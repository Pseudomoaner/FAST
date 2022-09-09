%Script that plots a comparison of the optimised tracking accuracy of the
%FAST tracking algorithm with the trackability score (figure 1) and the
%relative performance of the centroid-only and all-feature versions of the
%algorithm for different types of variation applied to the data (figure 2).

clear all
close all

root = 'C:\Users\olijm\Desktop\SPRfastTest';
fileNames = {'DTsweep','F0Sweep','Nsweep','CentroidNoiseSweep','LnoiseSweep','FnoiseSweep'};
trackabilityName = 'Trackabilities';
optimName = 'OptimisedThresholds';
extension = '.mat';

zeroEqv = 1e-5; %Value inaccuracies of 0 should be set to, so they don't get left off log/log axes - will need to break axes in Inkscape to indicate these properly
Colours = [hex2rgb('7DDF64');...
          hex2rgb('DEB986');...
          hex2rgb('485696');...
          hex2rgb('ED4D6E');...
          hex2rgb('75B9BE');...
          hex2rgb('DDA3B2')];

figure(1)
hold on
axMaxi = gca;
% axMini = axes('Position',[0.6,0.6,0.3,0.3],'Units','Normalized');
figure(3)
hold on
      
for i = 1:size(fileNames,2)
    load(fullfile(root,[fileNames{i},trackabilityName,extension]))
    load(fullfile(root,[fileNames{i},optimName,extension]))
    
    badInds = or(maxAccuraciesCent == 0,maxAccuraciesAll == 0);
%     maxAccuraciesCent(maxAccuraciesCent == 0) = zeroEqv;
%     maxAccuraciesAll(maxAccuraciesAll == 0) = zeroEqv;
    
    figure(1)
%     plot([trackabilityCentroid(~badInds);trackabilityAll(~badInds)],[maxAccuraciesCent(~badInds);maxAccuraciesAll(~badInds)],'Color',Colors(i,:),'LineWidth',1.5)

    figure(3)
    plot(maxAccuraciesCent(~badInds),maxAccuraciesAll(~badInds),'.','Color',Colours(i,:),'MarkerSize',15)
end

trackCentStore = [];
trackAllStore = [];
accCentStore = [];
accAllStore = [];
improvements = [];

for i = 1:size(fileNames,2)
    load(fullfile(root,[fileNames{i},trackabilityName,extension]))
    load(fullfile(root,[fileNames{i},optimName,extension]))
    
%     badInds = or(maxAccuraciesCent == 0,maxAccuraciesAll == 0);
    maxAccuraciesCent(maxAccuraciesCent == 0) = zeroEqv;
    maxAccuraciesAll(maxAccuraciesAll == 0) = zeroEqv;
    
    figure(1)
    %Plot data from centroid-based tracking
    plot(axMaxi,trackabilityCentroid(~badInds),maxAccuraciesCent(~badInds),'o','MarkerFaceColor',hex2rgb('B14E4E'),'MarkerEdgeColor','none','LineWidth',1)
    plot(axMaxi,trackabilityAll(~badInds),maxAccuraciesAll(~badInds),'o','MarkerFaceColor',hex2rgb('7A66B2'),'MarkerEdgeColor','none','LineWidth',1)
    
    if i == 2
        plot(axMaxi,trackabilityAll(3),maxAccuraciesAll(3),'o','MarkerFaceColor',hex2rgb('7A66B2'),'MarkerEdgeColor','k','LineWidth',1)
        plot(axMaxi,trackabilityCentroid(3),maxAccuraciesCent(3),'o','MarkerFaceColor',hex2rgb('B14E4E'),'MarkerEdgeColor','k','LineWidth',1)
    end
    
    trackCentStore = [trackCentStore,trackabilityCentroid(~badInds)];
    trackAllStore = [trackAllStore,trackabilityAll(~badInds)];
    accCentStore = [accCentStore,maxAccuraciesCent(~badInds)];
    accAllStore = [accAllStore,maxAccuraciesAll(~badInds)];
    improvements = [improvements,maxAccuraciesAll(~badInds)./maxAccuraciesCent(~badInds)];
end

axMaxi.YScale = 'log';
axMaxi.YDir = 'reverse';
axMaxi.LineWidth = 1.5;
axMaxi.Box = 'on';
axis([-1,8,1e-5,1])

xlabel(axMaxi,'Trackability (bits object^{-1})')
ylabel(axMaxi,'1 - max(F_1)')

figure(3)
ax2 = gca;
ax2.LineWidth = 1.5;
ax2.Box = 'on';
ax2.YScale = 'log';
ax2.XScale = 'log';
plot([1e-5,1],[1e-5,1],'k')
axis([1e-5,1,1e-5,1])

xlabel('Optimised tracking inaccuracy (Centroids only)')
ylabel('Optimised tracking inaccuracy (All features)')

legend('Framerate','Cell speed','Density','Positional noise','Length noise','Fluorescence noise','Location','NorthWest')