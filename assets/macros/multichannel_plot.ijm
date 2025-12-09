// Macro to make line plots with 4 selectable normalization modes
// Styled for publication: Larger Fonts (24), Thick Lines (4)
//
// Mode 1: Mean Normalization (Mean=1.0)
// Mode 2: Max Scaling (Match Primary Ch Max, Min fixed at 0)
// Mode 3: Min-Max Scaling (Match Primary Ch Min & Max) -> ADDED
// Mode 4: Raw Intensity

macro "Multi-mode Plot Profile Final 4-Modes" {
	setTool("line");
	if (isOpen("ROI Manager")) {
		selectWindow("ROI Manager");
		run("Close");
	}
	inv = false;
	
	// Variables for calculation
	firstSelected = -1; 
	refMax = 0; 
	refMin = 0; // Added for Min-Max scaling
	globalMaxY = 0; 
	
	getVoxelSize(vw, vh, vd, unit);
	
	// 1. Check Line Selection
	do{
		type = selectionType();
		if (type!=5){
			title="Warning";
			msg="The macro needs a line selection.\nMake a line selection and click \"OK\"";
			waitForUser(title, msg);
		}
	wait(100);
	}while(type!=5);
	
	getLine(x1, y1, x2, y2, lineWidth);
	dx = (x2-x1)*vw; 
	dy = (y2-y1)*vh;
	totalDist = sqrt(dx*dx+dy*dy);

	Stack.getDimensions(width, height, channels, slices, frames);

	// 2. Handle RGB/Composite
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

	// 3. Create Dialog (Updated with 4 options)
	modes = newArray("Mean Normalization (Mean=1.0)", "Max Scaling (Match Primary Ch Max)", "Min-Max Scaling (Match Primary Ch Min&Max)", "Raw Intensity (No Scaling)");
	
	if (channels > 1){
		Dialog.create("Multi-Channel Plot Settings");
			Dialog.addMessage("Select Channels:");
			for (i=0; i<channels;i++){
				Dialog.addCheckbox(color[i+1], true);
			}
			Dialog.addMessage("-----------------");
			Dialog.addRadioButtonGroup("Normalization Method:", modes, 4, 1, "Mean Normalization (Mean=1.0)");
		Dialog.show();
		
		setBatchMode(true);
		
		for (i=0; i<channels;i++){
			channel[i] = Dialog.getCheckbox();
			if (channel[i] && firstSelected == -1) firstSelected = i + 1;
		}
		modeChoice = Dialog.getRadioButton();
	} else {
		firstSelected = 1;
		modeChoice = "Raw Intensity (No Scaling)"; 
	}

	// 4. DATA ANALYSIS PASS
	for (i=1; i<=channels; i++){
		if(channel[i-1]==true){
			if (channels>1) Stack.setChannel(i);
			run("Plot Profile");
			Plot.getValues(x, y);
			close();
			
			Array.getStatistics(y, cMin, cMax, cMean, cStd);
			if (cMean == 0) cMean = 0.0001; 
			if (cMax == 0) cMax = 0.0001;

			// Logic to find limits and references
			if (modeChoice == "Mean Normalization (Mean=1.0)") {
				normMax = cMax / cMean;
				if (normMax > globalMaxY) globalMaxY = normMax;
			} 
			else if (modeChoice == "Max Scaling (Match Primary Ch Max)") {
				if (i == firstSelected) {
					refMax = cMax; 
					if (cMax > globalMaxY) globalMaxY = cMax;
				}
			}
			else if (modeChoice == "Min-Max Scaling (Match Primary Ch Min&Max)") {
				if (i == firstSelected) {
					refMin = cMin;
					refMax = cMax;
					// For limits, we use the primary channel's range
					if (cMax > globalMaxY) globalMaxY = cMax;
				}
			}
			else { // Raw
				if (cMax > globalMaxY) globalMaxY = cMax;
			}
		}
	}
	
	// Determine Plot Limits
	yLimitTop = 0;
	yTitle = "";
	yMinLimit = 0;
	
	if (modeChoice == "Mean Normalization (Mean=1.0)") {
		yLimitTop = globalMaxY * 1.1; 
		yTitle = "Normalized intensity"; 
	} 
	else if (modeChoice == "Max Scaling (Match Primary Ch Max)") {
		yLimitTop = refMax * 1.05; 
		yTitle = "Intensity (Max Scaled)";
	} 
	else if (modeChoice == "Min-Max Scaling (Match Primary Ch Min&Max)") {
		// Calculate range padding based on Primary Channel
		range = refMax - refMin;
		yLimitTop = refMax + (range * 0.05);
		yMinLimit = refMin - (range * 0.05);
		if (yMinLimit < 0) yMinLimit = 0;
		yTitle = "Intensity (Min-Max Scaled)";
	}
	else {
		yLimitTop = globalMaxY * 1.05;
		yTitle = "Intensity (Raw)";
	}


	// 5. DRAW PLOT
	Plot.create("Profile Plot", "Distance ("+unit+")", yTitle);
	Plot.setFrameSize(600, 400); 
	Plot.setFontSize(24);        
	Plot.setLimits(0, totalDist, yMinLimit, yLimitTop);
	
	// --- A. Draw Reference Line (Mean Mode Only) ---
	if (modeChoice == "Mean Normalization (Mean=1.0)") {
		Plot.setColor("lightgray");
		Plot.setLineWidth(2);
		Plot.drawLine(0, 1, totalDist, 1); 
	}

	// --- B. Draw Data Lines ---
	Plot.setLineWidth(4); 

	for (i=1; i<=channels; i++){
		if (channels>1) Stack.setChannel(i); 
		
		if(channel[i-1]==true){
			run("Plot Profile");
			Plot.getValues(x, y);
			close(); 

			Array.getStatistics(y, cMin, cMax, cMean, cStd);
			if (cMean == 0) cMean = 0.0001;
			if (cMax == 0) cMax = 0.0001;
			
			yNew = newArray(y.length);

			// --- Apply Transformation ---
			
			// Mode 1: Mean Normalization
			if (modeChoice == "Mean Normalization (Mean=1.0)") {
				for (k=0; k<y.length; k++) yNew[k] = y[k] / cMean;
				legendLabels = legendLabels + "Ch" + i + "\t";
			}
			
			// Mode 2: Max Scaling
			else if (modeChoice == "Max Scaling (Match Primary Ch Max)") {
				if (i == firstSelected) {
					yNew = y; 
				} else {
					factor = refMax / cMax;
					for (k=0; k<y.length; k++) yNew[k] = y[k] * factor;
				}
				legendLabels = legendLabels + "Ch" + i + " (Max Scaled)\t";
			}
			
			// Mode 3: Min-Max Scaling (Added)
			else if (modeChoice == "Min-Max Scaling (Match Primary Ch Min&Max)") {
				if (i == firstSelected) {
					yNew = y;
				} else {
					// Formula: scaled = (raw - min) * (refRange / rawRange) + refMin
					cRange = cMax - cMin;
					refRange = refMax - refMin;
					if (cRange == 0) cRange = 1;
					
					for (k=0; k<y.length; k++) {
						yNew[k] = (y[k] - cMin) * (refRange / cRange) + refMin;
					}
				}
				legendLabels = legendLabels + "Ch" + i + " (MinMax Scaled)\t";
			}
			
			// Mode 4: Raw
			else {
				yNew = y;
				legendLabels = legendLabels + "Ch" + i + " (Max:" + d2s(cMax,0) + ")\t";
			}

			Plot.setColor(color[i]); 
			Plot.add("line", x, yNew);
		}
	}

	Plot.addLegend(legendLabels);
	Plot.show();
	setBatchMode(false);
}