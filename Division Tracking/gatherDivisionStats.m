function [linkStats,tgtMat,pred1Mat,pred2Mat,featureStruct] = gatherDivisionStats(procTracks,divisionSettings)
%GATHERDIVISIONSTATS performs the model training stage of the tracking
%algorithm of FAST. 
%
%   INPUTS:
%       -procTracks: The main output of the tracking module, saved in the
%       Tracks.mat file. 
%       -divisionSettings: Structure created by the diffusionTracker GUI
%   
%   OUTPUTS:
%       -linkStats: The statistics extracted from the current dataset.
%       Contains separate fields indicating the Extent, Mean displacement
%       (drift), standard Deviation and Reliability of each feature. 
%       Circular and linear features are stored separately.
%       -tgtMat: The 'target' matrix, indicating the true feature values of
%       all daughter cells across all time points.
%       -pred1Mat: The first 'prediction' matrix, indicating the predicted
%       feature values of daughter cells based on the values of the mothers
%       in the dataset.
%       -pred2Mat: The second 'prediction' matrix.
%       -featureStruct: The output of the prepareTrackStruct function
%       -trackability: The ease with which mother-daughter assignments can
%       be made for this dataset.
%   
%   Author: Oliver J. Meacock, (c) 2019

featureStruct = prepareDivStruct(divisionSettings);

%Build feature matrices
[tgtMat,pred1Mat,pred2Mat] = buildDivisionFeatureMats(procTracks,featureStruct,divisionSettings.maxFrame);

%Get scaling factors for scoring stage
[covDfs,covFs,linMs,circMs,trackability] = getDivScalingFactors(tgtMat,pred1Mat,pred2Mat,divisionSettings.incProp,divisionSettings.statsUse);

%Pack up for export
linkStats.trackability = trackability;
linkStats.linMs = linMs;
linkStats.circMs = circMs;
linkStats.covDfs = covDfs;
linkStats.covFs = covFs;