clear all
close all

root = 'C:\Users\Olivier\Desktop\FAST_Benchmarking\VlietLineages\FAST_Efforts';
branches = {'140408_01_cib','140408_02_cib','140408_09_cib','140408_10_cib','140408_11_cib','140409_03_cib','140415_08_cib','140415_13_cib'};

vmagList = zeros(size(branches));
GRlist = zeros(size(branches));
covWlist = zeros(size(branches));
covFlist = zeros(size(branches));
trackabilityMean = zeros(size(branches));
trackabilityMeanCent = zeros(size(branches));

dt = 5; %In minutes
dx = 0.4; %Factor which accounts for the fact I didn't know the pixel size when running the analysis (0.04), so just put 0.1 as a guesstimate.

for b = 1:size(branches,2)
    load(fullfile(root,branches{b},'Tracks_ManualSeg_Corrected.mat'))
    
    firstGoodInd = find(cellfun(@(x)size(x,1),trackableData.Centroid) > 32, 1);
    
    goodTracks = arrayfun(@(x)x.times(1) >= firstGoodInd,procTracks);
    
    %Speed measurements
    vmags = arrayfun(@(x)mean(x.vmag)*dx/dt,procTracks);
    vmagList(b) = mean(vmags(goodTracks));
    disp(mean(arrayfun(@(x)mean(x.majorLen)*dx,procTracks)));
    
    %Growth rate measurements
    GRs = zeros(size(procTracks));
    for i = 1:size(procTracks,2)
        f = fit(procTracks(i).times'*dt,procTracks(i).majorLen*dx,'exp1');
        GRs(i) = f.b;
    end
    GRlist(b) = mean(GRs(goodTracks));
    
    %Fluoresence and width fluctuations
    Fflucs = arrayfun(@(x)std(x.channel_2_mean - mean(x.channel_2_mean))/mean(x.channel_2_mean),procTracks);
    Wflucs = arrayfun(@(x)std(x.minorLen - mean(x.minorLen))/mean(x.minorLen),procTracks); %dx gets cancelled out, so don't need to include
    covFlist(b) = mean(Fflucs(goodTracks));
    covWlist(b) = mean(Wflucs(goodTracks));
    
    %Average trackability
    trackabilityMean(b) = mean(linkStats.trackability(firstGoodInd:end));
    load(fullfile(root,branches{b},'Tracks_AutoSeg_Auto_CentroidsOnly.mat'))
    trackabilityMeanCent(b) = mean(linkStats.trackability(firstGoodInd:end));
end

purp = [122,102,178]/255;
brn = [177,78,78]/255;
ms = 4;

figure
subplot(1,4,1)
hold on

p = polyfit(vmagList,trackabilityMean,1);
plot(vmagList,trackabilityMean,'o','MarkerFaceColor',purp,'Color',purp,'MarkerSize',ms)
plot(vmagList,polyval(p,vmagList),'Color',purp)
plot(vmagList(1),trackabilityMean(1),'ko','MarkerSize',ms+1.5,'LineWidth',1)

p = polyfit(vmagList,trackabilityMeanCent,1);
plot(vmagList,trackabilityMeanCent,'o','MarkerFaceColor',brn,'Color',brn,'MarkerSize',ms)
plot(vmagList,polyval(p,vmagList),'Color',brn)
plot(vmagList(1),trackabilityMeanCent(1),'ko','MarkerSize',ms+1.5,'LineWidth',1)

xlabel('Average speed (\mum/min)')
ylabel('Average trackability (bits/object)')
ax=gca;
ax.LineWidth = 1.5;
ax.Box = 'on';
ylim([0,11])
xlim([0.035,0.07])

subplot(1,4,2)
hold on

p = polyfit(GRlist,trackabilityMean,1);
plot(GRlist,trackabilityMean,'o','MarkerFaceColor',purp,'Color',purp,'MarkerSize',ms)
plot(GRlist,polyval(p,GRlist),'Color',purp)
plot(GRlist(1),trackabilityMean(1),'ko','MarkerSize',ms+1.5,'LineWidth',1)

p = polyfit(GRlist,trackabilityMeanCent,1);
plot(GRlist,trackabilityMeanCent,'o','MarkerFaceColor',brn,'Color',brn,'MarkerSize',ms)
plot(GRlist,polyval(p,GRlist),'Color',brn)
plot(GRlist(1),trackabilityMeanCent(1),'ko','MarkerSize',ms+1.5,'LineWidth',1)

xlabel('Average growth rate (1/min)')
ax=gca;
ax.LineWidth = 1.5;
ax.Box = 'on';
ylim([0,11])
xlim([0.01,0.025])

subplot(1,4,3)
hold on

p = polyfit(covFlist,trackabilityMean,1);
plot(covFlist,trackabilityMean,'o','MarkerFaceColor',purp,'Color',purp,'MarkerSize',ms)
plot(covFlist,polyval(p,covFlist),'Color',purp)
plot(covFlist(1),trackabilityMean(1),'ko','MarkerSize',ms+1.5,'LineWidth',1)

p = polyfit(covFlist,trackabilityMeanCent,1);
plot(covFlist,trackabilityMeanCent,'o','MarkerFaceColor',brn,'Color',brn,'MarkerSize',ms)
plot(covFlist,polyval(p,covFlist),'Color',brn)
plot(covFlist(1),trackabilityMeanCent(1),'ko','MarkerSize',ms+1.5,'LineWidth',1)

xlabel('COV - fluoresence')
ax=gca;
ax.LineWidth = 1.5;
ax.Box = 'on';
ylim([0,11])
xlim([0.022,0.048])

subplot(1,4,4)
hold on

p = polyfit(covWlist,trackabilityMean,1);
plot(covWlist,trackabilityMean,'o','MarkerFaceColor',purp,'Color',purp,'MarkerSize',ms)
plot(covWlist,polyval(p,covWlist),'Color',purp)
plot(covWlist(1),trackabilityMean(1),'ko','MarkerSize',ms+1.5,'LineWidth',1)

p = polyfit(covWlist,trackabilityMeanCent,1);
plot(covWlist,trackabilityMeanCent,'o','MarkerFaceColor',brn,'Color',brn,'MarkerSize',ms)
plot(covWlist,polyval(p,covWlist),'Color',brn)
plot(covWlist(1),trackabilityMeanCent(1),'ko','MarkerSize',ms+1.5,'LineWidth',1)

xlabel('COV - width')
ax=gca;
ax.LineWidth = 1.5;
ax.Box = 'on';
ylim([0,11])
xlim([0.05,0.065])