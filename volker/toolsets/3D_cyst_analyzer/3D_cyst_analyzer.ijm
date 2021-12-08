/**
 * 3D Cyst Analyzer
 * 
 * Segment and track the cells. Construct the lineage of the cells. 
 * Measure intensity in the cytoplasm and in the membrane of the cells.
 * 
 *  (c) 2021, INSERM
 *  
  * written by Volker Baecker at Montpellier Ressources Imagerie, Biocampus Montpellier, INSERM, CNRS, University of Montpellier (www.mri.cnrs.fr)
 */

var DIAMETERXY = 18;
var RADIUSZ = 9;
var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/3D_Cyst_Analyzer";


macro "3D cyst analyzer tool help [f4]" {
	run('URL...', 'url='+helpURL);
}

macro "3D cyst analyzer help (f4) Action Tool - C000L0020C421D30C5aaL4050C849D60Ca64D70C544D80C462L90a0C421Db0C000Lc0f0L0111C110D21C854D31C849L4151C854D61C586L7181C849L91b1C854Dc1C421Dd1C000Le1f1D02C110D12C421D22C849L3242C586L5282C979D92C849Da2C979Db2Cbb2Lc2d2C421De2C000Df2D03C421D13C854D23Ca64L3343C586D53C462D63C544D73C586D83C9a8D93C979La3b3C5aaDc3Caa6Dd3C854De3C000Df3C110D04C854D14Ca64L2444C586D54C462L6474C586D84C9a8D94C979Da4Cbb2Db4C586Dc4C5aaDd4Ca64De4C110Df4C854D05Ca64D15Cbb2L2535Ca64D45C854D55C586D65C5aaL7595Caa6Da5Cbb2Lb5c5C5aaDd5C979De5C544Df5Caa6D06Cbb2L1626Ca64D36C854L4666C5aaL7686C9abD96Cbb2La6c6Caa6Dd6C854Le6f6Caa6L0727Ca64D37C854D47C544D57C421D67C462D77C5aaL8797C9a8Da7Cbb2Lb7d7C462Le7f7C979D08C9abL1828C979D38C439D48C544D58C421L6878C849D88C9abL98a8Caa6Db8C462Lc8f8C979D09C9a8D19C979D29C439L3959C421L6979C849D89C979D99C9abLa9b9C439Dc9C9a8Ld9f9C979D0aC544D1aC439L2a5aC854D6aC421D7aC849D8aC9abL9aaaC9a8DbaC439LcadaC9abDeaC9a8DfaC544L0b1bC439L2b3bC849D4bC979L5b6bCbb2D7bCaa6D8bC9a8L9babC5aaDbbC439DcbC9abLdbebC544DfbC110D0cC544D1cCaa6D2cC439D3cC849D4cC979L5c6cCaa6L7cacC5aaDbcC586DccC9abDdcC9a8DecC421DfcC000D0dC462D1dCaa6D2dC9a8L3d4dCa64L5d7dC854D8dC462D9dC586DadC5aaLbdcdC9abDddC421DedC000DfdD0eC110D1eC544D2eC586D3eC9a8D4eCaa6D5eCa64L6e7eC421D8eC544L9eaeC9abDbeC9a8DceC462DdeC000LeefeL0f1fC110D2fC462D3fC586D4fC544L5f6fC849D7fC439D8fC849D9fC9abDafC544DbfC421DcfC000Ldfff"{
	run('URL...', 'url='+helpURL);
}

macro "export frames (f5) Action Tool - C000T4b12f" {
	exportFrames();
}

macro "export frames [f5]" {
	exportFrames();
}

macro "remove labels in the center (f6) Action Tool - C000T4b12r" {
	removeLabelsInTheCenter();
}

macro "remove labels in the center [f6]" {
	removeLabelsInTheCenter();
}

macro "remove labels in selection (f7) Action Tool - C000T4b12s" {
	removeSelectedLabelsCurrentFrame();
}

macro "remove labels in selection [f7]" {
	removeSelectedLabelsCurrentFrame();
}

