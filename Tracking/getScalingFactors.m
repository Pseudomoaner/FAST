function [linEs,circEs,linDs,circDs,linMs,circMs,trackability] = getScalingFactors(linFeatMats,circFeatMats,includeProportion,statsUse)
%GETSCALINGFACTORS calculates the crowding and dispersions of all features
%in a dataset, and uses these to calculate feature weightings (SFs). It
%also calculates the mean drift between frames.
%
%   INPUTS:
%       -linFeatMats: Cell array, containing matrices of all linear
%       features for each timepoint.
%       -circFeatMats: Cell array, containing matrices of all circular
%       features for each timepoint.
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
%       -trackability: Trackability score for each timepoint
%
%       For more details on these statistics, please see:
%       https://mackdurham.group.shef.ac.uk/FAST_DokuWiki/dokuwiki/doku.php?id=usage:tracking_algorithm
%
%   Author: Oliver J. Meacock (c) 2019

%Find the full range of values that each of the linear variables can take
allFeats = [];
for i = 1:length(linFeatMats)
    allFeats = [allFeats;linFeatMats{i}(:,2:end),circFeatMats{i}(:,2:end)];
end
minFeats = min(allFeats(:,1:size(linFeatMats{1},2)-1),[],1);
maxFeats = max(allFeats(:,1:size(linFeatMats{1},2)-1),[],1);

groupedMat = [];

for i = 1:length(linFeatMats) - 1
    if ~isempty(linFeatMats{i}) && ~isempty(linFeatMats{i+1})
        linFrame1 = linFeatMats{i}(:,2:end);
        linFrame2 = linFeatMats{i+1}(:,2:end);
        if size(circFeatMats{i},2) > 1
            circFrame1 = circFeatMats{i}(:,2:end);
            circFrame2 = circFeatMats{i+1}(:,2:end);
        else
            circFrame1 = zeros(size(circFeatMats{i},1),1);
            circFrame2 = zeros(size(circFeatMats{i+1},1),1);
        end
        
        %Regularize the linear data, so it varies between 0 and 1. Is an approximate way of weighting all features equally, so you can get estimates of the statistics you need to weigh them more accurately later.
        linFrame1Reg = (linFrame1 - repmat(minFeats,size(linFrame1,1),1))./(repmat(maxFeats,size(linFrame1,1),1) - repmat(minFeats,size(linFrame1,1),1));
        linFrame2Reg = (linFrame2 - repmat(minFeats,size(linFrame2,1),1))./(repmat(maxFeats,size(linFrame2,1),1) - repmat(minFeats,size(linFrame2,1),1));
        
        %Decide if user wants to use all features or just the centroid
        switch statsUse
            case 'Centroid'
                D = pdist2(linFrame1Reg(:,1:2),linFrame2Reg(:,1:2));
            case 'All'
                D1 = pdist2(linFrame1Reg,linFrame2Reg);
                D2 = pdistCirc2(circFrame1,circFrame2,ones(size(circFrame1,2),1));
                
                D = (D1.^2 + D2.^2).^0.5;
        end
        
        %Find the minimum distance between each Frame1 point and all Frame2 points
        [distsTmp,locsF2] = min(D,[],2); %locsF2 is the row of each cell in frame 2
        locsF1 = (1:size(D,1))'; %Take a guess
        
        groupedMat = [groupedMat;distsTmp,locsF1,locsF2,i*ones(size(distsTmp))];
    end
end

linMs = zeros(length(linFeatMats) - 1,size(linFeatMats{1},2) - 1);
circMs = zeros(length(linFeatMats) - 1,size(circFeatMats{1},2) - 1);
linEs = zeros(length(linFeatMats) - 1,size(linFeatMats{1},2) - 1);
circEs = zeros(length(linFeatMats) - 1,size(circFeatMats{1},2) - 1);
linDs = zeros(length(linFeatMats) - 1,size(linFeatMats{1},2) - 1);
circDs = zeros(length(linFeatMats) - 1,size(circFeatMats{1},2) - 1);
trackability = zeros(length(linFeatMats) - 1,1);

