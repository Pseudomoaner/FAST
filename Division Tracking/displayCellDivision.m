function divisionSettings = displayCellDivision(root,procTracks,divisionSettings,segmentChan,axHand)
%DISPLAYCELLDIVISION generates a visual representation of a given detected
%division event. The maternal cell in the event is coloured in yellow, the
%two daughters in magenta.
%
%   INPUTS:
%       -root: String defining the path to the currently selected root
%       directory. Directory must contain a 'Segmentations' folder, with
%       binary images named 'Frame_0000.tif', 'Frame_0001.tif' containing
%       segmentations of the images of the current dataset.
%       -procTracks: The output of the tracking module, saved within the
%       Tracks.mat file. Must contain D1 and D2 fields.
%       -divisionSettings: User-defined settings, generated using the
%       divisionTracker GUI.
%       -segmentChan: The channel index used to perform segmentations with.
%       Sets the channel that will be used in the underlay of the division
%       event reconstruction.
%       -axHand: Handle to axes into which this reconstruction should be
%       inserted.
%
%   OUTPUTS:
%       -divisionSettings: Updateed version of divisionSettings, containing
%       an updated ABstate field.
%
%   Author: Oliver J. Meacock (c) 2019

motherID = divisionSettings.showDiv;

D1ID = procTracks(motherID).D1;
D2ID = procTracks(motherID).D2;

oriFrame = procTracks(motherID).times(end);
if isempty(D1ID)
    tgtFrame = procTracks(D2ID).times(1);
    colVecs = repmat(rand(1,3),2,1);
elseif isempty(D2ID)
    tgtFrame = procTracks(D1ID).times(1);
    colVecs = repmat(rand(1,3),2,1);
else
    %Want that frame closest to the last frame of the mother cell in which both daughters are present
    bothDTs = intersect(procTracks(D1ID).times,procTracks(D2ID).times);
    [~,closestFrameInd] = min(abs(bothDTs-oriFrame));
    tgtFrame = bothDTs(closestFrameInd);
    colVecs = repmat(rand(1,3),3,1);
end

%Load segmentation and brightfield images
oriSegName = [root,filesep,'Segmentations',filesep,sprintf('Frame_%04d.tif',oriFrame-1)];
tgtSegName = [root,filesep,'Segmentations',filesep,sprintf('Frame_%04d.tif',tgtFrame-1)];
oriBFName = [root,filesep,'Channel_',num2str(segmentChan),filesep,sprintf('Frame_%04d.tif',oriFrame-1)];
tgtBFName = [root,filesep,'Channel_',num2str(segmentChan),filesep,sprintf('Frame_%04d.tif',tgtFrame-1)];
oriOutName = [root,filesep,'TestDivision_0001.tif'];
tgtOutName = [root,filesep,'TestDivision_0002.tif'];

oriImgPlane = -double(imread(oriBFName));
oriImgPlane = (oriImgPlane - min(oriImgPlane(:)))/(max(oriImgPlane(:))-min(oriImgPlane(:)));
oriImgPlane = repmat(oriImgPlane,[1,1,3]);

tgtImgPlane = -double(imread(tgtBFName));
tgtImgPlane = (tgtImgPlane - min(tgtImgPlane(:)))/(max(tgtImgPlane(:))-min(tgtImgPlane(:)));
tgtImgPlane = repmat(tgtImgPlane,[1,1,3]);

oriSeg = imread(oriSegName);
tgtSeg = imread(tgtSegName);

%Create a new data structure with only the mother data at the end of its track for frame 1 and only the daughter cells and their data at the start of their tracks for frame 2.
divData(1).x = procTracks(motherID).x(end);
divData(1).y = procTracks(motherID).y(end);
divData(1).times = 1;

indTog = 2;
if ~isempty(D1ID)
    D1TimeInd = find(procTracks(D1ID).times == tgtFrame);
    
    divData(2).x = procTracks(D1ID).x(D1TimeInd);
    divData(2).y = procTracks(D1ID).y(D1TimeInd);
    divData(2).times = 2;
    
    indTog = indTog+1;
end
if ~isempty(D2ID)
    D2TimeInd = find(procTracks(D2ID).times == tgtFrame);
    
    divData(indTog).x = procTracks(D2ID).x(D2TimeInd);
    divData(indTog).y = procTracks(D2ID).y(D2TimeInd);
    divData(indTog).times = 2;
end

imgOut = plotSegmentationOnPicture(oriSeg,oriImgPlane,divData,1,divisionSettings.pixSize,colVecs);
imwrite(imgOut,oriOutName)

imgOut = plotSegmentationOnPicture(tgtSeg,tgtImgPlane,divData,2,divisionSettings.pixSize,colVecs); 
imwrite(imgOut,tgtOutName)

imshow(imread(oriOutName),'Parent',axHand)
divisionSettings.ABstate = 1;