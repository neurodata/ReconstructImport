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

The first step in the conversion process is to apply transformations to the image files, and convert the XML data in the anno files to image format. 

### Grouping Annotations for Open Connectome Ingest

The second step is to group annotations into a single image file. While Open Connectome can ingest all the annotation files individually, it is more efficient to process annotation files on the local machine and upload to Open Connectome. 
