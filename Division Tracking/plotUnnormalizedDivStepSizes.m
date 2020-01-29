function [] = plotUnnormalizedDivStepSizes(tgtMat,pred1Mat,pred2Mat,statsUse,IncProp,trackability,axHand)
%PLOTUNNORMALIZEDDIVSTEPSIZES plots a histogram indicating the distribution 
%of step sizes between objects in sequential frames, prior to normalisation
%of features. Also indicates the inclusion proportion cutoff with a red 
%vertical line.
%
%   INPUTS:
%       -tgtMat: The 'target' matrix, indicating the true feature values of
%       all daughter cells across all time points.
%       -pred1Mat: The first 'prediction' matrix, indicating the predicted
%       feature values of daughter cells based on the values of the mothers
%       in the dataset.
%       -pred2Mat: The second 'prediction' matrix.
%       -StatsUse: Whether the model is being trained using only the
%       centroid data, or all selected feature data. Can be the strings
%       'Centroid' or 'All'.
%       -IncProp: The user-selected proportion of highest-scoring training
%       links that should be included when calculating feature statistics.
%`      -trackability: A scalar, indicating the trackability score derived 
%       from the current dataset with the current model training 
%       parameters. One of the outputsof the gatherDivisionStats function.
%       -axHand: Handle to the axes into which histogram should be placed
%
%   Author: Oliver J. Meacock (c) 2019

%Find the full range of values that each of the linear variables can take
maxFeats = max([tgtMat.lin(:,2:end);pred1Mat.lin(:,2:end);pred2Mat.lin(:,2:end)],[],1);
minFeats = min([tgtMat.lin(:,2:end);pred1Mat.lin(:,2:end);pred2Mat.lin(:,2:end)],[],1);

if ~isempty(tgtMat.lin) && ~isempty(pred1Mat.lin)
    linFrameT = tgtMat.lin(:,2:end);
    linFrameP1 = pred1Mat.lin(:,2:end);
    linFrameP2 = pred2Mat.lin(:,2:end);
    circFrameT = tgtMat.circ(:,3:end);
    circFrameP1 = pred1Mat.circ(:,3:end);
    circFrameP2 = pred2Mat.circ(:,3:end);
    
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
    sameT = TT == TP;
    
    D1(sameT) = Inf;
    D2(sameT) = Inf;
    
    %Find the minimum distance between each Frame1 point and all Frame2 points
    distsTmp1 = min(D1,[],2); %locsF2 is the row of each cell in frame 2
    distsTmp2 = min(D2,[],2);
    
    unscaledDists = [distsTmp1;distsTmp2];
end

h1 = histogram(axHand,unscaledDists);
hold(axHand,'on')
h1.Normalization = 'probability';
ylabel(axHand,'PDF')
xlabel(axHand,'Unnormalized step size')

xLims = [0,prctile(unscaledDists,99.9)];
yLims = get(axHand,'YLim');
plot(axHand,[prctile(unscaledDists,IncProp * 100),prctile(unscaledDists,IncProp * 100)],[0,1],'Color','r')
axis(axHand,[xLims,yLims])

legend(axHand,'Steps','Inclusion proportion');

%Display trackability
text(axHand,xLims(2) - (diff(xLims)*0.35), yLims(2) - (diff(yLims)*0.17),['R = ',num2str(trackability)],'FontSize',15)

hold(axHand,'off')