%Script that plots a comparison of the trackability and tracking accuracy
%of the centroid-only and all-feature versions of the FAST tracking
%algorithm. Should be run after calculateThresholdAccuracy.m.

clear all
close all

root = 'C:\Users\olijm\Desktop\SPRfastTest';
fileNames = {'DTsweep','F0Sweep','Nsweep','CentroidNoiseSweep','LnoiseSweep','FnoiseSweep'};
legendTitles = {'Sampling framerate','Cell speed','System density','Positional noise','Length noise','Fluorescence noise'};
trackabilityName = 'Trackabilities';
optimName = 'OptimisedThresholds';
extension = '.mat';

plotColCent = hex2rgb('B14E4E');
plotColAll = hex2rgb('7A66B2');

zeroRep = 1e-5; %Value samples with zero errors should be replaced with

for i = 1:size(fileNames,2)
    load(fullfile(root,[fileNames{i},trackabilityName,extension]))
    load(fullfile(root,[fileNames{i},optimName,extension]),'maxAccuraciesAll','maxAccuraciesCent')
    
    %Adjust the diplayed units of the independant variable if needed
    if i == 1 %DT sweep
        varList = varList; %So measured in framerate rather than dt
    elseif i == 3 %Density sweep
        load(fullfile(root,[fileNames{i},extension]),'groundTruth')
        for j = 1:size(groundTruth,2)
            varList(j) = groundTruth{j}.areaFrac;
        end
    end
    
    %     ax1 = axes('Position',[i/(size(fileNames,2)+2),0.55,1/(size(fileNames,2)+2),0.35],'Units','Normalized');
    shiftFac = (floor((i-0.5)/3)/20) - 0.025; %Sets the size of the gap separating the simulation parameters from the measurement parameters
    ax1 = axes('Position',[i/(size(fileNames,2)+2)+shiftFac,0.5,1/(size(fileNames,2)+2),0.4],'Units','Normalized');
    hold on
    
    plot([varList;varList],[trackabilityCentroid;trackabilityAll],'k','LineWidth',1.5)
    plot(varList,trackabilityCentroid,'ko','MarkerFaceColor',plotColCent,'MarkerSize',8)
    plot(varList,trackabilityAll,'ko','MarkerFaceColor',plotColAll,'MarkerSize',8)
    plot(varList,mean([trackabilityCentroid;trackabilityAll],1),'k^','MarkerSize',6,'MarkerFaceColor','k')
%     plot(varList,trackabilityCentroid,'Color',plotColCent,'LineWidth',1.5)
%     plot(varList,trackabilityAll,'Color',plotColAll,'LineWidth',1.5)
%     xlabel(legendTitles{i})
    
    axPadFrac = (max(varList)-min(varList))/10;

    ax1 = gca;
    ax1.LineWidth = 1.5;
    ax1.XTickLabel = [];
    ax1.Box = 'on';
    axis(ax1,[min(varList)-axPadFrac,max(varList)+axPadFrac,-1,9])
    if i == 1
        ylabel('Trackability')
%         legend('Centroid only','All features','Location','NorthWest')
    else
        ax1.YTickLabel = [];
    end
    
%     ax2 = axes('Position',[i/(size(fileNames,2)+2),0.1,1/(size(fileNames,2)+2),0.35],'Units','Normalized');
    ax2 = axes('Position',[i/(size(fileNames,2)+2)+shiftFac,0.1,1/(size(fileNames,2)+2),0.4],'Units','Normalized');
    hold on
    
    maxAccuraciesCent(maxAccuraciesCent == 0) = zeroRep;
    maxAccuraciesAll(maxAccuraciesAll == 0) = zeroRep;
%     badInds = or(maxAccuraciesCent == 0,maxAccuraciesAll == 0);
    plot([varList;varList],[maxAccuraciesCent;maxAccuraciesAll],'k','LineWidth',1.5)
    plot(varList,maxAccuraciesCent,'ko','MarkerFaceColor',plotColCent,'MarkerSize',8)
    plot(varList,maxAccuraciesAll,'ko','MarkerFaceColor',plotColAll,'MarkerSize',8)
    plot(varList,mean([maxAccuraciesCent;maxAccuraciesAll],1),'k^','MarkerSize',6,'MarkerFaceColor','k')
%     plot([trackabilityCentroid(~badInds);trackabilityAll(~badInds)],[maxAccuraciesCent(~badInds);maxAccuraciesAll(~badInds)],'k','LineWidth',1.5)
%     plot(trackabilityCentroid(~badInds),maxAccuraciesCent(~badInds),'ko','MarkerFaceColor',plotColCent)
%     plot(trackabilityAll(~badInds),maxAccuraciesAll(~badInds),'ko','MarkerFaceColor',plotColAll)
%     xlabel('Trackability')
    xlabel(legendTitles{i})
    
    ax2.YScale = 'log';
    ax2.YDir = 'reverse';
    ax2.LineWidth = 1.5;
    ax2.Box = 'on';
    axis(ax2,[min(varList)-axPadFrac,max(varList)+axPadFrac,1e-5,1])
    if i == 1
        ylabel('Minimised tracking inaccuracy')
    else
        ax2.YTickLabel = [];
    end
end