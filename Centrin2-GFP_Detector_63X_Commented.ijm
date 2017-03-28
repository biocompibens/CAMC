// Sigmas for Gaussian filtering, depends on picture quality. 
// if the images are very pixeleted we can use bigger values
G_x = 0.5; G_y = 0.5; G_z = 0.5;
// Sigmas for LoG. this should be the radious of the objects in 3D
L_x = 2; L_y = 2; L_z = 1;
// LOG threshold, Ideally zero, less means more strong threshold
TH_L = -450;
// Radius for maxima detection
// slightly bigger thqn the radius of the object
R_x = 2; R_y = 2; R_z = 2;

// Maxima threshold, Ideally 10% of the bit.
// This is value of removing weak detection. 1638 is 2.5% of 65535). 
// If 16 bit use arround 10000 or if 8 bit use arround 45
TH_M = 12.2;
TH_MV=TH_M*65535*0.01;

// Channel position in the stack
ch=2;

// Setup files. Please put all the input files in one directory, 
// and create one directory for output files
dir = getDirectory("Choose a Directory "); 
dir2 = getDirectory("Choose a Result Directory "); 
list = getFileList(dir); 

// Reading the files
for (k=0; k<list.length; k++) { 
        path = dir+list[k];         
        run("Bio-Formats Importer", "open=["+path+"]");
        path2 = dir2+File.nameWithoutExtension+ch; 

run("Grays"); run("Duplicate...","title=Frame1 duplicate channels="+ch);
selectWindow("Frame1"); run("Gaussian Blur 3D...", "x="+G_x+" y="+G_y+" z="+G_z);

// buffering
while (getTitle() != "Frame1") {
		wait(500);}
	
selectWindow("Frame1"); print("Running LoG...");
run("LoG 3D", "sigmax="+L_x+" sigmay="+L_y+" sigmaz="+L_z+" displaykernel=0 volume=1");

while (getTitle() != "LoG of Frame1") {
		wait(500);}
selectWindow("LoG of Frame1");

setThreshold(TH_L, 65535); 
run("Threshold", "thresholded remaining"); 
run("16-bit");
run("Multiply...", "value=257.000 stack");
wait(500);	
	
	// Subtraction
	imageCalculator("Subtract create stack", "Frame"+1,"LoG of Frame"+1);
	wait(500);

	// 3D Local maxima
	run("3D Fast Filters","filter=MaximumLocal radius_x_pix="+R_x+" radius_y_pix="+R_y+" radius_z_pix="+R_z+" Nb_cpus=8");
	wait(500);

selectWindow("Frame1"); run("Enhance Contrast", "saturated=0.35");
selectWindow("Frame1"); run("Z Project...", "projection=[Max Intensity]");
selectWindow("3D_MaximumLocal"); run("Z Project...", "projection=[Max Intensity]");

run("Subtract...", "value="+TH_MV);
run("Find Maxima...", "noise=10 output=[Single Points]"); run("Invert LUT");

run("Merge Channels...", "c2=[MAX_3D_MaximumLocal Maxima] c4=MAX_Frame1 keep ignore");
saveAs("PNG", path2+"-Overlay.png"); 
selectWindow("MAX_3D_MaximumLocal Maxima"); saveAs("PNG", path2+"-MAX_3D.png");
selectWindow("MAX_Frame1"); saveAs("PNG", path2+"-MAX_F.png");
run("Close All");} 

