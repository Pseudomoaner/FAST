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
F1_autoCentTracks = zeros(size(branches));

ER_autoTracks = zeros(size(branches));
ER_autoCentTracks = zeros(size(branches));

trackabilityMean = zeros(size(branches));
trackabilityMeanCents = zeros(size(branches));
trackabilityList = [];
trackabilityListCents = [];

F1_AutoFrames = [];
F1_AutoFrames_Cents = [];

noCells_ManFrames = [];

for b = 1:size(branches,2)
    load(fullfile(root,branches{b},'Tracks_AutoSeg_Auto.mat'))
    autoSegAutoTracks = revertTrackFormat(rawFromMappings,rawToMappings);
    
    %Trackability for the fully auto path
    firstGoodInd = find(cellfun(@(x)size(x,1),trackableData.Centroid) > 32, 1);
    trackabilityList = [trackabilityList;linkStats.trackability(firstGoodInd:end)];
    trackabilityMean(b) = mean(linkStats.trackability(firstGoodInd:end));
    
    load(fullfile(root,branches{b},'Tracks_AutoSeg_Corrected.mat'))
    autoSegManualTracks = revertTrackFormat(rawFromMappings,rawToMappings);
    load(fullfile(root,branches{b},'Tracks_AutoSeg_Auto_CentroidsOnly.mat'))
    autoSegAutoCentTracks = revertTrackFormat(rawFromMappings,rawToMappings);
    
    [TP_Auto,FP_Auto,TN_Auto,FN_Auto] = scoreTrackQuality(autoSegAutoTracks,autoSegManualTracks,2);
    [TP_AutoCent,FP_AutoCent,TN_AutoCent,FN_AutoCent] = scoreTrackQuality(autoSegAutoCentTracks,autoSegManualTracks,2);
    
    F1_autoTracks(b) = (2*sum(TP_Auto))/(2*sum(TP_Auto) + sum(FN_Auto) + sum(FP_Auto));
    F1_autoCentTracks(b) = (2*sum(TP_AutoCent))/(2*sum(TP_AutoCent) + sum(FN_AutoCent) + sum(FP_AutoCent));
    
    F1_AutoFrames_Cents = [F1_AutoFrames_Cents;(TP_AutoCent(firstGoodInd:end)*2)./(TP_AutoCent(firstGoodInd:end)*2 + FP_AutoCent(firstGoodInd:end) + FN_AutoCent(firstGoodInd:end))];
    F1_AutoFrames = [F1_AutoFrames;(TP_Auto(firstGoodInd:end)*2)./(TP_Auto(firstGoodInd:end)*2 + FP_Auto(firstGoodInd:end) + FN_Auto(firstGoodInd:end))];
        
    %Trackability of the centroid-only analysis
    trackabilityListCents = [trackabilityListCents;linkStats.trackability(firstGoodInd:end)];
    trackabilityMeanCents(b) = mean(linkStats.trackability(firstGoodInd:end));
    
    %Comparison to manually corrected stream
    load(fullfile(root,branches{b},'Tracks_ManualSeg_Auto.mat'))
    manSegAutoTracks = revertTrackFormat(rawFromMappings,rawToMappings);
    load(fullfile(root,branches{b},'Tracks_ManualSeg_Corrected.mat'))
    manSegManualTracks = revertTrackFormat(rawFromMappings,rawToMappings);
    
    [TP_Man,FP_Man,TN_Man,FN_Man] = scoreTrackQuality(manSegAutoTracks,manSegManualTracks,2);
    
    F1_manTracks(b) = (2*sum(TP_Man))/(2*sum(TP_Man) + sum(FN_Man) + sum(FP_Man));
    
    %Number of cells over time from manually-curated segmentations    
    lenList = cellfun(@(x)size(x,1),trackableData.Centroid);
    noCells_ManFrames = [noCells_ManFrames;lenList(firstGoodInd:end-1)];
    
    %Error rate calculations (fraction correct) used to illustrate the
    %fold-improvement by including centroids.
    ER_autoTracks(b) = (sum(FN_Auto) + sum(FP_Auto))/(sum(FN_Auto) + sum(FP_Auto) + sum(TN_Auto) + sum(TP_Auto));
    ER_autoCentTracks(b) = (sum(FN_AutoCent) + sum(FP_AutoCent))/(sum(FN_AutoCent) + sum(FP_AutoCent) + sum(TN_AutoCent) + sum(TP_AutoCent));
end

%Part 3: Assess division detection quality
F1_autoDivs = zeros(size(branches));
F1_manDivs = (size(branches));
F1_autoDivsCents = zeros(size(branches));

ER_autoDivs = zeros(size(branches));
ER_autoDivsCents = zeros(size(branches));

