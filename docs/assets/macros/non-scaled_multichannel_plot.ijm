/*
 * Multi-Channel Line Profile Plotter
 * Function: Plots intensity profiles for multiple channels of a selected Line ROI on a single graph.
 * * Features:
 * - Optimized speed (removed redundant window operations)
 * - Auto-converts RGB to Composite
 * - Auto-scales Y-axis based on min/max of all selected channels
 * - Option to export numeric data to the Results Table
 */

macro "Plot Multi-Channel Profile" {
    
    // 1. Setup and Validation
    //run("Select None"); // Prevent interference from existing non-line selections
    if (selectionType() != 5) { // Check if a Straight Line is selected
        waitForUser("Error", "Please create a Straight Line selection first.");
        return;
    }
    
    getLine(x1, y1, x2, y2, lineWidth);
    getVoxelSize(vw, vh, vd, unit);
    Stack.getDimensions(width, height, channels, slices, frames);
    
    // Convert RGB to Composite if necessary
    if (bitDepth() == 24) {
        run("Make Composite");
        Stack.getDimensions(width, height, channels, slices, frames); // Update dimensions
    }

    // 2. Detect Channel Colors
    colors = newArray(channels + 1);
    labels = newArray(channels);
    defaults = newArray(channels);
    
    for (i = 1; i <= channels; i++) {
        Stack.setChannel(i);
        // Estimate color based on LUT
        getLut(r, g, b);
        colors[i] = "black"; // Fallback
        if (r[255]==255 && g[255]==0 && b[255]==0) colors[i] = "red";
        else if (r[255]==0 && g[255]==255 && b[255]==0) colors[i] = "green";
        else if (r[255]==0 && g[255]==0 && b[255]==255) colors[i] = "blue";
        else if (r[255]==255 && g[255]==0 && b[255]==255) colors[i] = "magenta";
        else if (r[255]==0 && g[255]==255 && b[255]==255) colors[i] = "cyan";
        else if (r[255]==255 && g[255]==255 && b[255]==0) colors[i] = "yellow";
        else if (r[255]==255 && g[255]==255 && b[255]==255) colors[i] = "lightGray";
        
        labels[i-1] = "Channel " + i + " (" + colors[i] + ")";
        defaults[i-1] = true;
    }

    // 3. User Input (Dialog)
    Dialog.create("Profile Options");
    Dialog.addMessage("Select channels to plot:");
    Dialog.addCheckboxGroup(channels, 1, labels, defaults);
    Dialog.addCheckbox("Show Data List (Results Table)", false);
    Dialog.show();

    selectedChannels = newArray(channels + 1);
    for (i = 0; i < channels; i++) {
        selectedChannels[i+1] = Dialog.getCheckbox();
    }
    showData = Dialog.getCheckbox();

    // 4. Data Collection (Calculate Min/Max & X-axis)
    profileLen = 0;
    
    // Initialize Min/Max for Y-axis scaling
    minY = 999999999;
    maxY = -999999999;

    setBatchMode(true); // Stop screen updates for speed

    // Calculate physical length of the line
    dx = (x2 - x1) * vw;
    dy = (y2 - y1) * vh;
    lineLen = sqrt(dx*dx + dy*dy);
    
    // Get profile length from the first selected channel to determine array size
    for (i=1; i<=channels; i++) {
        if (selectedChannels[i]) {
            Stack.setChannel(i);
            tempProf = getProfile();
            profileLen = tempProf.length;
            break;
        }
    }
    
    // Generate X-axis values (Distance)
    xValues = newArray(profileLen);
    for (j=0; j<profileLen; j++) {
        xValues[j] = j * (lineLen / (profileLen-1));
    }

    // 5. Generate Plot
    Plot.create("Multi-Channel Profile", "Distance (" + unit + ")", "Intensity");
    
    legendLabels = "";
    
    for (i = 1; i <= channels; i++) {
        if (selectedChannels[i]) {
            Stack.setChannel(i);
            yValues = getProfile();
            
            // Update Global Min/Max
            Array.getStatistics(yValues, min, max, mean, stdDev);
            if (max > maxY) maxY = max;
            if (min < minY) minY = min;

            // Add line to plot
            Plot.setColor(colors[i]);
            Plot.add("line", xValues, yValues);
            
            // Append to legend string
            legendLabels = legendLabels + "Channel " + i + "\t";
        }
    }
    
    // Set plot style and limits
    Plot.setLimits(0, lineLen, minY, maxY);
    Plot.setLegend(legendLabels);
    Plot.show();

    // 6. (Optional) Export Data to Results Table
    if (showData) {
        run("Clear Results");
        for (row = 0; row < profileLen; row++) {
            setResult("Distance", row, xValues[row]);
            for (i = 1; i <= channels; i++) {
                if (selectedChannels[i]) {
                    Stack.setChannel(i);
                    prof = getProfile();
                    setResult("Ch" + i, row, prof[row]);
                }
            }
        }
        updateResults();
    }
    
    setBatchMode(false); // Resume screen updates
    Stack.setChannel(1); // Reset to first channel
}