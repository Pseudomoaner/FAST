%Classifies FAST tracks according to the fluoresence intensity measured in
%an initial and a final frame.
%
%Author: Oliver J. Meacock

clear all
close all

Root = 'D:\pilG_YFP_WT_CFP_Low_Density_Coculture';
trackLoc = [Root,filesep,'Tracks.mat']; %Location of your Tracks .mat file (containing procTracks)
startImgLoc = [Root,filesep,'PreSnap_YFP.tif']; %Location of the fluorescence image you took prior to timecourse imaging
endImgLoc = [Root,filesep,'PostSnap_YFP.tif']; %Location of the fluorescence image you took after timecourse imaging

load(trackLoc,'procTracks','trackSettings')

imgInfo = imfinfo(startImgLoc);
pixelSize = 1/imgInfo.XResolution; %As some upsampling may have occured during FAST processing, best to use resolution of fluoresence image

prePlane = double(imread(startImgLoc,'Index',1));
postPlane = double(imread(endImgLoc,'Index',1));

meanFluo = nan(size(procTracks,2),1);

%For each track...
for i = 1:length(procTracks)
    %If this track is present at the initial timepoint
    if procTracks(i).times(1) == 1
        [meanFluo(i),~] = meanIntInEllipse(prePlane,procTracks(i),1,pixelSize);
    elseif procTracks(i).times(end) == trackSettings.maxF
        [meanFluo(i),~] = meanIntInEllipse(postPlane,procTracks(i),size(procTracks(i).times,1),pixelSize);
    end
end

%Fit Gaussian mixture model of average intensities within ellipses to
%find threshold to split fluorescent from non-fluorescent cells
model = fitgmdist(meanFluo,2);
idx = cluster(model,meanFluo);

for i = 1:length(procTracks)
    if isnan(idx(i))
        procTracks(i).population = 3;
    elseif idx(i) == 1
        procTracks(i).population = 1;
    elseif idx(i) == 2
        procTracks(i).population = 2;
    end
end

save(trackLoc,'procTracks','-append')