for b = 1:size(branches,2)
    load(fullfile(root,branches{b},'Tracks_GoldStandardDivisions.mat'))
    manualTracks = procTracks;
    load(fullfile(root,branches{b},'Tracks_AutoStreamDivisions.mat'))
    autoTracks = procTracks;
    load(fullfile(root,branches{b},'Tracks_ManualStreamDivisions.mat'))
    correctedTracks = procTracks;
    load(fullfile(root,branches{b},'Tracks_AutoStreamDivisions_CentroidsOnly.mat'))
    centOnlyTracks = procTracks;
    
    [TP_Auto,FP_Auto,TN_Auto,FN_Auto] = scoreDivisionQuality(autoTracks,manualTracks);
    [TP_Man,FP_Man,TN_Man,FN_Man] = scoreDivisionQuality(correctedTracks,manualTracks);
    [TP_AutoCent,FP_AutoCent,TN_AutoCent,FN_AutoCent] = scoreDivisionQuality(centOnlyTracks,manualTracks);
    
    F1_manDivs(b) = (2*sum(TP_Man))/(2*sum(TP_Man) + sum(FN_Man) + sum(FP_Man));
    F1_autoDivs(b) = (2*sum(TP_Auto))/(2*sum(TP_Auto) + sum(FN_Auto) + sum(FP_Auto));
    F1_autoDivsCents(b) = (2*sum(TP_AutoCent))/(2*sum(TP_AutoCent) + sum(FN_AutoCent) + sum(FP_AutoCent));
    
    %Error rate calculations (fraction correct) used to illustrate the
    %fold-improvement by including centroids.
    ER_autoDivs(b) = (sum(FN_Auto) + sum(FP_Auto))/(sum(FN_Auto) + sum(FP_Auto) + sum(TN_Auto) + sum(TP_Auto));
    ER_autoDivsCents(b) = (sum(FN_AutoCent) + sum(FP_AutoCent))/(sum(FN_AutoCent) + sum(FP_AutoCent) + sum(TN_AutoCent) + sum(TP_AutoCent));
end

%Part 4: Assemble metrics on a single plot
figure('Units','Normalized','Position',[0.2,0.2,0.3,0.3])
hold on
ax=gca;

purp = [122,102,178]/255;
brn = [177,78,78]/255;
ms = 4;
F1_manDivs(F1_manDivs == 1) = 0.9999;
for i = 1:size(F1_autoTracks,2)
    plot(1,1-F1_Segmentations(i),'k^','MarkerSize',ms,'LineWidth',1)
    plot([2,3],1-[F1_manTracks(i),F1_autoTracks(i)],'Color',purp)
    plot([2,3],1-[F1_manTracks(i),F1_autoTracks(i)],'o','Color',purp,'MarkerFaceColor',purp,'MarkerSize',ms,'LineWidth',1)
%     plot([3,4],1-[F1_autoTracks(i),F1_manDivs(i)],'g')
    plot([4,5],1-[F1_manDivs(i),F1_autoDivs(i)],'Color',purp)
    plot([4,5],1-[F1_manDivs(i),F1_autoDivs(i)],'o','Color',purp,'MarkerFaceColor','w','MarkerSize',ms,'LineWidth',1)
end

%Highlight the displayed colony in panels a and b
plot(1,1-F1_Segmentations(1),'k^','MarkerSize',ms+1.5,'LineWidth',1)
plot([2,3],[1-F1_manTracks(1),1-F1_autoTracks(1)],'ko','MarkerSize',ms+1.5,'LineWidth',1)
plot([4,5],[1-F1_manDivs(1),1-F1_autoDivs(1)],'ko','MarkerSize',ms+1.5,'LineWidth',1)

axis([0.5,5.5,0.0001,1])
ax.YScale = 'log';
ax.YDir = 'reverse';
ax.Box = 'on';
ax.LineWidth = 1.5;

xticklabels({'Segmentation','Tracking (manual stream)','Tracking (auto stream)','Divisions (manual stream)','Divisions (auto stream)'})
ylabel('1 - F-score')


% %Part 5: Show relationship between tracking accuracy and trackability
% figure
% hold on
% ax = gca;
% 
% tbl_Track = table(trackabilityMean',log(1-F1_autoTracks)');
% mdl_Track = fitlm(tbl_Track,'Var2 ~ Var1');
% tbl_Div = table(trackabilityMean',log(1-F1_autoDivs)');
% mdl_Div = fitlm(tbl_Div,'Var2 ~ Var1');
% 
% plot(mdl_Track)
% plot(mdl_Div)
% 
% xlabel('Mean trackability (bits/object)')
% ylabel('log(1 - F-score)')

