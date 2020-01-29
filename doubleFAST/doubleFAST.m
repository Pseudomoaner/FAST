clear all
close all

%File choice
mainRoot = 'C:\path\to\root\'; %Main directory in which all of your datasets is located
branches = {'Branch_1','Branch_2','Branch_3'}; %Names of subdirectories within main directory in which each separate dataset is stored
batchRoots = fullfile(mainRoot,branches);

%Filename of the unprocessed image data (Only need to define this if you are running from raw images)
imgName = 'Img.czi';

%The following define the locations of the processing parameters,
%previously chosen through the FAST GUI. If any of these remain undefined,
%that portion of the processing will be skipped (can be useful if you only
%want to perform e.g. feature extraction without tracking).

%The location of the metadata file output during image import (if the bioformats import system is used)
MetadataLoc = 'C:\original\analysis\root\Metadata.mat';
 
%The location of the segmentParams file saved following image segmentation
SegmentSettingsLoc = 'C:\original\analysis\root\SegmentationSettings.mat';
 
%The location of the featSettings file output following feature extraction
FeatureSettingsLoc = 'C:\original\analysis\root\CellFeatures.mat';
 
%The location of the track data generated following the object tracking stages
TrackSettingsLoc = 'C:\original\analysis\root\Tracks.mat';
 
%The location of the track data with divisions detected
DivisionSettingsLoc = 'C:\original\analysis\root\Tracks.mat';

%% Data import
if exist('MetadataLoc','var') && exist('imgName','var')
    load(MetadataLoc,'metaStore')
    
    for r = 1:size(branches,2)
        root = [mainRoot,branches{r}];
        importBioformatsData(root,imgName,metaStore)
    end
end

%% Segmentation
if exist('SegmentSettingsLoc','var')
    load(SegmentSettingsLoc,'segmentParams')
    
    for r = 1:size(branches,2)
        root = [mainRoot,branches{r}];
        segmentAndSaveBatch(root,segmentParams)
    end
end

%% Feature extraction
if exist('FeatureSettingsLoc','var')
    load(FeatureSettingsLoc,'featSettings')
    
    for r = 1:size(branches,2)
        root = [mainRoot,branches{r}];
        extractFeatureEngineBatch(root,featSettings)
    end
end

%% Tracking
if exist('TrackSettingsLoc','var')
    load(TrackSettingsLoc,'trackSettings')
    
    for r = 1:size(branches,2)
        root = [mainRoot,branches{r}];
        runTrackingBatch(root,trackSettings)
    end
end

%% Division detection
if exist('DivisionSettingsLoc','var')
    load('DivisionSettingsLoc','divisionSettings')
    
    for r = 1:size(branches,2)
        root = [mainRoot,branches{r}];
        runDivisionsBatch(root,divisionSettings)
    end
end