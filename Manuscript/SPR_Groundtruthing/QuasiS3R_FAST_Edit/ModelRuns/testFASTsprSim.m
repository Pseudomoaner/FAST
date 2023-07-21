%testFASTsprSim

clear all
close all

%% Run simulation
simSettings.DT = 0;
simSettings.DR = 0;
simSettings.DF = 0;
simSettings.F0 = 1; %Self-propulsion force applied to each rod
simSettings.RootSim = 'C:\Users\olijm\Desktop\SPRfastTest\';
simSettings.noX = 20;
simSettings.noY = 35;
simSettings.dt = 10; %Sampling framerate

groundTruth = runFASTsprSim(simSettings);

%% Add measurement errors
measSettings.Lstd = 0.1; %Standard deviation of measurement noise of aspect ratio (baseline of 0.1 measured from P. aruginosa TSS data)
measSettings.Fstd = 1; %Standard deviation of measurement noise of fluorescence (baseline of 1.06 from TSS data)
measSettings.Cstd = 0.02; %Standard deviation of measurement noise of position (baseline of 0.02 from TSS data)
measSettings.PhiStd = 0.02; %Standard deviation of measurement noise of orientation (baseline of 0.02 from TSS data)
measSettings.segErrorRate = 0.1; %Mis-segmentation error rate (Not used in current version of code)
measSettings.fieldSize = 100; %Size of field in both directions (assume square) - set within runFASTsprSim as well as fieldWidth and fieldHeight (will be kept fixed, so quicker to cludge by setting separately here)

measuredTruth = applyMeasurementErrors(groundTruth,measSettings);

%% Track results
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

thresholds = -4:0.2:2;

% Loop 1: centroid only
F1Centroid = zeros(size(thresholds));

for i = 1:size(thresholds,2)
    F1Centroid(i) = calculateThresholdAccuracy(thresholds(i),procSettings,simSettings,measuredTruth,groundTruth);
end

%Run an optimization procedure to find maximal accuracy values
options = optimset('Display','iter');
threshBounds = [-3,2];
minFuncHand = @(x)calculateThresholdAccuracy(x,procSettings,simSettings,measuredTruth,groundTruth);
[optThreshCent,maxAccuracyCent] = fminbnd(minFuncHand,threshBounds(1),threshBounds(2),options);

% Loop 2: centroid, length and fluo
procSettings.Length = true;
procSettings.Orientation = true;
procSettings.meanInc = logical([1,0,0]);
procSettings.statsUse = 'Centroid';

F1All = zeros(size(thresholds));

for i = 1:size(thresholds,2)
    F1All(i) = calculateThresholdAccuracy(thresholds(i),procSettings,simSettings,measuredTruth,groundTruth);
end

minFuncHand = @(x)calculateThresholdAccuracy(x,procSettings,simSettings,measuredTruth,groundTruth);
[optThreshAll,maxAccuracyAll] = fminbnd(minFuncHand,threshBounds(1),threshBounds(2),options);

plot(10.^thresholds, F1Centroid,'r','LineWidth',1.5)
hold on
plot(10.^thresholds, F1All,'b','LineWidth',1.5)
ax = gca;
ax.XScale = 'log';
ax.YScale = 'log';