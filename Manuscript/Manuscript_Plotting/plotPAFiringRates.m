clear all
close all

mainRoot = 'C:\Users\omeacock\Desktop\FAST_Datasets\T6SS\';

load(fullfile(mainRoot,'allTracks.mat'))

onBranches = {'SM6_1','SM6_2'};
offBranches = {'SM7_1','SM7_2'};

onRates = zeros(size(onBranches));
offRates = zeros(size(offBranches));

for i = 1:size(onBranches,2)
    procTracks = procTracksAll.(onBranches{i});
    eventTot = 0;
    timeTot = 0;
    for j = 1:size(procTracks,2)
        if procTracks(j).population == 1
            eventTot = eventTot + sum(procTracks(j).event);
            timeTot = timeTot + numel(procTracks(j).x);
        end
    end
    onRates(i) = eventTot/timeTot;
end

for i = 1:size(offBranches,2)
    procTracks = procTracksAll.(offBranches{i});
    eventTot = 0;
    timeTot = 0;
    for j = 1:size(procTracks,2)
        if procTracks(j).population == 1
            eventTot = eventTot + sum(procTracks(j).event);
            timeTot = timeTot + numel(procTracks(j).x);
        end
    end
    offRates(i) = eventTot/timeTot;
end

ax=gca;
hold on
plot(ax,[1,1],onRates,'.','MarkerSize',12,'color',[0,0.8,0.8])
plot(ax,[2,2],offRates,'.','MarkerSize',12,'color',[0,0.8,0.8])
plot(ax,[0.8,1.2],[mean(onRates),mean(onRates)],'LineWidth',2,'color',[0,0.8,0.8])
plot(ax,[1.8,2.2],[mean(offRates),mean(offRates)],'LineWidth',2,'color',[0,0.8,0.8])
axis([0.5,2.5,0,0.007])
ax.Box='on';
ax.LineWidth=1.5;
ylabel('Fraction of time firing')