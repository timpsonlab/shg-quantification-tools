# SHG Quantification Tools
This code provides tools for quantification of second harmonic generation (SHG) images. 
Now uses Matlab 2016b runtime


## Running the code

### Getting started
* To run the code you need [Matlab](http://www.mathworks.com/products/matlab). We have tested the code with version R2015a and above.
* Download the code using [git](https://help.github.com/articles/cloning-a-repository/) or by clicking 'Download ZIP' on the [GitHub project page](https://github.com/timpsonlab/shg-quantification-tools)
*  In Matlab, navigate to the `shg-quantification-tools` folder and type `Interface` to run the user interface

## Intensity analysis of SHG images

### Aim
To quantify the average SHG intensity through a series of z-stacks, producing an z-profile of intensity for each stack aligned such that the position of maximum intensity occurs in the same position for each stack. 

We currently assume that the z-stacks are saved in a Leica LIF file.

### Method
* Acquire a series of z-stacks from one or more samples in a Lif file 
* Select the `Process SHG from Lif` menu item
* Select your Lif file
* Select the correct options for your data
   * `Filter using string:` If you would only like to process images from the Lif file with a names that contain a string, enter that string in the filter text box. E.g. if you enter `SHG`, only files containing `SHG` such as `Sample 1 SHG` or `SHG Slide 1` will be processed.  
   * `Channel Number (zero-indexed):` channel in the data containing the SHG images. If there is only one image, use `0`, if you would like to use the second channel, set `1`.

### Results
The code will produce two CSV files: 

 *  `[filename]-z-profile.csv`: One column per sample with the average SHG intensity at each z position 
 *  `[filename]-z-profile-aligned.csv`: One column per sample with the average SHG intensity at each z position aligned such that the maximum z-intensity occurs at the sample position for each sample

## GLCM analysis 

### Aim
To quantify the GLCM parameters for a series of images
