# -*- coding: utf-8 -*-
"""
Batch detect rna-FISH-spots using big-fish. 
See https://github.com/fish-quant/big-fish

This script (c) 2022 INSERM
written by Volker Baecker (volker.baecker at mri.cnrs.fr)
for Montpellier Ressources Imagerie (www.mri.cnrs.fr)
"""

import os
import sys
import glob
import numpy as np
import bigfish
import bigfish.stack as stack
import bigfish.detection as detection

from tkinter import filedialog, Tk

RNA_FISH_SPOTS_CHANNEL = '561'
VOXEL_SIZE = 1
SPOT_RADIUS = 1.2
ALPHA = 0.7
BETA = 1
GAMMA = 5
MAX_SPOTS_FOR_DECOMPOSITION = 1000000

def main():
    """
    Apply the spot detection to all images of the spot-channel in all subfolders of the selected root-folder.

    Returns
    -------
    None.

    """
    print("Big-FISH version: {0}".format(bigfish.__version__))
    rootFolder = getFolderFromUser()
    subfoldersOfRootFolder = getMatchingSubfoldersIn(rootFolder, 'Coleno')
    for folder in subfoldersOfRootFolder:
        files = getFilesForChannel(folder, RNA_FISH_SPOTS_CHANNEL)
        images = []
        for file in files:
            rna = stack.read_image(file)
            images.append(rna)
        print("processing files {}".format(files))
        spots, threshold = detectSpots(images)
        for file, image, spot in zip(files, images, spots):
            if spot.shape[0] < MAX_SPOTS_FOR_DECOMPOSITION:
                spots, dense_regions, reference_spot = decomposeSpots(image, spot)
                outPath = file.split(".")[0]+".txt"
                np.savetxt(outPath, spot, delimiter =", ")
            
def detectSpots(rna):
    """
    Detect spots in the image.

    Parameters
    ----------
    rna : array
        The input image.

    Returns
    -------
    spots : array
        An array of spot positions.
    threshold : float
        The threshold for the spot-detection, calculated by the software.

    """
    spots, threshold = detection.detect_spots(
    images=rna, 
    return_threshold=True, 
    voxel_size=(VOXEL_SIZE, VOXEL_SIZE),  
    spot_radius=(SPOT_RADIUS, SPOT_RADIUS)) 
    for roi in spots:
        print("detected spots")
        print("\r shape: {0}".format(roi.shape))
        print("\r dtype: {0}".format(roi.dtype))
        print("\r threshold: {0}".format(threshold))
    return spots, threshold

def decomposeSpots(rna, spots):
    """
    Decompose spots in dense regions to individual spots.

    Parameters
    ----------
    rna : array
        The input image
    spots : array
        The spots to be decomposed

    Returns
    -------
    spots_post_decomposition : array
        The list of decomposed spots.
    dense_regions : ???
        ???.
    reference_spot : ???
        ???.

    """
    spots_post_decomposition, dense_regions, reference_spot = detection.decompose_dense(
    image = rna, 
    spots = spots, 
    voxel_size = (VOXEL_SIZE, VOXEL_SIZE), 
    spot_radius = (SPOT_RADIUS, SPOT_RADIUS), 
    alpha = ALPHA,  # alpha impacts the number of spots per candidate region
    beta = BETA,  # beta impacts the number of candidate regions to decompose
    gamma = GAMMA)  # gamma the filtering step to denoise the image
    print("detected spots before decomposition")
    print("\r shape: {0}".format(spots.shape))
    print("\r dtype: {0}".format(spots.dtype), "\n")
    print("detected spots after decomposition")
    print("\r shape: {0}".format(spots_post_decomposition.shape))
    return spots_post_decomposition, dense_regions, reference_spot

def getFilesForChannel(folder, channel):
    """
    Get a list of files in the folder that contain channel in their names.

    Parameters
    ----------
    folder : string
        The path to the folder.
    channel : string
        The name of the channel as it is used in the filenames.

    Returns
    -------
    files : list
        A list of image-files of the given channel in the given folder.

    """
    files = glob.glob(folder+"/"+"*"+channel+"*")    
    return files
    
def getFolderFromUser():
    """
    Open a file-dialog and let the user select the root-folder of the project.
    
    Returns
    -------
    rootFolder : String
        The root folder of the project.

    """
    root = Tk() 
    root.withdraw() 
    root.attributes('-topmost', True) 
    rootFolder = filedialog.askdirectory() 
    return rootFolder
    
def getMatchingSubfoldersIn(rootFolder, text):
    """
    Answer the subfolders in the root-folder that contain text in their names.
    
    Parameters
    ----------
    rootFolder : String
        The folder for which the subfolders will be answered.

    Returns
    -------
    subfoldersOfRootFolder : list
        A list of global paths to the subfolders of the root-folder.

    """
    filesInRootFolder = os.listdir(rootFolder)
    subfoldersOfRootFolder = [os.path.join(rootFolder, aPath) for 
                              aPath in filesInRootFolder if 
                              os.path.isdir(os.path.join(rootFolder, aPath)) 
                              and text in aPath]
    return subfoldersOfRootFolder
    
if __name__ == '__main__':
    sys.exit(main()) 


