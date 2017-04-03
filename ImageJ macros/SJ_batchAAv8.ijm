// Batch Process images, combining amendments to v6 + v7
// no background subtraction
// set min max to 0-4095 to be done manually prior to starting but also included in code
// Generate HiLo images

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
	
	originwidth = getWidth;
	originheight = getHeight;
	
	
// Get ROI to ROI manager
	run("To ROI Manager");

// Set to 12-bit image
	setMinAndMax(0, 4095);
	call("ij.ImagePlus.setDefault16bitRange", 12);

// Process Channel 1
	run("Duplicate...", "duplicate channels=1");
	run("Z Project...", "projection=[Max Intensity]");
	run("Duplicate...", "title=Ch1");

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

// Save Channel 1 HiLo LUT
	selectWindow("Ch1");
	run("Duplicate...", "title=save");
	title = "HiLo_C1_"+sampleid;
	run("HiLo");
	run("RGB Color");
	saveAs("Tiff", destdir +title);
	close();

// Make Channel 1 into binary mask
	selectWindow("Ch1");
	run("From ROI Manager");
	roiManager("select", 0);
	setAutoThreshold("MaxEntropy dark");
	getThreshold(C1min, C1max);
	run("Convert to Mask");
	run("Divide...", "value=255");
	title = "Mask_"+"C1_"+sampleid;
	saveAs("Tiff", destdir +title);

// Save visible version of binary mask
	run("Duplicate...", "title=save");
	roiManager("Deselect");
	run("Enhance Contrast", "equalize histogram");
	saveAs("PNG", destdir +title);
	run("Close");

// Process channel 2
	selectWindow(origin);
	run("Duplicate...", "duplicate channels=2");
	run("Z Project...", "projection=[Max Intensity]");
	run("Duplicate...", "title=Ch2");

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

// Save Channel 2 HiLo LUT
	selectWindow("Ch2");
	run("Duplicate...", "title=save");
	title = "HiLo_C3_"+sampleid;
	run("HiLo");
	run("RGB Color");
	saveAs("Tiff", destdir +title);
	close();

// Make Channel 2 into binary mask
	selectWindow("Ch2");
	run("From ROI Manager");
	roiManager("select", 0);
	setAutoThreshold("MaxEntropy dark");
	getThreshold(C2min, C2max);
	run("Convert to Mask");
	run("Divide...", "value=255");
	title = "Mask_"+"C2_"+sampleid;
	saveAs("Tiff", destdir +title);

// Save visible version of binary mask
	run("Duplicate...", "title=save");
	roiManager("Deselect");
	run("Enhance Contrast", "equalize histogram");
	saveAs("PNG", destdir +title);
	run("Close");

// Multiply C1 and C2 masks
	image1 = "Mask_C1_"+sampleid +".tif";
	image2 = "Mask_C2_"+sampleid +".tif";
	imageCalculator("Multiply create", image1,image2);
	
	title = "C1xC2_"+sampleid;
	saveAs("Tiff", destdir +title);	

	run("Duplicate...", "title=save");
	roiManager("Deselect");
	run("Enhance Contrast", "equalize histogram");
	saveAs("PNG", destdir +title);
	run("Close");
	
// Histogram of C1 x C2
	run("Clear Results");

	selectWindow(title+".tif");
	cropwidth = getWidth;
	cropheight = getHeight;
	run("From ROI Manager");
	roiManager("select", 0);
	
	row = 0; 
	getHistogram(Values, counts, 256);
	                for (k=0; k<2; k++) {
	                	setResult("Label", row, "C1xC2");	
	                	setResult("Value", row, k);
	                	setResult("Count", row, counts[k]);
	                	row++;
	        }
	updateResults();

// Histogram of C1 & C2
	selectWindow("Mask_C1_"+sampleid +".tif");
	run("From ROI Manager");
	roiManager("select", 0);
	row = nResults;
	getHistogram(Values, counts, 256);
	                for (k=0; k<2; k++) {
	                	setResult("Label", row, "C1");
	                	setResult("Value", row, k);
	                	setResult("Count", row, counts[k]);
	                	row++;
	        }
	        updateResults();
	selectWindow("Mask_C2_"+sampleid +".tif");
	run("From ROI Manager");
	roiManager("select", 0);
	row = nResults;
	getHistogram(Values, counts, 256);
	                for (k=0; k<2; k++) {
	                	setResult("Label", row, "C2");
	                	setResult("Value", row, k);
	                	setResult("Count", row, counts[k]);
	                	row++;
	        }
	        updateResults();
	name = "histograms_" + sampleid + ".csv"; 
	saveAs("Results", destdir+name);
	run("Clear Results");

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

// Save Channel 3 HiLo LUT
	selectWindow("Ch3");
	run("Duplicate...", "title=save");
	title = "HiLo_C3_"+sampleid;
	run("HiLo");
	run("RGB Color");
	saveAs("Tiff", destdir +title);
	close();

// Multiply C1 mask with C3 and get Histogram
	selectWindow("Ch3");
	imageCalculator("Multiply create 32-bit", image1, "Ch3");
	
	run("Duplicate...", "title=save");
	roiManager("Deselect");
	run("8-bit");
	run("Enhance Contrast", "equalize histogram");
	title = "C1bxC3_"+sampleid;
	saveAs("PNG", destdir +title);
	run("Close");
	
	run("From ROI Manager");
	roiManager("select", 0);
	row = nResults;
	getHistogram(Values, counts, 4096,0,4095);
	                for (k=0; k<4096; k++) {
	                	setResult("Label", row, "C1bxC3");
	                	setResult("Value", row, k);
	                	setResult("Count", row, counts[k]);
	                	row++;
	        }
	        updateResults();

