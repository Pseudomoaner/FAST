%Plots

clear all
close all

load('C:\Users\olijm\Desktop\Pinging\Tracks.mat');

%% Part 1: Discount timepoints with unlikely length or width measurements (probably mis-segmentations)
lenThresh = 0.4; %Maximal length difference from median for timepoint to be discarded
widThresh = 0.2; %Maximal width difference from median for timepoint to be discarded

vComps = cell(size(procTracks));
for i = 1:size(procTracks,2)
    medLen = median(procTracks(i).majorLen);
    medWidth = median(procTracks(i).minorLen);
    
    badLens = or(procTracks(i).majorLen > medLen + lenThresh,procTracks(i).majorLen < medLen - lenThresh);
    badWidths = or(procTracks(i).minorLen > medWidth + widThresh,procTracks(i).minorLen < medWidth - lenThresh);
    badIndsOrd1 = or(badLens,badWidths); %Bad indices for first-order features (e.g. position, length)
    
    badIndsOrd2 = badIndsOrd1(1:end-1); %Bad indices for second-order features (e.g. velocity, growth rate)
    badIndsOrd2(diff(badIndsOrd2) == 1) = 1; %Pad bad index vector so timepoints both before and after mis-segmentations are discounted
    
    xVComps = procTracks(i).vmag(~badIndsOrd2).*cosd(procTracks(i).theta(~badIndsOrd2));
    yVComps = procTracks(i).vmag(~badIndsOrd2).*sind(procTracks(i).theta(~badIndsOrd2));
    
    vComps{i} = [xVComps;yVComps];
end
allVcomps = vertcat(vComps{:});

%% Part 2: Calculate and plot histogram

[N,E] = histcounts(allVcomps,'BinWidth',0.5,'Normalization','pdf');
M = (E(1:end-1) + diff(E)/2);

normD = makedist('Normal','mu',0,'sigma',std(allVcomps));
x = -70:0.1:70;
normPDF = pdf(normD,x);

hold on
plot([0,0],[1e-6,1],'k','LineWidth',1.5)
plot(M,N,'o','MarkerFaceColor',[0.2,0.9,0.2],'MarkerSize',4,'MarkerEdgeColor','none')
plot(x,normPDF,'k--','LineWidth',1.5)

ax = gca;
ax.Box = 'on';
ax.YScale = 'log';
ax.LineWidth = 1.5;

axis([-60,60,1e-6,1])