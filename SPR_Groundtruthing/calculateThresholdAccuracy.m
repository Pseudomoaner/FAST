function outScore = calculateThresholdAccuracy(threshold,procSettings,simSettings,measuredTruth,groundTruth)
%CALCULATETHRESHOLDACCURACY performs tracking with FAST on the given
%trackable data structure in the measuredTruth structure, and compares the
%resulting tracks to the ground truth as output by the SPR model. Scores
%the results using the F1 score (Beta currently = 1). Function is formatted
%to work with the fminsearch optimisation procedure, so actually returns
%1-F1 (so the score can be minimised, rather than maximised).
%
%   INPUTS:
%       -threshold: the currently selected link detection cutoff (in the
%       normalized feature space).
%       -procSettings: track processing settings
%       -simSettings: settings used to setup the SPR simulation
%       -measuredTruth: the feature data with measurement noise added
%       -groundTruth: structure output by the SPR simulations, containing
%       the un-noisy feature information as well as the correct
%       ground-truth track data.
%
%   OUTPUTS:
%       -outScore: 1 minus the F1 score.
%
%   Author: Oliver J. Meacock, 2022

Beta = 1; %Factor that recall is considered more important than precision (precision is more important in tracking, so may set less than 1) 

procSettings.tgtDensity = 10^threshold;
[~,~,~,~,~,Tracks] = trackRodsFAST(measuredTruth.trackableData,procSettings,simSettings.dt);

[TP,FP,TN,FN] = scoreTrackQuality(Tracks,groundTruth.tracks,procSettings.gapWidth);
TPs = sum(TP);
FPs = sum(FP);
TNs = sum(TN);
FNs = sum(FN);

R1 = TPs./(TPs + FNs); %Recall
P1 = TPs./(TPs + FPs); %Precision

F1 = ((1+Beta^2)*R1*P1)./(R1 + (Beta^2)*P1);
outScore = 1-F1;