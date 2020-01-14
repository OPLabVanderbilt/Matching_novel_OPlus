# Matching_Ziggerin
Matching Same Different task with Ziggerin
Dependencies:
* stimuli directory
* data directory
* mask_Ziggerin.jpg
* instruct1.jpg
* instruct2.jpg

Still uses the same images as the original version.

NOTE THAT THIS IS RELATIVELY UNTESTED FOR IN-LAB.

## Online Conversion and uploading notes
A separate file of online assets are available as a dependency. The script uses images from the online assets, trial file, and stimuli to create images to be used in the OPLab.barrios.io interface for an online version of the experiment. Note that the Matlab script requires the computer vision toolbox to add buttons programatically. There appears to be a bug with the OPLab.barrios.io interface which makes uploading files tricky, these are my observations:
* After uploading many images, the server can block your computer/IP from uploading anything larger than 60kb. Work around by changing computers. The error that appears here is noted by red text under the upload box.
* When you can upload images, uploading a single zip with the entire experiment is finnicky. The script automatically packages the entire set of images into smaller zip files. Try to upload them one at a time, if one fails to finish (the bar doesn't complete), simply try it again. 
