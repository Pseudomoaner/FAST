%Script that creates a set of SPR simulations with variations in one of the
%input parameters (e.g. sampling framerate, positional noise, rod
%self-propulsion force). Then calculates the trackability of each of the
%resulting datasets, and saves everything. Used as the first script in a
%pipeline that proceeds via calcualteThresholdAccuracy and then the various
%plotting scripts.

clear all
close all

%% Simulation settings
simSettings.DT = 0;
simSettings.DR = 0;
simSettings.DF = 0;
simSettings.F0 = 1; %Self-propulsion force applied to each rod
simSettings.RootSim = 'C:\Users\olijm\Desktop\SPRfastTest\';
simSettings.noX = 20;
simSettings.noY = 35;
simSettings.dt = 10; %Sampling framerate

%% Measurement error settings
measSettings.Lstd = 0.1; %Standard deviation of measurement noise of aspect ratio (baseline of 0.1 measured from P. aruginosa TSS data)
measSettings.Fstd = 1; %Standard deviation of measurement noise of fluorescence (baseline of 1.06 from TSS data)
measSettings.Cstd = 0.02; %Standard deviation of measurement noise of position (baseline of 0.02 from TSS data)
measSettings.PhiStd = 0.02; %Standard deviation of measurement noise of orientation (baseline of 0.02 from TSS data)
measSettings.segErrorRate = 0.1; %Mis-segmentation error rate (Not used in current version of code)
measSettings.fieldSize = 100; %Size of field in both directions (assume square) - set within runFASTsprSim as well as fieldWidth and fieldHeight (will be kept fixed, so quicker to cludge by setting separately here)

%% Define variable that will change with each simulation iteration
varList = [5, 7.5, 10, 12.5, 15];
varType = 'Sim'; %Either a simulation variable ('Sim') or a measurement variable ('Meas') - in latter case, will apply different parameter values to the same simulation.
fieldName = 'dt';
simSetName = 'DTsweep';
RsetName = 'DTsweepTrackabilities';

%Settings for rerunning if some simulations went wrong
reprocess = true; %Only set to true if you are rerunning some previous simulations
reprocessInds = 2;

%% Actually run simulations and apply errors
if reprocess
    load(fullfile(simSettings.RootSim,RsetName),'trackabilityAll','trackabilityCentroid') 
    load(fullfile(simSettings.RootSim,simSetName),'groundTruth','measuredTruth') %Note this will overwrite varType etc. so ensure these match the previous run
else
    groundTruth = cell(size(varList));
    measuredTruth = cell(size(varList));
    reprocessInds = 1:size(varList,2);
end

switch varType
    case 'Sim'
        for i = reprocessInds
            simSettings.(fieldName) = varList(i);
            groundTruth{i} = runFASTsprSim(simSettings);
            
            measuredTruth{i} = applyMeasurementErrors(groundTruth{i},measSettings);
        end
    case 'Meas'
        for i = reprocessInds
            groundTruth{i} = runFASTsprSim(simSettings);
            measSettings.(fieldName) = varList(i);
            
            measuredTruth{i} = applyMeasurementErrors(groundTruth{i},measSettings);
        end
end

save(fullfile(simSettings.RootSim,simSetName),'varList','varType','fieldName','simSettings','measSettings','groundTruth','measuredTruth')

%% Track results
procSettings.fieldWidth = 100;
procSettings.fieldHeight = 100;
procSettings.pixSize = 0.2;
procSettings.incProp = 0.75; %Inclusion proportion for the model training stage of the defect tracking
procSettings.minTrackLength = 1;
procSettings.gapWidth = 1;
procSettings.statsUse = 'Centroid';
procSettings.tgtDensity = 0.1;

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

% Sweep 1: centroid only
trackabilityCentroid = zeros(size(varList));
for i = 1:size(varList,2)
    [~,~,~,~,linkStats,~] = trackRodsFAST(measuredTruth{i}.trackableData,procSettings,simSettings.dt);
    trackabilityCentroid(i) = mean(linkStats.trackability);
end

% Sweep 2: centroid, length and fluo
procSettings.Length = true;
procSettings.meanInc = logical([1,0,0]);
procSettings.statsUse = 'Centroid';

trackabilityAll = zeros(size(varList));
for i = 1:size(varList,2)
    [~,~,~,~,linkStats,~] = trackRodsFAST(measuredTruth{i}.trackableData,procSettings,simSettings.dt);
    trackabilityAll(i) = mean(linkStats.trackability);
end

save(fullfile(simSettings.RootSim,RsetName),'varList','trackabilityCentroid','trackabilityAll')