// Multiply C2 mask with C3 and get Histogram
	selectWindow("Ch3");
	imageCalculator("Multiply create 32-bit", image2, "Ch3");
	
	run("Duplicate...", "title=save");
	roiManager("Deselect");
	run("8-bit");
	run("Enhance Contrast", "equalize histogram");
	title = "C2bxC3_"+sampleid;
	saveAs("PNG", destdir +title);
	run("Close");
	
	roiManager("select", 0);
	row = nResults;
	getHistogram(Values, counts, 4096,0,4095);
	                for (k=0; k<4096; k++) {
	                	setResult("Label", row, "C2bxC3");
	                	setResult("Value", row, k);
	                	setResult("Count", row, counts[k]);
	                	row++;
	        }
	        updateResults();

// Multiply C1C2 mask with C3 and get Histogram
	selectWindow("Ch3");
	image3 = "C1xC2_"+sampleid +".tif";
	imageCalculator("Multiply create 32-bit", image3 , "Ch3");
	
	run("Duplicate...", "title=save");
	roiManager("Deselect");
	run("8-bit");
	run("Enhance Contrast", "equalize histogram");
	title = "C1C2bxC3_"+sampleid;
	saveAs("PNG", destdir +title);
	run("Close");
	
	run("From ROI Manager");
	roiManager("select", 0);
	row = nResults;
	getHistogram(Values, counts, 4096,0,4095);
	                for (k=0; k<4096; k++) {
	                	setResult("Label", row, "C1C2bxC3");
	                	setResult("Value", row, k);
	                	setResult("Count", row, counts[k]);
	                	row++;
	        }
	        updateResults();

// save histogram data
	name = "Phalloidin_" + sampleid + ".csv"; 
	saveAs("Results", destdir+name);
	run("Clear Results");

// Get C3 Histogram
	selectWindow("Ch3");
	
	run("From ROI Manager");
	roiManager("select", 0);
	row = nResults;
	getHistogram(Values, counts, 4096,0,4095);
	                for (k=0; k<4096; k++) {
	                	setResult("Label", row, "C3");
	                	setResult("Value", row, k);
	                	setResult("Count", row, counts[k]);
	                	row++;
	        }
	        updateResults();

// save histogram data
	name = "C3origin_" + sampleid + ".csv"; 
	saveAs("Results", destdir+name);
	run("Clear Results");

// Make Channel 3 into binary mask
	selectWindow("Ch3");
	run("From ROI Manager");
	roiManager("select", 0);
	setAutoThreshold("MaxEntropy dark");
	getThreshold(C3min, C3max);
	run("Convert to Mask");
	run("Divide...", "value=255");
	title = "Mask_"+"C3_"+sampleid;
	saveAs("Tiff", destdir +title);

// Save visible version of binary mask
	run("Duplicate...", "title=save");
	roiManager("Deselect");
	run("Enhance Contrast", "equalize histogram");
	saveAs("PNG", destdir +title);
	run("Close");

// Get histogram data of binary mask (to crosscheck with non-masked data)
	run("Clear Results");
	selectWindow("Mask_C3_"+sampleid +".tif");
	run("From ROI Manager");
	roiManager("select", 0);
	row = nResults;
	getHistogram(Values, counts, 256);
	                for (k=0; k<2; k++) {
	                	setResult("Label", row, "C3");
	                	setResult("Value", row, k);
	                	setResult("Count", row, counts[k]);
	                	row++;
	        }
	        updateResults();
	name = "C3bhistogram_" + sampleid + ".csv"; 
	saveAs("Results", destdir+name);

// Get image info
	run("Clear Results");
	setResult("Label", 0, "original image");
	setResult("Width", 0, originwidth);
	setResult("Height", 0, originheight);
	setResult("Label", 1, "cropped image");
	setResult("Width", 1, cropwidth);
	setResult("Height", 1, cropheight);
	setResult("Label", 2, "Threshold value C1/C2/C3");
	setResult("C1min", 2, C1min);
	setResult("C2min", 2, C2min);
	setResult("C3min", 2, C3min);
	
	print("\\Clear");
	getPixelSize(unit, pw, ph, pd);
	if (unit!="pixel" || pd!=1) {
	      if (pw==ph)
	          print(1/pw+" pixels per "+unit);
	      else {
	          print("check manually");
	      }
	  }
	res = getInfo("log");
	
	setResult("Label", 3, "Resolution");
	setResult("Resolution", 3, res);
	
	name = "imagedata_" +sampleid + ".csv"; 
	saveAs("Results", destdir+name);
	
	run("Close All");
	selectWindow("Log");
	run("Close");
	selectWindow("ROI Manager");
	run("Close");
	run("Clear Results");
	selectWindow("Results");
	run("Close");
	


	print("Processing: " + input + file);
	print("Saving to: " + output);
}


// If ever want to get histogram graph: run("Histogram", "bins=4096 x_min=0 x_max=4096 y_max=Auto");