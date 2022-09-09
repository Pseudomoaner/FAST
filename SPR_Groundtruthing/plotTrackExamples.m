%Script that plots either just the positions or the positions plus the
%length, orientation and intensity of rods of an SPR simulation. Intended
%to illustrate the different amounts of information available to the
%centroid-only and all-feature versions of the tracking algorithm.

clear all
close all

inputData = 'C:\Users\olijm\Desktop\SPRfastTest\PlottableSim.mat';
inputFrame = 'C:\Users\olijm\Desktop\SPRfastTest\ColourCells\Frame_0002.tif';
load(inputData)
imgFrame = imread(inputFrame);
imgFrame = double(imgFrame(:,:,1));

noPlotFrames = 4;
simUsed = 1; %Index of the simulation in the specified set of simulations you want to present
viewLims = [34.4,42.4,72,80];
pxSize = 1/25;
lkLineWidth = 3.5;
nodeSize = 20;
recLineWidth = 5;

figDims = [0.2,0.2];

cmap = colormap('winter');
noCs = size(cmap,1);
cmapSml = cmap(round(linspace(1,noCs,noPlotFrames)),:);

%Figure 1 will be just the centroids of the rods. Figure 2 will be
%centroids + length + orientation + fluo intensity
fig1 = figure(1);
fig1.Units = 'Normalized';
fig1.Position = [0.1,0.1,figDims(1),figDims(2)];
fig1.Renderer='Painters';
hold on
rectangle('Position',[0,0,100,100],'FaceColor','k')

fig2 = figure(2);
fig2.Units = 'Normalized';
fig2.Position = [0.1,0.1 + figDims(2),figDims(1),figDims(2)];
fig2.Renderer='Painters';
hold on
rectangle('Position',[0,0,100,100],'FaceColor','k')

for i = 1:noPlotFrames
    centCol = cmapSml(i,:);
    
    figure(1)
    plot(measuredTruth{simUsed}.trackableData.Centroid{i}(:,1),measuredTruth{simUsed}.trackableData.Centroid{i}(:,2),'.','Color','w','MarkerSize',nodeSize+5)
    plot(measuredTruth{simUsed}.trackableData.Centroid{i}(:,1),measuredTruth{simUsed}.trackableData.Centroid{i}(:,2),'.','Color',centCol,'MarkerSize',nodeSize)
    
    figure(2)
    for j = 1:size(measuredTruth{simUsed}.trackableData.Length{i},1)
        currOri = -measuredTruth{simUsed}.trackableData.Orientation{i}(j);
        currX = measuredTruth{simUsed}.trackableData.Centroid{i}(j,1);
        currY = measuredTruth{simUsed}.trackableData.Centroid{i}(j,2);
        currLen = measuredTruth{simUsed}.trackableData.Length{i}(j)/2;
        currInt = measuredTruth{simUsed}.trackableData.ChannelMean{i}(j,1)+0.2;
        
        if currInt < 0
            currInt = 0;
        elseif currInt > 1
            currInt = 1;
        end
        
        startPos = [currX + cos(currOri)*currLen/2, currY + sin(currOri)*currLen/2];        
        endPos = [currX - cos(currOri)*currLen/2, currY - sin(currOri)*currLen/2];
        
        plot([startPos(1),endPos(1)],[startPos(2),endPos(2)],'LineWidth',recLineWidth,'Color',ones(1,3)*currInt)
    end
    plot(measuredTruth{simUsed}.trackableData.Centroid{i}(:,1),measuredTruth{simUsed}.trackableData.Centroid{i}(:,2),'.','Color','w','MarkerSize',nodeSize+5)
    plot(measuredTruth{simUsed}.trackableData.Centroid{i}(:,1),measuredTruth{simUsed}.trackableData.Centroid{i}(:,2),'.','Color',centCol,'MarkerSize',nodeSize)
end

