function [handles,divisionSettings] = setupDivisionCheckboxes(handles,procTracks,trackSettings)
%SETUPDIVISIONCHECKBOXES ensures that only those features that have
%sufficient data in the procTracks data structure are available for use by
%the division detection algorithm.
%
%   INPUTS:
%       -handles: Handles to the various bits of the division detection
%       GUI.
%       -procTracks: The track data strucutre, produced by the tracking 
%       module and stored in Tracks.mat. 
%       -trackSettings: Settings used to generate procTracks by the
%       tracking module.
%
%   OUTPUTS:
%       -handles: Same as input, with various feature checkboxes activated
%       and deactivated as needed
%       -divisionSettings: Settings that get will be used to perform
%       model training and division detection.
%
%   Author: Oliver J. Meacock, (c) 2020

%This is a hacky bit of code that figures out which features you need as
%inputs to use each feature as a division predictor (e.g. position
%typically needs position, length and orientation to know where daughter
%cells will end up).
dummySettings = struct();
if isfield(procTracks,'x') && isfield(procTracks,'y')
    dummySettings.Centroid = 1;
    dummySettings.Velocity = 1;
else
    dummySettings.Centroid = 0;
    dummySettings.Velocity = 0;
end
if isfield(procTracks,'majorLen')
    dummySettings.Length = 1;
else
    dummySettings.Length = 0;
end
if isfield(procTracks,'area')
    dummySettings.Area = 1;
else
    dummySettings.Area = 0;
end
if isfield(procTracks,'minorLen')
    dummySettings.Width = 1;
else
    dummySettings.Width = 0;
end
if isfield(procTracks,'phi')
    dummySettings.Orientation = 1;
else
    dummySettings.Orientation = 0;
end
if trackSettings.noChannels > 0
    dummySettings.noChannels = trackSettings.noChannels;
    dummySettings.availableMeans = trackSettings.availableMeans;
    dummySettings.availableStds = trackSettings.availableStds;
    dummySettings.MeanInc = trackSettings.availableMeans;
    dummySettings.StdInc = trackSettings.availableStds;
else
    dummySettings.noChannels = 0;
    dummySettings.availableMeans = [];
    dummySettings.availableStds = [];
    dummySettings.MeanInc = [];
    dummySettings.StdInc = [];
end
if isfield(procTracks,'sparefeat1')
    dummySettings.SpareFeat1 = 1;
else
    dummySettings.SpareFeat1 = 0;
end
if isfield(procTracks,'sparefeat2')
    dummySettings.SpareFeat2 = 1;
else
    dummySettings.SpareFeat2 = 0;
end
if isfield(procTracks,'sparefeat3')
    dummySettings.SpareFeat3 = 1;
else
    dummySettings.SpareFeat3 = 0;
end
if isfield(procTracks,'sparefeat4')
    dummySettings.SpareFeat4 = 1;
else
    dummySettings.SpareFeat4 = 0;
end

dummyDivStruct = prepareDivStruct(dummySettings);

%This 'dummyDivStruct' contains information about the fields of procTracks that *would*
%be needed, if each feature was selected. If these fields *are* available,
%actually make the feature selectable.

%Centroid
incPos = true;
if isfield(dummyDivStruct,'x') && isfield(dummyDivStruct,'y')
    for i = 1:size(dummyDivStruct.x.divArguments,2)
        if ~isfield(procTracks,dummyDivStruct.x.divArguments{i})
            incPos = false;
        end
    end
else
    incPos = false;
end

if incPos
    handles.checkbox9.Enable = 'on';
    handles.checkbox9.Value = 1;
    divisionSettings.Centroid = 1;
else
    divisionSettings.Centroid = 0;
end

%Velocity
incVel = true;
if isfield(dummyDivStruct,'vmag')
    for i = 1:size(dummyDivStruct.vmag.divArguments,2)
        if ~isfield(procTracks,dummyDivStruct.vmag.divArguments{i})
            incVel = false;
        end
    end
else
    incVel = false;
end

if incVel
    handles.checkbox7.Enable = 'on';
    handles.checkbox7.Value = 0;
    divisionSettings.Velocity = 0;
else
    divisionSettings.Velocity = 0;
end

%Length
incLen = true;
if isfield(dummyDivStruct,'majorLen')
    for i = 1:size(dummyDivStruct.majorLen.divArguments,2)
        if ~isfield(procTracks,dummyDivStruct.majorLen.divArguments{i})
            incLen = false;
        end
    end
else
    incLen = false;
