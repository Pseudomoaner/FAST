function handles = updateHomePanelButtons(src,evt,handles,rootdir)
%UPDATEHOMEPANELBUTTONS analyses the current state of the root directory 
%rootdir and activates/deactivates and recolours the buttons of the home 
%panel (pointers stored in handles) accordingly. 
%
%   INPUTS:
%       -src and evt: unused variables, required as inputs by Matlab's
%       callback system
%       -handles: Structure of handles pointing to (among other things) the
%       buttons on the home panel.
%       -rootdir: String indicating the user-selected home directory.
%
%   OUTPUTS:
%       -handles: handles structure with updated button states
%
%   Author: Oliver J. Meacock, (c) 2019

if exist([rootdir,filesep,'Channel_1'],'dir') && or(exist([rootdir,filesep,'Channel_1',filesep,'Frame_0001.tif'],'file'),exist([rootdir,filesep,'Channel_1',filesep,'Frame_0000.tif'],'file'))
    handles.SegPush.Enable = 'on';
    handles.SegPush.BackgroundColor = [0.7,1,0.7];
else
    handles.SegPush.Enable = 'off';
    handles.SegPush.BackgroundColor = [1,0.7,0.7];
end

if exist([rootdir,filesep,'Segmentations'],'dir') && or(exist([rootdir,filesep,'Segmentations',filesep,'Frame_0001.tif'],'file'),exist([rootdir,filesep,'Segmentations',filesep,'Frame_0000.tif'],'file'))
    handles.FeatPush.Enable = 'on';
    handles.FeatPush.BackgroundColor = [0.7,1,0.7];
else
    handles.FeatPush.Enable = 'off';
    handles.FeatPush.BackgroundColor = [1,0.7,0.7];
end

if exist([rootdir,filesep,'CellFeatures.mat'],'file') %also need to include condition that more than one frame exists in the dataset
    try
        load([rootdir,filesep,'CellFeatures.mat'],'trackableData')
        fieldNames = fieldnames(trackableData);
        
        if numel(trackableData.(fieldNames{1})) > 2
            handles.TrackPush.Enable = 'on';
            handles.TrackPush.BackgroundColor = [0.7,1,0.7];
        else
            handles.TrackPush.Enable = 'off';
            handles.TrackPush.BackgroundColor = [1,0.7,0.7];
        end
    catch
        wh = warndlg('CellFeatures.mat exists, but the trackableData variable could not be found in it. Try reprocessing?','trackableData not found');
        handles.TrackPush.Enable = 'off';
        handles.TrackPush.BackgroundColor = [1,0.7,0.7];
        uiwait(wh)
    end
else
    handles.TrackPush.Enable = 'off';
    handles.TrackPush.BackgroundColor = [1,0.7,0.7];
end

if exist([rootdir,filesep,'Tracks.mat'],'file')
    load([rootdir,filesep,'Tracks.mat'],'trackSettings')
    if trackSettings.minFrame ~= trackSettings.maxFrame %Only turn on division detection if there is more than one frame.
        handles.DivPush.Enable = 'on';
        handles.DivPush.BackgroundColor = [0.7,1,0.7];
    else
        handles.DivPush.Enable = 'off';
        handles.DivPush.BackgroundColor = [1,0.7,0.7];
    end
    handles.OverPush.Enable = 'on';
    handles.OverPush.BackgroundColor = [0.7,1,0.7];
    handles.PlotPush.Enable = 'on';
    handles.PlotPush.BackgroundColor = [0.7,1,0.7];
else
    handles.DivPush.Enable = 'off';
    handles.DivPush.BackgroundColor = [1,0.7,0.7];
    handles.OverPush.Enable = 'off';
    handles.OverPush.BackgroundColor = [1,0.7,0.7];
    handles.PlotPush.Enable = 'off';
    handles.PlotPush.BackgroundColor = [1,0.7,0.7];
end