figure(1)
ax1 = gca;
axis equal
axis(ax1,viewLims)
ax1.LineWidth = 1.5;
ax1.Box = 'on';
ax1.XTick = [];
ax1.YTick = [];

figure(2)
ax2 = gca;
axis equal
axis(ax2,viewLims)
ax2.LineWidth = 1.5;
ax2.Box = 'on';
ax2.XTick = [];
ax2.YTick = [];

%Figure 3 will be the ground truth data
fig3 = figure(3);
fig3.Units = 'Normalized';
fig3.Position = [0.1 + figDims(1),0.1,figDims(1),figDims(2)];
fig3.Renderer='Painters';

imagesc(-imgFrame)
colormap('gray')
hold on
for i = 1:size(groundTruth{simUsed}.data,2)
    for j = 1:size(groundTruth{simUsed}.data(i).x,1)-1
        currT = groundTruth{simUsed}.data(i).times(j);
        currX = groundTruth{simUsed}.data(i).x(j)/pxSize;
        currY = groundTruth{simUsed}.data(i).y(j)/pxSize;
        nextX = groundTruth{simUsed}.data(i).x(j+1)/pxSize;
        nextY = groundTruth{simUsed}.data(i).y(j+1)/pxSize;
        
        if currT <= noPlotFrames
            lineCol = cmapSml(currT,:);
        end
        
        if currT < noPlotFrames
            plot([currX,nextX],[currY,nextY],'LineWidth',lkLineWidth+1.5,'Color','w')
            plot([currX,nextX],[currY,nextY],'LineWidth',lkLineWidth,'Color',lineCol)
        end
        
        if currT <= noPlotFrames
            plot(currX,currY,'.','MarkerSize',nodeSize+5,'Color','w')
            plot(currX,currY,'.','MarkerSize',nodeSize,'Color',lineCol)
        end
    end
end

figure(3)
ax3 = gca;
ax3.YDir = 'normal';
axis equal
axis(ax3,viewLims/pxSize)
ax3.LineWidth = 1.5;
ax3.Box = 'on';
ax3.XTick = [];
ax3.YTick = [];

%Figures 4 and 5 will be the same as 1 and 2, but with automatic track
%reconstructions overlaid

%Track settings
procSettingsCent.fieldWidth = 100;
procSettingsCent.fieldHeight = 100;
procSettingsCent.pixSize = 1/25;
procSettingsCent.incProp = 0.75; %Inclusion proportion for the model training stage of the defect tracking
procSettingsCent.minTrackLength = 1;
procSettingsCent.gapWidth = 1;
procSettingsCent.statsUse = 'Centroid';

procSettingsCent.Centroid = true;
procSettingsCent.Length = false;
procSettingsCent.Width = false;
procSettingsCent.Orientation = false;
procSettingsCent.noChannels = 3;
procSettingsCent.availableMeans = 1:3;
procSettingsCent.availableStds = 1:3;
procSettingsCent.meanInc = [];
procSettingsCent.stdInc = [];
procSettingsCent.Area = false;
procSettingsCent.tgtDensity = 10;

% [procTracks,fromMappings,toMappings,trackSettings,linkStats,Tracks]
[procTracksCent,~,~,~,linkStatsCent,TracksCent] = trackRodsFAST(measuredTruth{simUsed}.trackableData,procSettingsCent,simSettings.dt);

procSettingsAll = procSettingsCent;
procSettingsAll.Length = true;
procSettingsAll.meanInc = logical([1,0,0]);
procSettingsAll.Orientation = true;
procSettingsAll.tgtDensity = 0.1;

[procTracksAll,~,~,~,linkStatsAll,TracksAll] = trackRodsFAST(measuredTruth{simUsed}.trackableData,procSettingsAll,simSettings.dt);

fig4 = figure(4);
fig4.Units = 'Normalized';
fig4.Position = [0.1 + figDims(1),0.1 + figDims(2),figDims(1),figDims(2)];
fig4.Renderer='Painters';
hold on
rectangle('Position',[0,0,100,100],'FaceColor','k')

