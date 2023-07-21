clear all
close all

%File choice
mainRoot = 'C:\Users\Olivier\Desktop\FAST_Benchmarking\VlietLineages\FAST_Efforts\'; %Main directory in which all of your datasets is located
branches = {'140408_01_cib','140408_02_cib','140408_09_cib','140408_10_cib','140408_11_cib','140409_03_cib','140415_08_cib','140415_13_cib'}; %Names of subdirectories within main directory in which each separate dataset is stored
batchRoots = fullfile(mainRoot,branches);

%The following define the locations of the processing parameters,
%previously chosen through the FAST GUI. If any of these remain undefined,
%that portion of the processing will be skipped (can be useful if you only
%want to perform e.g. feature extraction without tracking).
 
%The location of the segmentParams file saved following image segmentation
% SegmentSettingsLoc = 'C:\Users\Olivier\Desktop\FAST_Benchmarking\VlietLineages\FAST_Efforts\140408_01_cib\SegmentationSettings.mat';
 
%The location of the featSettings file output following feature extraction
% FeatureSettingsLoc = 'C:\Users\Olivier\Desktop\FAST_Benchmarking\VlietLineages\FAST_Efforts\140408_01_cib\CellFeatures.mat';
 
%The location of the track data generated following the object tracking stages
%TrackSettingsLoc = 'C:\Users\Olivier\Desktop\FAST_Benchmarking\VlietLineages\FAST_Efforts\140408_01_cib\Tracks_AutoSeg_Auto_CentroidsOnly.mat';
 
%The location of the track data with divisions detected
DivisionSettingsLoc = 'C:\Users\Olivier\Desktop\FAST_Benchmarking\VlietLineages\FAST_Efforts\140408_01_cib\Tracks_AutoStreamDivisions.mat';

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
        
        delete(fullfile(root,'CellFeatures.mat'))
        copyfile(fullfile(root,'CellFeatures_AutoSeg.mat'),fullfile(root,'CellFeatures.mat'))
        load(fullfile(root,'CellFeatures.mat'))
        trackSettings.maxFrame = size(trackableData.Centroid,1);
        runTrackingBatch(root,trackSettings)
        movefile(fullfile(root,'Tracks.mat'),fullfile(root,'Tracks_AutoSeg_Auto_CentroidsOnly.mat'))
    end
end

%% Division detection
if exist('DivisionSettingsLoc','var')
    load(DivisionSettingsLoc,'divisionSettings')
    
    for r = 1:size(branches,2)
        %We will run twice for the two benchmarking streams. Need to do some
        %supplementary filename things here for that reason
        root = [mainRoot,branches{r}];
        
        %Auto path
        copyfile(fullfile(root,'Tracks_AutoSeg_Auto.mat'),fullfile(root,'Tracks.mat'))
        runDivisionsBatch(root,divisionSettings)
        delete(fullfile(root,'Pre-division_Tracks.mat'))
        movefile(fullfile(root,'Tracks.mat'),fullfile(root,'Tracks_AutoStreamDivisions.mat'))
        
        %Manual path
%         copyfile(fullfile(root,'Tracks_ManualSeg_Corrected.mat'),fullfile(root,'Tracks.mat'))
%         runDivisionsBatch(root,divisionSettings)
%         delete(fullfile(root,'Pre-division_Tracks.mat'))
%         movefile(fullfile(root,'Tracks.mat'),fullfile(root,'Tracks_ManualStreamDivisions.mat'))
    end
end