// macro to make line plots with auto-scaling for visibility
// Modified to normalize intensities for better comparison of weak/strong signals

macro plot_multicolour_scaled{
	setTool("line");
	if (isOpen("ROI Manager")) {
		selectWindow("ROI Manager");
		run("Close");
	}
	inv = false;
	p = 0;
	
	// Variables for plot scaling
	refMin = 0;
	refMax = 0;
	firstSelected = -1; // To identify the primary channel

	getVoxelSize(vw, vh, vd, unit);
	
	// Check that there is a line selection
	do{
		type = selectionType();
		if (type!=5){
			title="Warning";
			msg="The macro needs a line selection.\nMake a line selection and click \"OK\"";
			waitForUser(title, msg);
		}
	wait(100);
	}while(type!=5);
	
	// Store original selection
	getLine(x1, y1, x2, y2, lineWidth);
	dx = (x2-x1)*vw; 
	dy = (y2-y1)*vh;

	Stack.getDimensions(width, height, channels, slices, frames);

	// Handle RGB/24bit images
	if (bitDepth==24){
		if (nSlices>1){
			roiManager("Add");
			run("Make Composite");
			wait(100); 
			setVoxelSize(vw, vh, vd, unit);
			roiManager("select", 0);
			selectWindow("ROI Manager");
			run("Close");
		}else{
			run("Make Composite");
		}
	}

	Stack.getDimensions(width, height, channels, slices, frames);
	channel = newArray(channels);
	color = newArray(channels+1);
	
	// Array to store channel names for legend
	legendLabels = ""; 

	// Default: select all
	for (i=0; i<channels;i++) channel[i]=true;

	// Detect colors
	for (i=1; i<=channels; i++){
		if (is("Inverting LUT")){
			run("Invert LUT");
			inv=true;
		}
		if (channels>1) Stack.setChannel(i); 
		getLut(reds, greens, blues);
		if ((reds[i]==i)&&(greens[i]==0)&&(blues[i]==0)) color[i] = "red";
		else if ((reds[i]==0)&&(greens[i]==i)&&(blues[i]==0)) color[i] = "green";
		else if ((reds[i]==0)&&(greens[i]==0)&&(blues[i]==i)) color[i] = "blue";
		else if ((reds[i]==0)&&(greens[i]==i)&&(blues[i]==i)) color[i] = "cyan";
		else if ((reds[i]==i)&&(greens[i]==0)&&(blues[i]==i)) color[i] = "magenta";
		else if ((reds[i]==i)&&(greens[i]==1)&&(blues[i]==0)) color[i] = "yellow";
		else if ((reds[i]==i)&&(greens[i]==i)&&(blues[i]==i)) color[i] = "gray";
		else color[i] = "black";
	}
	if (inv) run("Invert LUT");

	// Select channels Dialog
	if (channels > 1){
		Dialog.create("channels");
			Dialog.addMessage("Select channels to plot (First selected sets the scale):");
			for (i=0; i<channels;i++){
				Dialog.addCheckbox(color[i+1], true);
			}
		Dialog.show();
		setBatchMode(true);
		for (i=0; i<channels;i++){
			channel[i] = Dialog.getCheckbox();
			// Identify the first selected channel to serve as Y-axis reference
			if (channel[i] && firstSelected == -1) {
				firstSelected = i + 1;
			}
		}
	} else {
		firstSelected = 1;
	}

	// Plotting Loop
	for (i=1; i<=channels; i++){
		if (channels>1) Stack.setChannel(i); 
		
		if(channel[i-1]==true){
			
			// 1. Get correct X, Y values using the Plot Profile command to handle calibration
			run("Plot Profile");
			Plot.getValues(x, y);
			close(); // close the temporary plot window

			// 2. Get Statistics for current channel
			Array.getStatistics(y, currentMin, currentMax, currentMean, currentStd);
			
			// 3. Set up the Plot Window (if first time)
			if (p==0){
				// This is the Primary Channel (Reference)
				refMin = currentMin;
				refMax = currentMax;
				
				// Add some padding to Y axis
				yRange = refMax - refMin;
				plotMin = refMin - (yRange * 0.05);
				if(plotMin < 0) plotMin = 0;
				plotMax = refMax + (yRange * 0.05);

				Plot.create("Multi Channel Plot (Scaled)", "Distance ("+unit+")", "Intensity (Scaled)"); 
				Plot.setLimits(0, sqrt(dx*dx+dy*dy), plotMin, plotMax);
				
				// Add to legend
				legendLabels = legendLabels + "Ch" + i + " (Max:" + d2s(currentMax,0) + ")\t";
				
				p=1;
				
				// Plot the primary line as is
				Plot.setColor(color[i]); 
				Plot.add("line", x, y);
				
			} else {
				// 4. For subsequent channels: Scale data to fit the Reference Channel range
				// Formula: scaledY = (y - currMin) * (refRange / currRange) + refMin
				
				yScaled = newArray(y.length);
				currentRange = currentMax - currentMin;
				refRange = refMax - refMin;
				
				// Avoid division by zero if channel is empty
				if (currentRange == 0) currentRange = 1; 

				for (k=0; k<y.length; k++) {
					yScaled[k] = (y[k] - currentMin) * (refRange / currentRange) + refMin;
				}

				// Plot the scaled line
				Plot.setColor(color[i]); 
				Plot.add("line", x, yScaled);
				
				// Update legend to indicate scaling
				legendLabels = legendLabels + "Ch" + i + " (Scaled, Max:" + d2s(currentMax,0) + ")\t";
			}
		}
	}
	
	// Add the Legend at the end
	Plot.addLegend(legendLabels);
	Plot.show();
	setBatchMode(false);
}