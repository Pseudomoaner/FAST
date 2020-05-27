function [covDfs,covFs,linMs,circMs,trackability] = getDivScalingFactors(tgtMat,pred1Mat,pred2Mat,includeProportion,statsUse)
%GETDIVSCALINGFACTORS calculates the feature summary statistics necessary
%for normalising the feature space, specifically for the division detection
%module.
%
%   INPUTS:
%       -tgtMat: The 'target' matrix, indicating the true feature values of
%       all daughter cells across all time points.
%       -pred1Mat: The first 'prediction' matrix, indicating the predicted
%       feature values of daughter cells based on the values of the mothers
%       in the dataset.
%       -pred2Mat: The second 'prediction' matrix.
%       -includeProportion: User-defined proportion of highest-scoring
%       low-quality links that should be included during the calculation of
%       summary statistics.
%       -statsUse: Whether the full range of available features should be
%       used during model training, or just the centroid
%
%   OUTPUTS:
%       -linEs: Extents (double the interquartile range) of the linear
%       features.
%       -circEs: Extents of the circular features.
%       -linDs: Dispersals (standard deviations) of the linear features
%       -circDs: Dispersals of the circular features
%       -linMs: Drifts (means) of the linear features
%       -circMs: Drifts of the circular features
%       -trackability: Trackability score for the dataset
%
%   Author: Oliver J. Meacock (c) 2019

%Find the full range of values that each of the linear variables can take
allFeats = [tgtMat.lin(:,2:end),tgtMat.circ(:,2:end);pred1Mat.lin(:,2:end),pred1Mat.circ(:,2:end);pred2Mat.lin(:,2:end),pred2Mat.circ(:,2:end)];
maxFeats = max(allFeats(:,1:size(tgtMat.lin,2)-1),[],1);
minFeats = min(allFeats(:,1:size(tgtMat.lin,2)-1),[],1);

