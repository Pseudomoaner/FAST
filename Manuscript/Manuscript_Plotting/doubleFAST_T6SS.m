clear all
close all

%File choice
mainRoot = 'C:\Users\omeacock\Desktop\FAST_Datasets\T6SS\'; %Main directory in which all of your datasets is located
branches = {'SM6_2','SM7_1','SM7_2'}; %Names of subdirectories within main directory in which each separate dataset is stored
batchRoots = fullfile(mainRoot,branches);

%Filename of the unprocessed image data (Only need to define this if you are running from raw images)
imgName = 'Img.ome.tif';

%The following define the locations of the processing parameters,
%previously chosen through the FAST GUI. If any of these remain undefined,
%that portion of the processing will be skipped (can be useful if you only
%want to perform e.g. feature extraction without tracking).

%The location of the Metadata file output by the data import part of FAST
metadataLoc = 'C:\Users\omeacock\Desktop\FAST_Datasets\T6SS\SM6_1\Metadata.mat';

%The location of the SegmentationSettings file containning the settings
%used to perform segmentation
segmentSettingsLoc = 'C:\Users\omeacock\Desktop\FAST_Datasets\T6SS\SM6_1\SegmentationSettings.mat';

%The location of the featSettings file output following feature extraction
FeatureSettingsLoc = 'C:\Users\omeacock\Desktop\FAST_Datasets\T6SS\SM6_1\CellFeatures.mat';
 
%The location of the track data generated following the object tracking stages
TrackSettingsLoc = 'C:\Users\omeacock\Desktop\FAST_Datasets\T6SS\SM6_1\Tracks.mat';

%% Data import
if exist('MetadataLoc','var') && exist('imgName','var')
    load(MetadataLoc,'metaStore')
    
    for r = 1:size(branches,2)
        root = [mainRoot,branches{r}];
        importBioformatsDataBatch(root,imgName,metaStore)
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