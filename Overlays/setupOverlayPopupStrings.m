function [infoPopups,dataPopups,overlayPopups,underlayPopups] = setupOverlayPopupStrings(tracks,overlaySettings,root)
%SETUPOVERLAYPOPUPSTRINGS specifies which strings should be available in
%the popup menus of the overlay GUI, based on the data fields available in
%the track data, whether the data consists of tracks or individual frames
%and the channels that have been extracted.
%
%For example, only allows the 'Ellipses' option to be chosen if sufficient
%morphological features (major length, minor length, position, angle, velocity) have been
%extracted in  earlier stages. Similarly, only allows the 'Tracks' option
%to be chosen if the data has been tracked.
%
%   INPUTS:
%       -tracks: track data
%       -overlaySettings: settings specifying properties of the overlay
%       -root: root directory path
%
%   OUTPUTS:
%       -infoPopups: strings for the 'information overlayed' popup box
%       -dataPopups: strings for the 'data selection' popup box
%       -overlayPopups: strings for the 'overlay type' popup box
%       -underlayPopups: strings for the 'underlay source' popup box
%
%   Author: Oliver J. Meacock (c) 2019

%Underlay settings
rootDirs = dir(root);
underlayPopups = {};
segmented = false;
for i = 1:size(rootDirs,1)
    if rootDirs(i).isdir
        chanRoot = regexp(rootDirs(i).name,'Channel_\d','ONCE');
        if ~isempty(chanRoot)
            underlayPopups = [underlayPopups;rootDirs(i).name];
        end
        if strcmp(rootDirs(i).name,'Segmentations')
            segmented = true;
            underlayPopups = [underlayPopups;'Segmentations'];
        end
    end
end

if isempty(underlayPopups)
    warndlg('No underlay directory could be found!')
end

%Overlay type settings
overlayPopups = {'None'};
if isfield(tracks,'x') && isfield(tracks,'y') && ~overlaySettings.pseudoTracks
    overlayPopups = [overlayPopups;'Tracks'];
end
if isfield(tracks,'x') && isfield(tracks,'y') && isfield(tracks,'minorLen') && isfield(tracks,'majorLen') && isfield(tracks,'phi') && isfield(tracks,'theta') && isfield(tracks,'vmag')
    overlayPopups = [overlayPopups;'Ellipses'];
end
if isfield(tracks,'x') && isfield(tracks,'y') && segmented
    overlayPopups = [overlayPopups;'Masks';'Boundaries'];
end

%Overlay information types
infoPopups = {'Raw','Track IDs','Data'};
if isfield(tracks,'D1')
    infoPopups = [infoPopups,'Lineage'];
    
end

%Data overlay names
trackNames = fieldnames(tracks);

%Convert population field to a vector the same size as the track, to allow
%plotting as a datafield.
if isfield(tracks,'population')
    for i = 1:size(tracks,2)
        tracks(i).population = ones(size(tracks(i).x))*tracks(i).population;
    end
end

if overlaySettings.pseudoTracks
    minLen = 1;
    minLenInd = 1;
else %Find the index of the first track that is long enough to be included
    minLen = 5;
    minLenInd = [];
    for i = 1:size(tracks,2)
        if minLen < size(tracks(i).x,1)-1
            minLenInd = i;
            break
        end
    end
end

dataPopups = {};
if isempty(minLenInd)
    warndlg('No track long enough for data plotting! No options will be available in the ''Data selection'' field.')
else
    for i = 1:size(trackNames,1)
        if size(tracks(minLenInd).(trackNames{i}),1) >= minLen %Ensures that any whole-track measures (e.g. average speed) are discounted.
            dataPopups = [dataPopups;trackNames{i}];
        end
    end
end