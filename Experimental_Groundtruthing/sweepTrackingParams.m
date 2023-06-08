clear all
close all

%The location of the track data generated following the object tracking stages
root = 'C:\Users\Olivier\Desktop\FAST_Benchmarking\VlietLineages\FAST_Efforts';
branches = {'140408_01_cib','140408_02_cib','140408_09_cib','140408_10_cib','140408_11_cib','140409_03_cib','140415_08_cib','140415_13_cib'};

trackSettingsLoc = 'Tracks_AutoSeg_Auto_CentroidsOnly.mat';
refTracksLoc = 'Tracks_AutoSeg_Corrected.mat';

Ps = [0.2,0.4,0.6,0.8,0.9,0.95,0.975];
betas = [0.05,0.1,0.2,0.5,1,2,5];

figure('Units','normalized','Position',[0.1,0.1,0.8,0.7])

for b = 1:size(branches,2)
    load(fullfile(root,branches{b},trackSettingsLoc),'trackSettings')
    load(fullfile(root,branches{b},refTracksLoc),'rawFromMappings','rawToMappings')
    
    refTracks = revertTrackFormat(rawFromMappings,rawToMappings);
    
    Fscores = zeros(size(Ps,2),size(betas,2));
    
    for pInd = 1:size(Ps,2)
        trackSettings.incProp = Ps(pInd);
        for betInd = 1:size(betas,2)
            trackSettings.tgtDensity = betas(betInd);
            
            runTrackingBatch(fullfile(root,branches{b}),trackSettings)
            
            load(fullfile(root,branches{b},'Tracks.mat'),'rawFromMappings','rawToMappings')
            
            testTracks = revertTrackFormat(rawFromMappings,rawToMappings);
            
            [TP,FP,TN,FN] = scoreTrackQuality(testTracks,refTracks,2);
            Fscores(pInd,betInd) = (2*sum(TP))/(2*sum(TP) + sum(FN) + sum(FP));
        end
    end
    
    debugprogressbar(1,true)
    
    subplot(2,4,b)
    imagesc(log10(1-Fscores))
    ax = gca;
    ax.XTick = 1:size(betas,2);
    xticklabels(betas)
    yticklabels(Ps)
    xlabel('\beta')
    ylabel('P')
    colormap('turbo')
    title(branches{b}, 'Interpreter', 'none')
    caxis([-3,0])
end