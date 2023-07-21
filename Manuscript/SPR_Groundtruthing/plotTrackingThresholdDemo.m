clear all
close all

%% Simulation settings
simSettings.DT = 0;
simSettings.DR = 0;
simSettings.DF = 0;
simSettings.F0 = 1.25;
simSettings.RootSim = 'C:\Users\olijm\Desktop\SPRfastTest\';
simSettings.noX = 20;
simSettings.noY = 35;
simSettings.dt = 8;

%% Measurement error settings
measSettings.Lstd = 0.075; %Standard deviation of measurement noise of length (baseline of 0.075 measured from P. aruginosa pinging data
measSettings.Fstd = 0.1; %Standard deviation of measurement noise of fluorescence (originally 0.1)
measSettings.Cstd = 0.25;
measSettings.PhiStd = 0.1;
measSettings.segErrorRate = 0.1; %Mis-segmentation error rate
measSettings.fieldSize = 100; %Size of field in both directions (assume square) - set within runFASTsprSim as well as fieldWidth and fieldHeight (will be kept fixed, so quicker to cludge by setting separately here)

groundTruth = runFASTsprSim(simSettings);
measuredTruth = applyMeasurementErrors(groundTruth,measSettings);

%% Track settings
procSettings.fieldWidth = 100;
procSettings.fieldHeight = 100;
procSettings.pixSize = 0.2;
procSettings.incProp = 0.75; %Inclusion proportion for the model training stage of the defect tracking
procSettings.minTrackLength = 1;
procSettings.gapWidth = 1;
procSettings.statsUse = 'Centroid';

procSettings.Centroid = true;
procSettings.Length = false;
procSettings.Width = false;
procSettings.Orientation = false;
procSettings.noChannels = 3;
procSettings.availableMeans = 1:3;
procSettings.availableStds = 1:3;
procSettings.meanInc = [];
procSettings.stdInc = [];
procSettings.Area = false;

thresholdVals = 10.^(-4:0.1:2);
Beta = 1;

centOnlyScores = zeros(size(thresholdVals));
for i = 1:size(thresholdVals,2)
    disp(i)
    procSettings.tgtDensity = thresholdVals(i);
    
    [~,~,~,~,~,Tracks] = trackRodsFAST(measuredTruth.trackableData,procSettings,simSettings.dt);
    
    [TP,FP,TN,FN] = scoreTrackQuality(Tracks,groundTruth.tracks,procSettings.gapWidth);
    TPs = sum(TP);
    FPs = sum(FP);
    TNs = sum(TN);
    FNs = sum(FN);
    
    R1 = TPs./(TPs + FNs); %Recall
    P1 = TPs./(TPs + FPs); %Precision
    
    F1 = ((1+Beta^2)*R1*P1)./(R1 + (Beta^2)*P1);
    centOnlyScores(i) = F1;
end

procSettings.Length = true;
procSettings.Orientation = true;
procSettings.meanInc = logical([1,0,0]);
allFeatScores = zeros(size(thresholdVals));
for i = 1:size(thresholdVals,2)
    disp(i)
    procSettings.tgtDensity = thresholdVals(i);
    
    [~,~,~,~,~,Tracks] = trackRodsFAST(measuredTruth.trackableData,procSettings,simSettings.dt);
    
    [TP,FP,TN,FN] = scoreTrackQuality(Tracks,groundTruth.tracks,procSettings.gapWidth);
    TPs = sum(TP);
    FPs = sum(FP);
    TNs = sum(TN);
    FNs = sum(FN);
    
    R1 = TPs./(TPs + FNs); %Recall
    P1 = TPs./(TPs + FPs); %Precision
    
    F1 = ((1+Beta^2)*R1*P1)./(R1 + (Beta^2)*P1);
    allFeatScores(i) = F1;
end

plot(thresholdVals,1-centOnlyScores,'LineWidth',1.5,'Color',hex2rgb('B14E4E'))
hold on
plot(thresholdVals,1-allFeatScores,'LineWidth',1.5,'Color',hex2rgb('7A66B2'))
ax = gca;
ax.LineWidth = 1.5;
ax.Box = 'on';
ax.YScale = 'log';
ax.XScale = 'log';
ax.YDir = 'reverse'; %With some relabelling of ticks, this allows you to plot the F score directly, rather than 1-F.