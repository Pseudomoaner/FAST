function segDat = updateSegmentationStorage(segDat,oldFrame,GUIsets)
%UPDATESEGMENTATIONSTORAGE updates the segDat variable, efficiently loading
%only those segmentation images that are not already within the segDat
%dataset.
%
%   INPUTS:
%       -segDat: The old segDat structure, containing the fields frames
%       (the labelled images of the system at the n timepoints in front of
%       the currently chosen frame) and stats (the regionprops output of
%       the binary images
%       -oldFrame: The frame that used to be the first frame in the segDat
%       structure.
%       -GUIsets: The settings from the GUI, including new frames and directory root. 
%
%   OUTPUTS:
%       -segDat: The updated version of the segDat structure.
%
%   Author: Oliver J. Meacock, (c) 2019

newLook = min(GUIsets.maxF - GUIsets.frame + 1,GUIsets.forLook);

fmTmp = {};
stTmp = {};
for i = 1:newLook
    segPath = [GUIsets.root,filesep,'Segmentations',filesep,sprintf('Frame_%04d.tif',GUIsets.frame+i-2)];
    seg = imread(segPath);
    fmTmp{i} = bwlabeln(seg,8);
    stTmp{i} = regionprops(fmTmp{i},'Centroid','PixelIdxList');
end

segDat.frames = fmTmp;
segDat.stats = stTmp;

%Urgh, getting the indexing to work properly is a friggin' nightmare.
%Tedious AND difficult you say? And supremely finikity? I've decided to
%abandon the attempt for the time being, and will just load all the
%segmentations every time. Might make the GUI a bit laggy, but hopefully
%should be a minor enough effect. The old code is commented below:

% oldLook = min(GUIsets.maxF - oldFrame + 1,GUIsets.forLook);
% newLook = min(GUIsets.maxF - GUIsets.frame + 1,GUIsets.forLook);
% 
% if oldFrame < GUIsets.frame %Need to trim off bits from start of segDat and add to the end
%     if oldFrame + oldLook > GUIsets.frame %Use some unpleasant indexing to save a bit of loading if you can actually do so
%         %Trim out unneccessary bits of data
%         segDat.frames(1:min(GUIsets.frame-oldFrame,size(segDat.frames,1))) = [];
%         segDat.stats(1:min(GUIsets.frame-oldFrame,size(segDat.stats,1))) = [];
%         
%         fmTmp = {};
%         stTmp = {};
%         for i = 1:(GUIsets.frame+newLook)-(oldFrame+oldLook)
%             %Add new bits of data
%             segPath = [GUIsets.root,filesep,'Segmentations',filesep,sprintf('frame_%04d.tif',oldFrame+oldLook+i-3)];
%             seg = imread(segPath);
%             fmTmp{i} = bwlabeln(seg,8);
%             stTmp{i} = regionprops(fmTmp{i},'Centroid','PixelIdxList');
%         end
%         
%         %Concatenate arrays
%         segDat.frames = [segDat.frames;fmTmp];
%         segDat.stats = [segDat.stats;stTmp];
%     else %Otherwise just delete all the old data and load all the new data. Less to go wrong by using this.
%         fmTmp = {};
%         stTmp = {};
%         for i = 1:newLook
%             segPath = [GUIsets.root,filesep,'Segmentations',filesep,sprintf('frame_%04d.tif',GUIsets.frame+i-2)];
%             seg = imread(segPath);
%             fmTmp{i} = bwlabeln(seg,8);
%             stTmp{i} = regionprops(fmTmp{i},'Centroid','PixelIdxList');
%         end
%         
%         segDat.frames = fmTmp;
%         segDat.stats = stTmp;
%     end
% elseif oldFrame > GUIsets.frame %Need to trim off bits from end of segDat and add to the start
%     %Trim out unneccessary bits of data
%     endDiff = (oldFrame+oldLook)-(GUIsets.frame+newLook);
%     segDat.frames(max(1,size(segDat.frames,1)-endDiff+1):end) = [];
%     segDat.stats(max(1,size(segDat.stats,1)-endDiff+1):end) = [];
%     
%     fmTmp = {};
%     stTmp = {};
%     for i = 1:endDiff
%         %Add new bits of data
%         segPath = [GUIsets.root,filesep,'Segmentations',filesep,sprintf('frame_%04d.tif',GUIsets.frame+i-2)];
%         seg = imread(segPath);
%         fmTmp{i} = bwlabeln(seg,8);
%         stTmp{i} = regionprops(fmTmp{i},'Centroid','PixelIdxList');
%     end
%     
%     %Concatenate arrays
%     segDat.frames = [fmTmp;segDat.frames];
%     segDat.stats = [stTmp;segDat.stats];
% end