if ~isempty(tgtMat.lin) && ~isempty(pred1Mat.lin)
    linFrameT = tgtMat.lin(:,2:end);
    linFrameP1 = pred1Mat.lin(:,2:end);
    linFrameP2 = pred2Mat.lin(:,2:end);
    circFrameT = tgtMat.circ(:,2:end);
    circFrameP1 = pred1Mat.circ(:,2:end);
    circFrameP2 = pred2Mat.circ(:,2:end);
    
    %Regularize the linear data, so it varies between 0 and 1. Is an approximate way of weighting all features equally, so you can get estimates of the statistics you need to weigh them more accurately later.
    linFrameTReg = (linFrameT - repmat(minFeats,size(linFrameT,1),1))./(repmat(maxFeats,size(linFrameT,1),1) - repmat(minFeats,size(linFrameT,1),1));
    linFrameP1Reg = (linFrameP1 - repmat(minFeats,size(linFrameP1,1),1))./(repmat(maxFeats,size(linFrameP1,1),1) - repmat(minFeats,size(linFrameP1,1),1));
    linFrameP2Reg = (linFrameP2 - repmat(minFeats,size(linFrameP2,1),1))./(repmat(maxFeats,size(linFrameP2,1),1) - repmat(minFeats,size(linFrameP2,1),1));
    
    switch statsUse
        case 'Centroid'
            D1 = pdist2(linFrameTReg(:,1:3),linFrameP1Reg(:,1:3));
            D2 = pdist2(linFrameTReg(:,1:3),linFrameP2Reg(:,1:3));
        case 'All'
            DL1 = pdist2(linFrameTReg,linFrameP1Reg); %Distance between the target (daughter) and 1st predicted (from mother) cells - linear stats
            DL2 = pdist2(linFrameTReg,linFrameP2Reg);
            DC1 = pdist2(circFrameT,circFrameP1,@circDist);
            DC2 = pdist2(circFrameT,circFrameP2,@circDist);
            
            D1 = (DL1.^2 + DC1.^2).^0.5; %Distance measure for the first predicted daughter location - targets (daughters) in the rows, predictions (mothers) in the columns
            D2 = (DL2.^2 + DC2.^2).^0.5; %Distance measure for the second predicted daughter location
    end
    %Some of these will correspond to predictation and targets at the same time point. That makes no sense - you can't be in both a pre and post-division state at once - set these comparisons to be infinitely large.
    TT = repmat(tgtMat.lin(:,2),1,size(pred1Mat.lin,1));
    TP = repmat(pred1Mat.lin(:,2)',size(tgtMat.lin,1),1);
    sameT = (TT - 1) == TP;
    
    D1(sameT) = Inf;
    D2(sameT) = Inf;
    
    %Find the minimum distance between each prediction and all target points
    [distsTmpD1,locsPD1] = min(D1,[],2); %locsPD1 gives the indices of the best linked predictions
    locsTD1 = (1:size(D1,1))'; %indicies of best linked targets
    [distsTmpD2,locsPD2] = min(D2,[],2); %locsPD1 gives the indices of the best linked predictions
    locsTD2 = (1:size(D2,1))'; %indicies of best linked targets
    
    grouped1Mat = [distsTmpD1,locsTD1,locsPD1];
    grouped2Mat = [distsTmpD2,locsTD2,locsPD2];
    
    sorted1Mat = sortrows(grouped1Mat,1); %Sort by distance
    sorted2Mat = sortrows(grouped2Mat,1);
    
    %Assume the n% closest tracks are accurately linked - base scaling factors on these links.
    goodInds1 = 1:round(size(sorted1Mat,1)*includeProportion);
    goodT1 = sorted1Mat(goodInds1,2);
    goodP1 = sorted1Mat(goodInds1,3);
    
    goodInds2 = 1:round(size(sorted2Mat,1)*includeProportion);
    goodT2 = sorted2Mat(goodInds2,2);
    goodP2 = sorted2Mat(goodInds2,3);
    
    uniqueTgts = union(goodT1,goodT2);
    
    %Find the list of features
    goodFeatures = [tgtMat.lin(uniqueTgts,2:end),tgtMat.circ(uniqueTgts,2:end)];
    
    %Find the featurewise differences between 'correct' links.
    goodFeatureDiffs1 = tgtMat.lin(goodT1,2:end) - pred1Mat.lin(goodP1,2:end);
    goodFeatureDiffs2 = tgtMat.lin(goodT2,2:end) - pred2Mat.lin(goodP2,2:end);
    circ1 = tgtMat.circ(goodT1,2:end) - pred1Mat.circ(goodP1,2:end);
    circ2 = tgtMat.circ(goodT2,2:end) - pred2Mat.circ(goodP2,2:end);
    goodFeatureDiffs1 = [goodFeatureDiffs1,mod(circ1 + 0.5,1) - 0.5];
    goodFeatureDiffs2 = [goodFeatureDiffs2,mod(circ2 + 0.5,1) - 0.5];
    goodFeatureDiffs = [goodFeatureDiffs1;goodFeatureDiffs2];
    
    covFs = cov(goodFeatures);
    covDfs = cov(goodFeatureDiffs);
    
    %MFs are the mean displacements from predicted for each of these link differences.
    linMs = mean(goodFeatureDiffs(:,1:size(tgtMat.lin,2)-1),1);
    tmp = goodFeatureDiffs(:,size(tgtMat.lin,2):end);
    if ~isempty(tmp)
        circMs = circ_mean(tmp,[],1);
    else
        circMs = [];
    end
    
    %Calculate and store trackability score
    detFrac = det(covFs)/det(covDfs);
    distFac = log2(pi*exp(1)/6);
    trackability = (1/2)*log2(detFrac) - (size(goodFeatures,2)/2)*distFac - log2(size(linFrameT,1)/2);
else
    linMs = [];
    circMs = [];
    covDfs = [];
    covFs = [];
    trackability = [];
end