function exportFrames() {
	path = getDir("Select the output-folder!");
	Stack.getDimensions(width, height, channels, slices, frames);
	title = getTitle();
	name = File.getNameWithoutExtension(title);
	for (i = 1; i <= frames; i++) {
		run("Duplicate...", "duplicate frames="+i+"-"+i);
		save(path+name+IJ.pad(i, 3)+".tif");
		close();
	}
}

function removeSelectedLabelsCurrentFrame() {
	title = getTitle();
	inputImageID = getImageID();
	Stack.getDimensions(width, height, channels, slices, frames);
	Stack.getPosition(channel, slice, frame)
	run("Duplicate...", "title=frame duplicate frames="+frame+"-"+frame);
	removeLabelsInSelection();
	rename("current");
	selectImage(inputImageID);
	if (frame>1) {
		run("Duplicate...", "title=head duplicate frames=1-"+(frame-1));
	}
	selectImage(inputImageID);
	if (frame<frames) {
		run("Duplicate...", "title=tail duplicate frames="+(frame+1)+"-"+frames);
	}
	if (frame>1 && frame<frames) {
		run("Concatenate...", "  title=tmp open image1=head image2=current image3=tail");
	}
	if (frame==1) {
		run("Concatenate...", "  title=tmp open image1=current image2=tail");
	}
	if (frame==frames) {
		run("Concatenate...", "  title=tmp open image1=head image2=current");
	}
	selectImage(inputImageID);
	close();
	selectImage("tmp");
	rename(title);
	Stack.setPosition(channel, slice, frame);
}

function removeLabelsInTheCenter() {
	title = getTitle();
	inputImageID = getImageID();
	newTitle = title + "-cleaned";
	Stack.getDimensions(width, height, channels, slices, frames);
	for (frame = 1; frame <= frames; frame++) {
		selectImage(inputImageID);
		run("Duplicate...", "title=frame duplicate frames="+frame+"-"+frame);
		removeLabelsInTheCenterForFrame();
		if (frame==1) {
			rename("movie");
			continue;
		}
		run("Concatenate...", "open title=nmovie image1=movie image2=frame image3=[-- None --]");
		rename("movie");
	}
	rename(newTitle);
}

function removeLabelsInTheCenterForFrame() {
	firstSlice = 0;
	for (slice = 1; slice <= nSlices; slice++) {
		Stack.setSlice(slice);
		getStatistics(area, mean, min, max, std, histogram);
		if (min==0 && max==0) {
			firstSlice++;
		} else {
			firstSlice++;
			break;
		}
	}
	lastSlice = nSlices+1;
	for (slice = lastSlice; slice >= 1; slice--) {
		Stack.setSlice(slice);
		getStatistics(area, mean, min, max, std, histogram);
		if (min==0 && max==0) {
			lastSlice--;
		} else {
			lastSlice--;
			break;
		}
	}
	
	middleSlice = firstSlice + ((lastSlice - firstSlice) / 2);
	print(firstSlice, lastSlice, middleSlice);
	Stack.setSlice(middleSlice);
	setThreshold(1, 65535);
	run("Create Selection");
	xCentroid = getValue("X");
	yCentroid = getValue("Y");
	toUnscaled(xCentroid, yCentroid);
	run("Select None");
	
	labelsToBeRemoved = newArray(0);
	start = maxOf(1, middleSlice - RADIUSZ);
	end = minOf(middleSlice + RADIUSZ, nSlices);
	for (slice = start; slice <= end; slice++) {
		setSlice(slice);
		makeOval(xCentroid-(DIAMETERXY/2), yCentroid-(DIAMETERXY/2), DIAMETERXY, DIAMETERXY);
		removeLabelsInSelection();
		run("Select None");
	}
	resetThreshold();
}


function removeLabelsInSelection() {
	getRawStatistics(nPixels, mean, min, max, std, histogram);
	run("Select None");
	for (i = 1; i < histogram.length; i++) {
		if (histogram[i]==0) continue;
		run("Replace/Remove Label(s)", "label(s)="+i+" final=0");
	}
	run("Restore Selection");
}

