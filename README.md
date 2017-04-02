Description:
Confocal image stacks of 100 - 150 um vibratome sections of 3D-cultured stem cell-derived aggregates analysed using ImageJ/Fiji and R. 

Instructions:
Copy ImageJ macros into Fiji.app > Plugins folder. Restart Fiji and open using Macros > Edit... 
_v6 macro generates csv with histogram data, tiff files of binary masks generated and used for image analysis, png files of those masks with contrast enhanced for the purposes of visualisation. LUTs of raw images generated from _v6 code are incorrect, because the images were imported as 16-bit images by default. This was accounted for in the histogram generation but not the image generation. This is fixed in the _v7 code.

_v7 macro is solely for the purpose of generating LUTs.

[LUTs = application of LUT to raw images]