for i = 1:size(procTracksCent,2)
    for j = 1:size(procTracksCent(i).x,1)-1
        currT = procTracksCent(i).times(j);
        currX = procTracksCent(i).x(j);
        currY = procTracksCent(i).y(j);
        nextX = procTracksCent(i).x(j+1);
        nextY = procTracksCent(i).y(j+1);
        
        if currT <= noPlotFrames
            lineCol = cmapSml(currT,:);
        end
        
        if currT < noPlotFrames
            plot([currX,nextX],[currY,nextY],'LineWidth',lkLineWidth+1.5,'Color','w')
            plot([currX,nextX],[currY,nextY],'LineWidth',lkLineWidth,'Color',lineCol)
        end
        
        if currT <= noPlotFrames
            plot(currX,currY,'.','MarkerSize',nodeSize+5,'Color','w')
            plot(currX,currY,'.','MarkerSize',nodeSize,'Color',lineCol)
        end
    end
end

fig5 = figure(5);
fig5.Units = 'Normalized';
fig5.Position = [0.1+figDims(1)*2,0.1,figDims(1),figDims(2)];
fig5.Renderer='Painters';
hold on
rectangle('Position',[0,0,100,100],'FaceColor','k')

for i = 1:size(procTracksAll,2)
    for j = 1:size(procTracksAll(i).x,1)-1
        currT = procTracksAll(i).times(j);
        currX = procTracksAll(i).x(j);
        currY = procTracksAll(i).y(j);
        nextX = procTracksAll(i).x(j+1);
        nextY = procTracksAll(i).y(j+1);
        
        currLen = procTracksAll(i).majorLen(j)/2;
        currOri = -procTracksAll(i).phi(j);
        currInt = procTracksAll(i).channel_1_mean(j)+0.2;
        
        if currInt < 0
            currInt = 0;
        elseif currInt > 1
            currInt = 1;
        end
        
        if currT <= noPlotFrames
            lineCol = cmapSml(currT,:);
        end
        
        if currT <= noPlotFrames
            startPos = [currX + cos(currOri)*currLen/2, currY + sin(currOri)*currLen/2];
            endPos = [currX - cos(currOri)*currLen/2, currY - sin(currOri)*currLen/2];
            
            plot([startPos(1),endPos(1)],[startPos(2),endPos(2)],'LineWidth',recLineWidth,'Color',ones(1,3)*currInt)
        end
    end
end
   
for i = 1:size(procTracksAll,2)
    for j = 1:size(procTracksAll(i).x,1)-1
        currT = procTracksAll(i).times(j);
        currX = procTracksAll(i).x(j);
        currY = procTracksAll(i).y(j);
        nextX = procTracksAll(i).x(j+1);
        nextY = procTracksAll(i).y(j+1);
        
        if currT <= noPlotFrames
            lineCol = cmapSml(currT,:);
        end
        
        if currT < noPlotFrames
            plot([currX,nextX],[currY,nextY],'LineWidth',lkLineWidth+1.5,'Color','w')
            plot([currX,nextX],[currY,nextY],'LineWidth',lkLineWidth,'Color',lineCol)
        end
        
        if currT <= noPlotFrames
            plot(currX,currY,'.','MarkerSize',nodeSize+5,'Color','w')
            plot(currX,currY,'.','MarkerSize',nodeSize,'Color',lineCol)
        end
    end
end

figure(4)
ax4 = gca;
axis equal
axis(ax4,viewLims)
ax4.LineWidth = 1.5;
ax4.Box = 'on';
ax4.XTick = [];
ax4.YTick = [];

figure(5)
ax5 = gca;
axis equal
axis(ax5,viewLims)
ax5.LineWidth = 1.5;
ax5.Box = 'on';
ax5.XTick = [];
ax5.YTick = [];