clear all
close all

root = 'C:\Users\Olivier\Desktop\FAST_Benchmarking\VlietLineages\FAST_Efforts';
branches = {'140408_01_cib','140408_02_cib','140408_09_cib','140408_10_cib','140408_11_cib','140409_03_cib','140415_08_cib','140415_13_cib'};

vmagList = zeros(size(branches));
GRlist = zeros(size(branches));
covWlist = zeros(size(branches));
covFlist = zeros(size(branches));
trackabilityMean = zeros(size(branches));

for b = 1:size(branches,2)
    load(fullfile(root,branches{b},'Tracks_ManualSeg_Corrected.mat'))
    
    firstGoodInd = find(cellfun(@(x)size(x,1),trackableData.Centroid) > 32, 1);
    
    goodTracks = arrayfun(@(x)x.times(1) >= firstGoodInd,procTracks);
    
    %Speed measurements
    vmags = arrayfun(@(x)mean(x.vmag),procTracks);
    vmagList(b) = mean(vmags(goodTracks));
    
    %Growth rate measurements
    GRs = zeros(size(procTracks));
    for i = 1:size(procTracks,2)
        f = fit(procTracks(i).times',procTracks(i).majorLen,'exp1');
        GRs(i) = f.b;
    end
    GRlist(b) = mean(GRs(goodTracks));
    
    %Fluoresence and width fluctuations
    Fflucs = arrayfun(@(x)std(x.channel_2_mean - mean(x.channel_2_mean))/mean(x.channel_2_mean),procTracks);
    Wflucs = arrayfun(@(x)std(x.minorLen - mean(x.minorLen))/mean(x.minorLen),procTracks);
    covFlist(b) = mean(Fflucs(goodTracks));
    covWlist(b) = mean(Wflucs(goodTracks));
    
    %Average trackability
    trackabilityMean(b) = mean(linkStats.trackability(firstGoodInd:end));
end

figure
subplot(1,4,1)
tbl_V = table(vmagList',trackabilityMean');
mdl_V = fitlm(tbl_V,'Var2 ~ Var1');
plot(mdl_V)
xlabel('Average speed')
ylabel('Average trackability')
ylim([2,10])
title('')

subplot(1,4,2)
tbl_G = table(GRlist',trackabilityMean');
mdl_G = fitlm(tbl_G,'Var2 ~ Var1');
plot(mdl_G)
xlabel('Average growth rate')
ylabel('')
ylim([2,10])
title('')

subplot(1,4,3)
tbl_F = table(covFlist',trackabilityMean');
mdl_F = fitlm(tbl_F,'Var2 ~ Var1');
plot(mdl_F)
xlabel('COV - fluoresence')
ylabel('')
ylim([2,10])
title('')

subplot(1,4,4)
tbl_W = table(covWlist',trackabilityMean');
mdl_W = fitlm(tbl_W,'Var2 ~ Var1');
plot(mdl_W)
xlabel('COV - width')
ylabel('')
ylim([2,10])
title('')