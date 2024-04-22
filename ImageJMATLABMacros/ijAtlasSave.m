function ijAtlasSave(savePath)

ij.IJ.run("RGB Color", "");
ij.IJ.saveAs("Tiff", savePath + "Fused (RGB).tif");
ij.IJ.run("Close All");