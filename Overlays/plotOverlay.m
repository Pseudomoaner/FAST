function [] = plotOverlay(tracks,root,overlaySettings,colourmap,axHand,ownBar,debugSet)
%PLOTOVERLAY turns the user-selected options from the overlayTester GUI
%into an overlay for the currently selected image, and places it into the
%GUI's main axes.
%
%   INPUTS:
%       -tracks: Tracking data, typically procTracks from the Tracks.mat
%       file generated by the tracking module.
%       -root: String defining the location of the currently selected root
%       directory.
%       -overlaySettings: User-selected settings generated using the
%       overlayTester GUI.
%       -colourmap: Structure containing different colourmap data for
%       different data selection options. Specified when the overlayTester
%       GUI is initialised to permit persistence of colourmaps throughout
%       overlay setup.
%       -axHand: Handle to the axes into which you want the grayscale image
%       and its coloured overlay to be placed.
%       -ownBar: Whether this function should be responsible for its own
%       progress bar (single overlay), or is part of a larger batch processing
%       function which is handling its own progress bar.
%       -debugSet: Boolean specifying if we are currently in debug mode or
%       not.
%
%   Author: Oliver J. Meacock (c) 2019

if ownBar
    debugprogressbar(0,debugSet)
end

if strcmp(overlaySettings.info,'Data') %Implies that you want to plot data as the overlay - need to set up new global colourmap based on that data choice.
   minData = Inf;
   maxData = 0;
   for i = 1:size(tracks,2)
       if min(tracks(i).(overlaySettings.data)) < minData
           minData = min(tracks(i).(overlaySettings.data));
       end
       if max(tracks(i).(overlaySettings.data)) > maxData
           maxData = max(tracks(i).(overlaySettings.data));
       end
   end
end

cla(axHand)
ch=findall(axHand,'tag','Colorbar');
delete(ch);

%Start by plotting the selected underlay
underlayPath = [root,filesep,overlaySettings.underlay,filesep,sprintf('Frame_%04d.tif',overlaySettings.showFrame + overlaySettings.frameOffset)];
underlay = double(imread(underlayPath));
underlay = (underlay - min(underlay(:)))/(max(underlay(:)) - min(underlay(:)));
imagesc(underlay,'Parent',axHand);
colormap(axHand,'gray')
freezeColors(axHand);
axis(axHand,'equal')
axis(axHand,'off')
axLims = axis(axHand);

%Add data colourbar (if needed)
if strcmp(overlaySettings.info,'Data')
    cb = colorbar(axHand);
    colormap(axHand,overlaySettings.cmapName)
    cb.Label.String = overlaySettings.data;
    caxis(axHand,[minData,maxData]);
    cb.Limits = [minData,maxData];
    cb.FontSize = 15;
end

hold(axHand,'on')

%Do data overlay (if selected)
switch overlaySettings.type
    case 'None'
    case 'Masks'
        segRoot = [root,filesep,'Segmentations',filesep];
        switch overlaySettings.info
            case 'Raw'
                plotTrackedCellMaskOverlay(tracks,overlaySettings,colourmap.Raw,underlay,segRoot,axHand,[],[]);
            case 'Track IDs'
                plotTrackedCellMaskOverlay(tracks,overlaySettings,colourmap.ID,underlay,segRoot,axHand,[],[]);
            case 'Lineage'
                plotTrackedCellMaskOverlay(tracks,overlaySettings,colourmap.Lineage,underlay,segRoot,axHand,[],[]);
            case 'Data'
                plotTrackedCellMaskOverlay(tracks,overlaySettings,colourmap.ID,underlay,segRoot,axHand,minData,maxData);
        end
    case 'Ellipses'
        switch overlaySettings.info
            case 'Raw'
                plotTrackedCellEllipticalOverlay(tracks,overlaySettings,colourmap.Raw,axHand)
            case 'Track IDs'
                plotTrackedCellEllipticalOverlay(tracks,overlaySettings,colourmap.ID,axHand)
            case 'Lineage'
                plotTrackedCellEllipticalOverlay(tracks,overlaySettings,colourmap.Lineage,axHand)
            case 'Data'
                plotTrackedCellEllipticalOverlay(tracks,overlaySettings,colourmap,axHand,minData,maxData)
        end
    case 'Tracks'
        switch overlaySettings.info
            case 'Raw'
                plotAllInstantaneousTracks(tracks,overlaySettings,colourmap.Raw,axHand)
            case 'Track IDs'
                plotAllInstantaneousTracks(tracks,overlaySettings,colourmap.ID,axHand)
            case 'Lineage'
                plotAllInstantaneousTracks(tracks,overlaySettings,colourmap.Lineage,axHand)
            case 'Lineage trees'
                plotLineageTrees(tracks,overlaySettings,axHand)
            case 'Data'
                plotAllInstantaneousTracks(tracks,overlaySettings,colourmap,axHand,minData,maxData)
        end
    case 'Boundaries'
        segRoot = [root,filesep,'Segmentations',filesep];
        switch overlaySettings.info
            case 'Raw'
                plotTrackedCellBoundaryOverlay(tracks,overlaySettings,colourmap.Raw,underlay,segRoot,axHand,[],[])
            case 'Track IDs'
                plotTrackedCellBoundaryOverlay(tracks,overlaySettings,colourmap.ID,underlay,segRoot,axHand,[],[])
            case 'Lineage'
                plotTrackedCellBoundaryOverlay(tracks,overlaySettings,colourmap.Lineage,underlay,segRoot,axHand,[],[])
            case 'Data'
                plotTrackedCellBoundaryOverlay(tracks,overlaySettings,colourmap,underlay,segRoot,axHand,minData,maxData)
        end
end

%Do ID overlay (if selected)
if overlaySettings.IDshow == 1
    writeIDonImg(tracks,overlaySettings,axHand)
end

%Do event overlay (if selected)
if overlaySettings.eventShow == 1
    plotEvents(tracks,overlaySettings,axHand)
end
axis(axHand,axLims)

hold(axHand,'off')

if ownBar
    debugprogressbar(1,debugSet)
end