%Part 6: Show relationship between instantaneous number of cells and
%tracking accuracy
figure
subplot(1,2,1)
hold on
ax = gca;
plot(noCells_ManFrames,F1_AutoFrames,'o','Color',purp,'MarkerFaceColor',purp,'MarkerSize',ms-2)
plot(noCells_ManFrames,F1_AutoFrames_Cents,'o','Color',brn,'MarkerFaceColor',brn,'MarkerSize',ms-2)

%Plot trendlines through datasets
xCellNos = 32:200;
f = polyfit(noCells_ManFrames,F1_AutoFrames,1);
plot(xCellNos,polyval(f,xCellNos),'Color',purp,'LineWidth',1)
f = polyfit(noCells_ManFrames,F1_AutoFrames_Cents,1);
plot(xCellNos,polyval(f,xCellNos),'Color',brn,'LineWidth',1)

xlabel('Number of cells')
ylabel('F-score')
title('')
ax.Box = 'on';
ax.LineWidth = 1.5;
ylim([0.88,1])

%Part 7: Show relationship between instantaneous trackability and tracking
%accuracy
subplot(1,2,2)
hold on
ax = gca;
plot(trackabilityList,F1_AutoFrames,'o','Color',purp,'MarkerFaceColor',purp,'MarkerSize',ms-2)
plot(trackabilityListCents,F1_AutoFrames_Cents,'o','Color',brn,'MarkerFaceColor',brn,'MarkerSize',ms-2)

xAll = 3:0.1:9;
f = polyfit(trackabilityList,F1_AutoFrames,1);
plot(xAll,polyval(f,xAll),'Color',purp,'LineWidth',1)

xCent = 0:0.1:3;
f = polyfit(trackabilityListCents,F1_AutoFrames_Cents,1);
plot(xCent,polyval(f,xCent),'Color',brn,'LineWidth',1)

xlabel('Instantaneous trackability (bits/object)')
ylabel('F-score')
title('')
ax.Box = 'on';
ax.LineWidth = 1.5;
ylim([0.88,1])

%Part 8: Compare tracking performance with all features vs. just with
%centroid data
figure
hold on
ax = gca;
plot(trackabilityMeanCents,1-F1_autoCentTracks,'o','Color',brn,'MarkerFaceColor',brn,'MarkerSize',ms)
plot(10,median(1-F1_autoCentTracks),'o','Color',brn,'MarkerFaceColor',brn,'MarkerSize',ms);
plot(trackabilityMean,1-F1_autoTracks,'o','Color',purp,'MarkerFaceColor',purp,'MarkerSize',ms)
plot(10,median(1-F1_autoTracks),'o','Color',purp,'MarkerFaceColor',purp,'MarkerSize',ms);
plot(trackabilityMeanCents,1-F1_autoDivsCents,'o','Color',brn,'MarkerSize',ms,'LineWidth',1)
plot(10,median(1-F1_autoDivsCents),'o','Color',brn,'MarkerSize',ms,'LineWidth',1);
plot(trackabilityMean,1-F1_autoDivs,'o','Color',purp,'MarkerSize',ms,'LineWidth',1)
plot(10,median(1-F1_autoDivs),'o','Color',purp,'MarkerSize',ms,'LineWidth',1);

%Highlight the displayed colony in panels a and b
plot(trackabilityMeanCents(1),1-F1_autoCentTracks(1),'ko','MarkerSize',ms+1.5,'LineWidth',1)
plot(trackabilityMean(1),1-F1_autoTracks(1),'ko','MarkerSize',ms+1.5,'LineWidth',1)
plot(trackabilityMeanCents(1),1-F1_autoDivsCents(1),'ko','MarkerSize',ms+1.5,'LineWidth',1)
plot(trackabilityMean(1),1-F1_autoDivs(1),'ko','MarkerSize',ms+1.5,'LineWidth',1)

%Plot trendlines through datasets
xAll = 4:0.1:9;
f = fit(trackabilityMean',1-F1_autoTracks','exp1');
plot(xAll,f.a*exp(f.b*xAll),'Color',purp,'LineWidth',1)
f = fit(trackabilityMean',1-F1_autoDivs','exp1');
plot(xAll,f.a*exp(f.b*xAll),'Color',purp,'LineWidth',1)

xCent = 1:0.1:2.5;
f = fit(trackabilityMeanCents',1-F1_autoCentTracks','exp1');
plot(xCent,f.a*exp(f.b*xCent),'Color',brn,'LineWidth',1)
f = fit(trackabilityMeanCents',1-F1_autoDivsCents','exp1');
plot(xCent,f.a*exp(f.b*xCent),'Color',brn,'LineWidth',1)

ax.YScale = 'log';
ax.YDir = 'reverse';
ylabel('1 - F-score')
xlabel('Trackability (bits/object)')
ax.Box = 'on';
ax.LineWidth = 1.5;
axis([0,10,0.0001,1])