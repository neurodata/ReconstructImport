# ReconstructImport
matlab code for converting reconstruct files into OCP format

## Introduction
This repository contains a set of Matlab scripts that take as input a set of Reconstruct (http://synapses.clm.utexas.edu/tools/reconstruct/reconstruct.stm) data files and output files suitable for upload to Open Connectome (https://github.com/openconnectome/open-connectome).

All of the code in the ```MatlabCode``` directory was developed by Larry Lindsay (https://github.com/larrylindsey). The rest of the code was developed by Alex Baden as part of the Open Connectome Project, and is licensed under the Apache 2 license (see the ```LICENSE``` file).

For detailed explanations of how to run the code, read on.

## Usage
The following guide assumes the user has a directory of Reconstruct files. This directory should like something like the following:
```
  ReconstructProjectRoot
    * ImageFilePrefix.1.jpg
    * ImageFilePrefix.2.jpg
    * ImageFilePrefix.3.jpg
    * ImageFilePrefix.4.jpg
    * ...
    * AnnoFilePrefix.1
    * AnnoFilePrefix.2
    * AnnoFilePrefix.3
    * AnnoFilePrefix.4
    * ...
    * AnnoFile.ser
```

The image files are raw, unaligned images. The anno files contain the annotation contours and all alignment information. The number after each file prefix corresponds to the z-slice of the file.

### Extracting Annotations as Images and Applying Transformations

The first step in the conversion process is to apply transformations to the image files, and convert the XML data in the anno files to image format. The end result will be a directory of aligned images and annotation files (one for each ID).

*Warning* This step in the process will create an image for each individual annotation in your Reconstruct project. The total disk space required for this step could be more than 10 times greater than the disk space required for your Reconstruct project (depending on how many annotations you have).

#### Steps
1. Open Matlab and add the **ReconstructImport** directory (both selected folders and sub folders) to your path.
2. Browse to the root directory for your Reconstruct project and open the ```extract_annotation.m``` file for editing.
3. Create the following directories in your Reconstruct project root directory:
  * em
  * anno_raw
4. Change the following parameters in ```extract_annotation.m```
  * **(line 4)** ```ser = 'Volumejosef.ser' ```
  Replace the ```ser``` file prefix with your file prefix (e.g. ```AnnoFile``` in the above directory tree).  
   * **(line 27)**  ```anno_metadata = cell(2409,5);```
   We will need to create a metadata object with enough space to store metadata for all annotations in your project. Replace the first number (**2409** above) with the number of annotations in your project.
   * **(line 110-115)** If you have any contours you don't want converted, enter their names here.
   * **(line 132)** Replace the last two numbers with the image size of your *raw* image files. Here, the image size is **4096** x **4096**.
5. Execute the script by running ```extract_annotation``` on the Matlab command line.

When the script finishes, you will have a directory called ```em``` containing all aligned image files, and a directory called ```anno_raw``` containing image files for each annotation in your Reconstruct project.

### Grouping Annotations for Open Connectome Ingest

The second step is to group annotations into a single image file. While Open Connectome can ingest all the annotation files individually, it is more efficient to process annotation files on the local machine and upload to Open Connectome.

The ```process_annos.m``` script groups annotations. This script is heavily customized for Kristen Harris's Hippocampal Neuropil in 3DEM dataset (hosted at Open Connectome, see http://w.ocp.me/datum:harris15). We will walk through some basic features below, which should allow other users to customize the script for their needs.

#### Steps
1. Replace the **zstart**, **zend**, **xdim**, and **ydim** parameters in ```process_annos.m``` with the correct parameters for your dataset.
2. Make sure the path to your metadata csv file is correct (if you followed the steps above, it should be).
3. Decide how you want to group your dataset. The following groups are available:
  * **a** (axons)
  * **d** (dendrites)
  * **s** (synapses)
  * **g** (glia)
  * **c**, **p**, **r**, **m** (subcellular components)
  * *Note:* the labels given above don't matter, and depend only on how you want to characterize your data. For example, if you wanted to label mitochondria as *a* and all other components as *d*, that would be fine. It is up to you to define and remember a code. Feel free to create your own codes!
4. Open the ```anno_raw/anno_metadata.csv``` file and add your code for each annotation to the first empty column in the file.
5. For each group, run the following lines:
   1.  ```anno_group = groupAnnos(anno_info,'a','d');```
   2.  ```group_name = 'axon_dendrite';```
   * You can combine multiple groups by adding more groups to the function call to ```groupAnnos``` (the above line combines group **a** and **d**)
   * The **group_name** parameter specifies the output filename prefix.
6. Create a directory called ```annos_processed``` in your Reconstruct Project directory.
7. Run the processing code at the bottom of the ```process_annos.m``` file (lines 105-123).

### Next Steps
You should now have two directories full of files that can be uploaded to Open Connectome.

```em```: aligned image files that correspond exactly in file size to the annotation image files.
```annos_processed```: annotation image files (paint files) that are grouped according to the grouping preferences set above.