for i = 1:size(linFeatMats,1) - 1
    if size(linFeatMats{i},1) <= 1 %If no (or only a single object) in frame, don't really care about doing adjustments. Tracking should be obvious. Set measures to be very unstringent (but not e.g. Inf, as they would be if you didn't deal with this special case)
        trackability(i) = NaN;
        
        linEs(i,:) = 100;
        circEs(i,:) = 100;
        linDs(i,:) = 0.0001;
        circDs(i,:) = 0.0001;
        linMs(i,:) = 0;
        circMs(i,:) = 0;
    else
        currMatInds = groupedMat(:,4) == i;
        subMat = groupedMat(currMatInds,:);
        sortedSubMat = sortrows(subMat,1); %Sort by distance
        
        %Assume the n% closest objects are accurately linked - base mean adjustment values on these links.
        goodSubInds = 1:round(size(sortedSubMat,1)*includeProportion);
        if numel(goodSubInds) < 2 %To do stats, need at least two links to be assigned when at least two objects are in frame. Can't really define a standard deviation otherwise.
            goodSubInds = 1:2;
        end
        goodSubF1 = sortedSubMat(goodSubInds,2);
        goodSubF2 = sortedSubMat(goodSubInds,3);
        goodSubFrameNo = sortedSubMat(goodSubInds,4);
        goodSubFeatureDiffs = zeros(length(goodSubInds),size(linFeatMats{1},2)-1 + size(circFeatMats{1},2)-1);
        badInds = [];
        for j = goodSubInds
            goodSubFeatureDiffs(j,1:size(linFeatMats{1},2)-1) = linFeatMats{goodSubFrameNo(j)}(goodSubF1(j),2:end) - linFeatMats{goodSubFrameNo(j)+1}(goodSubF2(j),2:end);
            circSubDiff = circFeatMats{goodSubFrameNo(j)}(goodSubF1(j),2:end) - circFeatMats{goodSubFrameNo(j)+1}(goodSubF2(j),2:end);
            goodSubFeatureDiffs(j,size(linFeatMats{1},2):end) = mod(circSubDiff + 0.5,1) - 0.5;
            
            if sum(isnan(goodSubFeatureDiffs(j,:)))>0 %If you've got any NaNs in this frame (can occur if you have badly extracted object features)
                badInds = [badInds;j];
            end
        end
        goodSubFeatureDiffs(badInds,:) = [];
        
        frameIQRs = [iqr(linFeatMats{i}(:,2:end),1),iqr(circFeatMats{i}(:,2:end),1)];
        
        %It's not implausible that there's only a single object to
        %track within frame. If so, Dispersals will be 0, which could
        %be problematic. Use dummy values to solve.
        if size(sortedSubMat,1) == 1
            Dispersals = 0.01*ones(1,size(goodSubFeatureDiffs,2));
            Extents = 0.01*ones(1,size(goodSubFeatureDiffs,2));
        elseif size(sortedSubMat,1) > 1
            Dispersals = std(goodSubFeatureDiffs,[],1);
            Extents = (2*frameIQRs);
        end
        trackability(i) = -log10(size(sortedSubMat,1)/(prod(Extents./Dispersals)));
        
        linEs(i,:) = Extents(1:size(linFeatMats{1},2)-1);
        circEs(i,:) = Extents(size(linFeatMats{1},2):end);
        linDs(i,:) = Dispersals(1:size(linFeatMats{1},2)-1);
        circDs(i,:) = Dispersals(size(linFeatMats{1},2):end);
        
        linMs(i,:) = mean(goodSubFeatureDiffs(:,1:size(linFeatMats{1},2)-1),1);
        tmp = goodSubFeatureDiffs(:,size(linFeatMats{1},2):end);
        if ~isempty(tmp)
            circMs(i,:) = circ_mean(tmp,[],1);
        end
    end
end