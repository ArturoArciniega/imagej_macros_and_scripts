#@ File (label = "Input directory", style = "directory") input
#@ File (label = "Output directory", style = "directory") output
#@ String (label = "File suffix", value = ".tif") suffix

processFolder(input);

function processFolder(input) {
    subFolders = getSubFoldersIn(input);
    images = getImagesIn(input);
    openImagesInList(images);
    title = getTitle();
    run("Concatenate...", "all_open");
    namePrefix = File.getName(input);
    save(output + File.separator + namePrefix + "-" +title);
    close();
    for (i = 0; i < subFolders.length; i++) {
        processFolder(subFolders[i]);
    }
}

function openImagesInList(images) {
    for (j = 0; j < images.length; j++) {
        open(images[j]);
    }    
}

function getSubFoldersIn(aFolder) {
    list = getFileList(input);
    subFolders = newArray(0);
    for (i = 0; i < list.length; i++) {
        file = list[i];
        if (File.isDirectory(input + File.separator + file)) {
           subFolders = Array.concat(subFolders, input + File.separator + file);     
        }
    } 
    return subFolders;
}

function getImagesIn(aFolder) {
    list = getFileList(aFolder);
    images = newArray(0);
    for (i = 0; i < list.length; i++) {
        file = list[i];
        if (endsWith(file, suffix)) {
            images = Array.concat(images, aFolder + File.separator + file);       
        }
    } 
    return images;
}

