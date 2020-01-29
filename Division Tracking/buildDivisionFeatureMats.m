function [tgtMat,pred1Mat,pred2Mat] = buildDivisionFeatureMats(procTracks,featureStruct,maxF)
%BUILDDIVISIONFEATUREMATS creates matrices based on the first detected cell
%in each track of procTracks (the daughter 'target' matrix) and the predicted 
%position of daughter cells based on the features of cells at the end of their tracks 
%(the maternal 'predicted' matrices).
%
%   INPUTS:
%       -procTracks: Track data, output by the tracking module. Saved
%       within the Tracks.mat file. Used to provide the feature data the
%       output matrices are based on.
%       -featureStruct: Output of the prepareDivStruct: structure
%       containing information detailing the locations of currently
%       selected features in procTracks.
%       -maxF: The maximum frame index up to which features should be compiled
%   
%   OUTPUTS:
%       -tgtMat: The 'target' matrix, indicating the true feature values of
%       all daughter cells across all time points. Split into linear and
%       circular fields, 'lin' and 'circ', for linear and circular data.
%       -pred1Mat: The first 'prediction' matrix, indicating the predicted
%       feature values of daughter cells based on the values of the mothers
%       in the dataset.
%       -pred2Mat: The second 'prediction' matrix.
%   Author: Oliver J. Meacock (c) 2019

featureNames = fieldnames(featureStruct);

%Get information about the different features to be used (defined in the feature matrix)
linFeatNo = 0;
circFeatNo = 0;
for i = 1:length(featureNames)
    switch featureStruct.(featureNames{i}).StatsType
        case 'Linear'
            for l = 1:length(featureStruct.(featureNames{i}).Locations)
                linFeatNo = linFeatNo + 1;
            end
        case 'Circular'
            for l = 1:length(featureStruct.(featureNames{i}).Locations)
                circFeatNo = circFeatNo + 1;
            end
    end
end

tgtMat.lin = zeros(size(procTracks,2),linFeatNo+2);
tgtMat.circ = zeros(size(procTracks,2),circFeatNo+2);
pred1Mat.lin = zeros(size(procTracks,2),linFeatNo+2);
pred1Mat.circ = zeros(size(procTracks,2),circFeatNo+2);
pred2Mat.lin = zeros(size(procTracks,2),linFeatNo+2);
pred2Mat.circ = zeros(size(procTracks,2),circFeatNo+2);

for cInd = 1:size(procTracks,2)
    %Store the track index in the first column of each matrix, and the start/end time of each track (start for target, end for predicted) in the second column
    tgtMat.lin(cInd,1) = cInd;
    pred1Mat.lin(cInd,1) = cInd;
    pred2Mat.lin(cInd,1) = cInd;
    tgtMat.circ(cInd,1) = cInd;
    pred1Mat.circ(cInd,1) = cInd;
    pred2Mat.circ(cInd,1) = cInd;
    
    tgtMat.lin(cInd,2) = procTracks(cInd).times(1);
    pred1Mat.lin(cInd,2) = procTracks(cInd).times(end)+1;
    pred2Mat.lin(cInd,2) = procTracks(cInd).times(end)+1;
    tgtMat.circ(cInd,2) = procTracks(cInd).times(1);
    pred1Mat.circ(cInd,2) = procTracks(cInd).times(end)+1;
    pred2Mat.circ(cInd,2) = procTracks(cInd).times(end)+1;
    
    linCount = 1;
    circCount = 1;
    
    %Store the end time datapoint for each feature ('target') or the start time datapoint processed according to the predictive model stored in the featureStruct.featureName.postDivScale1 field.
    for fInd = 1:size(featureNames,1)
        if strcmp(featureStruct.(featureNames{fInd}).StatsType,'Linear')
            tgtMat.lin(cInd,linCount+2) = procTracks(cInd).(featureNames{fInd})(1);
            
            divInputs = zeros(size(featureStruct.(featureNames{fInd}).divArguments,2),1);
            for aInd = 1:size(featureStruct.(featureNames{fInd}).divArguments,2)
                divInputs(aInd) = procTracks(cInd).(featureStruct.(featureNames{fInd}).divArguments{aInd})(end);
            end
            
            pred1Mat.lin(cInd,linCount+2) = featureStruct.(featureNames{fInd}).postDivScale1(divInputs);
            pred2Mat.lin(cInd,linCount+2) = featureStruct.(featureNames{fInd}).postDivScale2(divInputs);
            
            linCount = linCount + 1;
        elseif strcmp(featureStruct.(featureNames{fInd}).StatsType,'Circular')
            tgtMat.circ(cInd,circCount+2) = (procTracks(cInd).(featureNames{fInd})(1) + featureStruct.(featureNames{fInd}).Range(2))/(featureStruct.(featureNames{fInd}).Range(2) - featureStruct.(featureNames{fInd}).Range(1));
            
            divInputs = zeros(size(featureStruct.(featureNames{fInd}).divArguments,1),1);
            for aInd = 1:size(featureStruct.(featureNames{fInd}).divArguments,1)
                divInputs(aInd) = procTracks(cInd).(featureStruct.(featureNames{fInd}).divArguments{aInd})(end);
            end
            
            pred1Mat.circ(cInd,circCount+2) = (featureStruct.(featureNames{fInd}).postDivScale1(divInputs) + featureStruct.(featureNames{fInd}).Range(2))/(featureStruct.(featureNames{fInd}).Range(2) - featureStruct.(featureNames{fInd}).Range(1));;
            pred2Mat.circ(cInd,circCount+2) = (featureStruct.(featureNames{fInd}).postDivScale2(divInputs) + featureStruct.(featureNames{fInd}).Range(2))/(featureStruct.(featureNames{fInd}).Range(2) - featureStruct.(featureNames{fInd}).Range(1));;
            
            circCount = circCount + 1;
        end
    end
end

%Predictors can't predict past the final frame, and targets can't be predicted from before the first. Eliminate these cases.
pred1Mat.lin(pred1Mat.lin(:,2) == maxF,:) = [];
pred2Mat.lin(pred2Mat.lin(:,2) == maxF,:) = [];
pred1Mat.circ(pred1Mat.circ(:,2) == maxF,:) = [];
pred2Mat.circ(pred2Mat.circ(:,2) == maxF,:) = [];
tgtMat.lin(tgtMat.lin(:,2) == 1,:) = [];
tgtMat.circ(tgtMat.circ(:,2) == 1,:) = [];

%Set circular features to range between 0 and 1. Makes future circular calculation more universal.
circCount = 1;
for fInd = 1:size(featureNames,1)
    if strcmp(featureStruct.(featureNames{fInd}).StatsType,'Circular')
        tgtMat.circ(:,circCount) = (tgtMat.circ(:,circCount) - featureStruct.(featureNames{fInd}).Range(1))./(featureStruct.(featureNames{fInd}).Range(2) - featureStruct.(featureNames{fInd}).Range(1));
        circCount = circCount + 1;
    end
end