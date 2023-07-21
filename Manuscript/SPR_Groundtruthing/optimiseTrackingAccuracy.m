%Script that finds the optimal tracking threshold for a given set of SPR
%simulations, based on maximising the F1 score. Will also save this
%maximised F1 score for good measure.

clear all
close all

root = 'C:\Users\olijm\Desktop\SPRfastTest';
fileNames = {'DTsweep'};%'DTsweep','F0sweep','Nsweep','LnoiseSweep'};
trackabilityName = 'Trackabilities';
optimName = 'OptimisedThresholds';
extension = '.mat';

%Track settings
procSettings.fieldWidth = 100;
procSettings.fieldHeight = 100;
procSettings.pixSize = 0.2;
procSettings.incProp = 0.75; %Inclusion proportion for the model training stage of the defect tracking
procSettings.minTrackLength = 1;
procSettings.gapWidth = 1;
procSettings.statsUse = 'Centroid';

procSettings.Centroid = true;
procSettings.Width = false;
procSettings.Orientation = false;
procSettings.noChannels = 3;
procSettings.availableMeans = 1:3;
procSettings.availableStds = 1:3;
procSettings.meanInc = [];
procSettings.stdInc = [];
procSettings.Area = false;

threshBounds = [-2,1];
options = optimset('MaxIter',15,'TolX',1e-2,'Display','iter');

for i = 1:size(fileNames,2)
    load(fullfile(root,[fileNames{i},extension]))
    load(fullfile(root,[fileNames{i},trackabilityName,extension]))
    
    %Loop 1: Maximise accuracy for centroid only tracks
    procSettings.Length = false;
    procSettings.meanInc = [];
    procSettings.Orientation = false;
    
    optThreshesCent = zeros(size(measuredTruth));
    maxAccuraciesCent = zeros(size(measuredTruth));
    
    threshBounds = [-2,1];
    
    for j = 1:size(measuredTruth,2)
        measTruth = measuredTruth{j};
        grndTruth = groundTruth{j};
        minFuncHand = @(x)calculateThresholdAccuracy(x,procSettings,simSettings,measTruth,grndTruth);
        
        [optThreshesCent(j),maxAccuraciesCent(j)] = fminbnd(minFuncHand,threshBounds(1),threshBounds(2),options);
    end
    optThreshesCent = 10.^optThreshesCent;
    
    %Loop 2: Maximise accuracy for centroid/fluorescence/length tracks
    procSettings.Length = true;
    procSettings.meanInc = logical([1,0,0]);
    procSettings.Orientation = true;
    
    threshBounds = [-3,0];
    
    optThreshesAll= zeros(size(measuredTruth));
    maxAccuraciesAll = zeros(size(measuredTruth));
        
    for j = 1:size(measuredTruth,2)
        measTruth = measuredTruth{j};
        grndTruth = groundTruth{j};
        minFuncHand = @(x)calculateThresholdAccuracy(x,procSettings,simSettings,measTruth,grndTruth);
        
        [optThreshesAll(j),maxAccuraciesAll(j)] = fminbnd(minFuncHand,threshBounds(1),threshBounds(2),options);
    end
    optThreshesAll = 10.^optThreshesAll;
    
    save(fullfile(root,[fileNames{i},optimName,extension]),'optThreshesCent','optThreshesAll','maxAccuraciesCent','maxAccuraciesAll')
end

