clear all
close all

root = 'C:\Users\Olivier\Desktop\FAST_Benchmarking\VlietLineages\FAST_Efforts\140408_01_cib\';
trackLoc = [root,'Tracks_AutoStreamDivisions.mat'];
segRoot = [root,'Original_Segmentations\'];

splitGen = 3;
tgtMothers = [1];

startTime = 40;
midTime = 65;
endTime = 83;

imgLoc1 = [root,sprintf('Channel_1\\Frame_%04d.tif',startTime-1)];
underlay1 = double(imread(imgLoc1));
underlay1 = underlay1(:,:,1)/max(underlay1(:));
imgLoc2 = [root,sprintf('Channel_1\\Frame_%04d.tif',midTime-1)];
underlay2 = double(imread(imgLoc2));
underlay2 = underlay2(:,:,1)/max(underlay2(:));
imgLoc3 = [root,sprintf('Channel_1\\Frame_%04d.tif',endTime-1)];
underlay3 = double(imread(imgLoc3));
underlay3 = underlay3(:,:,1)/max(underlay3(:));

load(trackLoc)

figure(1)
axHand1 = gca;
figure(2)
axHand2 = gca;
figure(3)
axHand3 = gca;

%Shouldn't need to include most of these, but including from the outset to
%prevent unforseen bugs creeping in.
overlaySettings.pixSize = trackSettings.pixSize;
overlaySettings.maxX = size(underlay1,2);
overlaySettings.maxY = size(underlay1,1);
overlaySettings.frameOffset = 0;
overlaySettings.pseudoTracks = 0;
overlaySettings.cmapName = 'jet';
overlaySettings.eventShow = 0;
overlaySettings.IDshow = 0;
overlaySettings.underlay = 'Channel_1';
overlaySettings.type = 'Masks';
overlaySettings.info = 'Lineages';
overlaySettings.data = 'x';

%Set up the colours for the lineages
linCols = zeros(size(procTracks,2),3);
for i = 1:size(tgtMothers,2)
    tgtM = tgtMothers(i);
    [linInds,linLens] = getLineageIndices(procTracks,tgtM,1);
    splitMs = linInds(linLens == splitGen);
    
    for j = 1:size(splitMs,1)
        [newInds,~] = getLineageIndices(procTracks,splitMs(j),1);
        linCols(newInds,:) = repmat(rand(1,3),size(newInds,1),1);
    end
end

linCols = (round(linCols*254)+1)/255;

overlaySettings.showFrame = startTime-1;
im1 = plotTrackedCellMaskOverlay(procTracks,overlaySettings,linCols,underlay1,segRoot,axHand1,[],[]);
imwrite(im1,[root,sprintf('CutGen_%i_Start.tif',splitGen)])

overlaySettings.showFrame = midTime-1;
im2 = plotTrackedCellMaskOverlay(procTracks,overlaySettings,linCols,underlay2,segRoot,axHand2,[],[]);
imwrite(im2,[root,sprintf('CutGen_%i_Mid.tif',splitGen)])

overlaySettings.showFrame = endTime-1;
im3 = plotTrackedCellMaskOverlay(procTracks,overlaySettings,linCols,underlay3,segRoot,axHand3,[],[]);
imwrite(im3,[root,sprintf('CutGen_%i_End.tif',splitGen)])