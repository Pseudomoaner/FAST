clear all
close all

load('C:\Users\omeacock\Desktop\FAST_Datasets\Slingshotting\Tracks.mat');
load('C:\Users\omeacock\Desktop\FAST_Datasets\Slingshotting\TrackabilityStore.mat')

realDt = diff(dtStore);

densityScatter(realDt(1:end-1)',linkStats.trackability(2:end),250,1,'cool')
hold on
ax = gca;
ax.LineWidth = 1.5;
ax.Box = 'on';
xList = 0:0.01:0.3;
linFit = fit(realDt(1:end-1)',linkStats.trackability(2:end),'poly1');
plot(xList,linFit.p2 + linFit.p1*xList,'k:','LineWidth',1.5)
axis([0,0.1,12,14.5])

[R,p] = corr(realDt(1:end-1)',linkStats.trackability(2:end))