end

if incLen
    handles.checkbox1.Enable = 'on';
    handles.checkbox1.Value = 0;
    divisionSettings.Length = 0;
else
    divisionSettings.Length = 0;
end

%Area
incArea = true;
if isfield(dummyDivStruct,'area')
    for i = 1:size(dummyDivStruct.area.divArguments,2)
        if ~isfield(procTracks,dummyDivStruct.area.divArguments{i})
            incArea = false;
        end
    end
else
    incArea = false;
end

if incArea
    handles.checkbox2.Enable = 'on';
    handles.checkbox2.Value = 0;
    divisionSettings.Area = 0;
else
    divisionSettings.Area = 0;
end

%Width
incWidth = true;
if isfield(dummyDivStruct,'minorLen')
    for i = 1:size(dummyDivStruct.minorLen.divArguments,2)
        if ~isfield(procTracks,dummyDivStruct.minorLen.divArguments{i})
            incWidth = false;
        end
    end
else
    incWidth = false;
end

if incWidth
    handles.checkbox3.Enable = 'on';
    handles.checkbox3.Value = 0;
    divisionSettings.Width = 0;
else
    divisionSettings.Width = 0;
end

%Orientation
incOri = true;
if isfield(dummyDivStruct,'phi')
    for i = 1:size(dummyDivStruct.phi.divArguments,2)
        if ~isfield(procTracks,dummyDivStruct.phi.divArguments{i})
            incOri = false;
        end
    end
else
    incOri = false;
end

if incOri
    handles.checkbox6.Enable = 'on';
    handles.checkbox6.Value = 0;
    divisionSettings.Orientation = 0;
else
    divisionSettings.Orientation = 0;
end

%Channels
if trackSettings.noChannels > 0
    handles.pushbutton7.Enable = 'on';
    divisionSettings.noChannels = trackSettings.noChannels;
    divisionSettings.availableMeans = trackSettings.availableMeans;
    divisionSettings.availableStds = trackSettings.availableStds;
else
    divisionSettings.noChannels = 0;
    divisionSettings.availableMeans = [];
    divisionSettings.availableStds = [];
end
divisionSettings.MeanInc = [];
divisionSettings.StdInc = [];

%Spare feature 1
incSF1 = true;
if isfield(dummyDivStruct,'sparefeat1')
    for i = 1:size(dummyDivStruct.sparefeat1.divArguments,2)
        if ~isfield(procTracks,dummyDivStruct.sparefeat1.divArguments{i})
            incSF1 = false;
        end
    end
else
    incSF1 = false;
end

if incSF1
    handles.checkbox8.Enable = 'on';
    handles.checkbox8.Value = 0;
    divisionSettings.SpareFeat1 = 0;
else
    divisionSettings.SpareFeat1 = 0;
end

%Spare feature 2
incSF2 = true;
if isfield(dummyDivStruct,'sparefeat2')
    for i = 1:size(dummyDivStruct.sparefeat2.divArguments,2)
        if ~isfield(procTracks,dummyDivStruct.sparefeat2.divArguments{i})
            incSF2 = false;
        end
    end
else
    incSF2 = false;
end

if incSF2
    handles.checkbox10.Enable = 'on';
    handles.checkbox10.Value = 0;
    divisionSettings.SpareFeat2 = 0;
else
    divisionSettings.SpareFeat2 = 0;
end

%Spare feature 3
incSF3 = true;
if isfield(dummyDivStruct,'sparefeat3')
    for i = 1:size(dummyDivStruct.sparefeat3.divArguments,2)
        if ~isfield(procTracks,dummyDivStruct.sparefeat3.divArguments{i})
            incSF3 = false;
        end
    end
else
    incSF3 = false;
end

if incSF3
    handles.checkbox11.Enable = 'on';
    handles.checkbox11.Value = 0;
    divisionSettings.SpareFeat3 = 0;
else
    divisionSettings.SpareFeat3 = 0;
end
   
%Spare feature 4
incSF4 = true;
if isfield(dummyDivStruct,'sparefeat4')
    for i = 1:size(dummyDivStruct.sparefeat4.divArguments,2)
        if ~isfield(procTracks,dummyDivStruct.sparefeat4.divArguments{i})
            incSF4 = false;
        end
    end
else
    incSF4 = false;
end

if incSF4
    handles.checkbox12.Enable = 'on';
    handles.checkbox12.Value = 0;
    divisionSettings.SpareFeat4 = 0;
else
    divisionSettings.SpareFeat4 = 0;
end