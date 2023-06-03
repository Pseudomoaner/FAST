clear all
close all

root = 'C:\Users\Olivier\Desktop\FAST_Benchmarking\VlietLineages\FAST_Efforts';
branches = {'140408_01_cib','140408_02_cib','140408_09_cib','140408_10_cib','140408_11_cib','140409_03_cib','140415_08_cib','140415_13_cib'};

%Part 1: Assess segmentation quality
F1_Segmentations = zeros(size(branches));
for b = 1:size(branches,2)
    load(fullfile(root,branches{b},'CellFeatures_ManualSeg.mat'))
    
    noOversegs = zeros(size(trackableData.Centroid,1),1);
    noUndersegs = zeros(size(trackableData.Centroid,1),1);
    
    for t = 1:size(trackableData.Centroid,1)
        autoImg = imread(fullfile(root,branches{b},'Original_Segmentations',sprintf('Frame_%04d.tif',t-1)));
        manImg = imread(fullfile(root,branches{b},'Corrected_Segmentations',sprintf('Frame_%04d.tif',t-1)));
        
        %Oversegmentations will result in white regions present in the
        %manual image not present in the auto image
        overSegsRegs = and(logical(manImg),~logical(autoImg));
        overSegsLabels = bwlabel(overSegsRegs);
        noOversegs(t) = max(overSegsLabels(:));
        
        %Undersegmentations will result in black regions present in the
        %manual image not present in the auto image
        underSegsRegs = and(~logical(manImg),logical(autoImg));
        underSegsLabels = bwlabel(underSegsRegs);
        noUndersegs(t) = max(underSegsLabels(:));
    end
    
    totObjs = sum(cellfun(@(x)size(x,1),trackableData.Centroid));
    
    F1_Segmentations(b) = 2*totObjs/(2*totObjs + sum(noOversegs) + sum(noUndersegs));
end

%Part 2: Assess tracking quality
F1_autoTracks = zeros(size(branches));
F1_manTracks = zeros(size(branches));

trackabilityMean = zeros(size(branches));

F1_ManFrames = [];
noCells_ManFrames = [];

for b = 1:size(branches,2)
    load(fullfile(root,branches{b},'Tracks_AutoSeg_Auto.mat'))
    autoSegAutoTracks = revertTrackFormat(rawFromMappings,rawToMappings);
    load(fullfile(root,branches{b},'Tracks_AutoSeg_Corrected.mat'))
    autoSegManualTracks = revertTrackFormat(rawFromMappings,rawToMappings);
    
    [TP_Auto,FP_Auto,TN_Auto,FN_Auto] = scoreTrackQuality(autoSegAutoTracks,autoSegManualTracks,2);
    
    F1_autoTracks(b) = (2*sum(TP_Auto))/(2*sum(TP_Auto) + sum(FN_Auto) + sum(FP_Auto));
    
    load(fullfile(root,branches{b},'Tracks_ManualSeg_Auto.mat'))
    manSegAutoTracks = revertTrackFormat(rawFromMappings,rawToMappings);
    load(fullfile(root,branches{b},'Tracks_ManualSeg_Corrected.mat'))
    manSegManualTracks = revertTrackFormat(rawFromMappings,rawToMappings);
    
    [TP_Man,FP_Man,TN_Man,FN_Man] = scoreTrackQuality(manSegAutoTracks,manSegManualTracks,2);
    
    F1_manTracks(b) = (2*sum(TP_Man))/(2*sum(TP_Man) + sum(FN_Man) + sum(FP_Man));
    
    %Trackability analyses
    firstGoodInd = find(cellfun(@(x)size(x,1),trackableData.Centroid) > 32, 1);
    
    trackabilityMean(b) = mean(linkStats.trackability(firstGoodInd:end));
    
    F1_ManFrames = [F1_ManFrames;(TP_Man*2)./(TP_Man*2 + FP_Man + FN_Man)];
    lenList = cellfun(@(x)size(x,1),trackableData.Centroid);
    noCells_ManFrames = [noCells_ManFrames;lenList(1:end-1)];
end

%Part 3: Assess division detection quality

%Part 4: Assemble metrics on a single plot
figure
hold on
ax=gca;
for i = 1:size(F1_autoTracks,2)
    plot(1,1-F1_Segmentations(i),'r.')
    plot([2,3],1-[F1_manTracks(i),F1_autoTracks(i)],'r')
    plot([2,3],1-[F1_manTracks(i),F1_autoTracks(i)],'r.')
end

axis([0.5,3.5,0.0001,0.05])
ax.YScale = 'log';
ax.YDir = 'reverse';

%Part 5: Show relationship between tracking accuracy and trackability
figure
hold on
ax = gca;
plot(trackabilityMean,1-F1_manTracks,'r.')

axis([4,9,0.001,0.05])
ax.YScale = 'log';
ax.YDir = 'reverse';

%Part 6: Show relationship between instantaneous number of cells and
%tracking accuracy
figure
hold on
ax = gca;
plot(noCells_ManFrames(noCells_ManFrames > 2),F1_ManFrames(noCells_ManFrames > 2),'r.')
smoothY = polyfit(noCells_ManFrames(noCells_ManFrames > 2),F1_ManFrames(noCells_ManFrames > 2),2);
x = sort(noCells_ManFrames(noCells_ManFrames > 2));
plot(x,polyval(smoothY,x),'k')

ax.XScale = 'log';