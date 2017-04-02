// Re-run raw image generation only
// Batch Process images using SJ_areaanalysis_v4 macro (amended to allow for batch process)

input = getDirectory("Input directory");
output = getDirectory("Output directory");

Dialog.create("File type");
Dialog.addString("File suffix: ", ".tif", 5);
Dialog.show();
suffix = Dialog.getString();

processFolder(input);

function processFolder(input) {
	list = getFileList(input);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + list[i]))
			processFolder("" + input + list[i]);
		if(endsWith(list[i], suffix))
			processFile(input, output, list[i]);
	}
}

function processFile(input, output, file) {
	open(input+file);
	dir = output;
// SJ_areaanalysis_v4 macro:
// Clear Logs
	run("Clear Results");

// Get image info
	origin = getTitle;

	startindex = lastIndexOf(origin, "slide");
	endindex = lastIndexOf(origin, "SectionROI");
	sampleid = substring(origin, startindex, endindex);
	
	endindex2 = lastIndexOf(origin, "_10X");
	samplebase = substring(origin, startindex, endindex2);
	destdir = dir+samplebase+"\\";
	
// Get ROI to ROI manager
	run("To ROI Manager");

// Process Channel 1
	run("Duplicate...", "duplicate channels=1");
	run("Z Project...", "projection=[Max Intensity]");
	run("Duplicate...", "title=Ch1");
	// Fix ImageJ 12-bit image auto-scaling
	setMinAndMax(0, 4095);

// Save Channel 1 grayscale LUT
	selectWindow("Ch1");
	run("Duplicate...", "title=save");
	roiManager("Deselect");
	title = "Gray_C1_"+sampleid;
	run("Grays");
	run("8-bit");
	saveAs("Tiff", destdir +title);
	
// Save Channel 1 Fire LUT
	selectWindow("Ch1");
	run("Duplicate...", "title=save");
	title = "Fire_C1_"+sampleid;
	run("Fire");
	run("RGB Color");
	saveAs("Tiff", destdir +title);
	close();

// Process channel 2
	selectWindow(origin);
	run("Duplicate...", "duplicate channels=2");
	run("Z Project...", "projection=[Max Intensity]");
	run("Duplicate...", "title=Ch2");
	// Fix ImageJ 12-bit image auto-scaling
	setMinAndMax(0, 4095);

// Save Channel 2 grayscale LUT
	selectWindow("Ch2");
	run("Duplicate...", "title=save");
	roiManager("Deselect");
	title = "Gray_C2_"+sampleid;
	run("Grays");
	run("8-bit");
	saveAs("Tiff", destdir +title);

// Save Channel 2 Fire LUT
	selectWindow("Ch2");
	run("Duplicate...", "title=save");
	title = "Fire_C2_"+sampleid;
	run("Fire");
	run("RGB Color");
	saveAs("Tiff", destdir +title);
	close();

// Process channel 3
	selectWindow(origin);
	run("Duplicate...", "duplicate channels=3");
	// Fix ImageJ 12-bit image auto-scaling
	setMinAndMax(0, 4095);
	run("Z Project...", "projection=[Max Intensity]");
	run("Duplicate...", "title=Ch3");

// Save Channel 3 grayscale LUT
	selectWindow("Ch3");
	run("Duplicate...", "title=save");
	roiManager("Deselect");
	title = "Gray_C3_"+sampleid;
	run("Grays");
	run("8-bit");
	saveAs("Tiff", destdir +title);

// Save Channel 3 Fire LUT
	selectWindow("Ch3");
	run("Duplicate...", "title=save");
	title = "Fire_C3_"+sampleid;
	run("Fire");
	run("RGB Color");
	saveAs("Tiff", destdir +title);
	close();

// Close windows

	run("Close All");
	selectWindow("ROI Manager");
	run("Close");
	


	print("Processing: " + input + file);
	print("Saving to: " + output);
}