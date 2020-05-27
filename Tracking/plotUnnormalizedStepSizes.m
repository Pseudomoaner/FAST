function [] = plotUnnormalizedStepSizes(FeatMats,IncProp,StatsUse,trackability,axHandBig,axHandSmall)
%PLOTUNNORMALIZEDSTEPSIZES plots a histogram indicating the distribution of
%step sizes between objects in sequential frames, prior to normalisation of
%features. Also indicates the inclusion proportion cutoff with a red 
%vertical line.
%
%   INPUTS:
%       -FeatMats: Reformatted feature data, output by the
%       buildFeatureMatricesRedux function.
%       -IncProp: The user-selected proportion of highest-scoring training
%       links that should be included when calculating feature statistics.
%       -StatsUse: Whether the model is being trained using only the
%       centroid data, or all selected feature data. Can be the strings
%       'Centroid' or 'All'.
%`      -trackability: Either a scalar or a vector, indicating the
%       trackability score derived from the current dataset with the 
%       current model training parameters. One of the fields of the
%       linkStats structure, output by gatherLinkStats.
%       -axHandBig: Handle to the axes into which the main histogram should
%       be inserted.
%`      -axHandSmall: Handle to the axes into which the trackability should
%       be plotted.
%
%   Author: Oliver J. Meacock (c) 2019

%Find the full range of values that each of the linear variables can take
allFeats = [];
for i = 1:length(FeatMats.lin)
    allFeats = [allFeats;FeatMats.lin{i}(:,2:end)];
end
minFeats = min(allFeats,[],1);
maxFeats = max(allFeats,[],1);

unscaledDists = [];

for i = 1:length(FeatMats.lin) - 1
    if ~isempty(FeatMats.lin{i}) && ~isempty(FeatMats.lin{i+1})
        linFrame1 = FeatMats.lin{i}(:,2:end);
        linFrame2 = FeatMats.lin{i+1}(:,2:end);
        circFrame1 = FeatMats.circ{i}(:,2:end);
        circFrame2 = FeatMats.circ{i+1}(:,2:end);
        
        %Regularize the linear data, so it varies between 0 and 1. Is an approximate way of weighting all features equally, so you can get estimates of the statistics you need to weigh them more accurately later.
        linFrame1Reg = (linFrame1 - repmat(minFeats,size(linFrame1,1),1))./(repmat(maxFeats,size(linFrame1,1),1) - repmat(minFeats,size(linFrame1,1),1));
        linFrame2Reg = (linFrame2 - repmat(minFeats,size(linFrame2,1),1))./(repmat(maxFeats,size(linFrame2,1),1) - repmat(minFeats,size(linFrame2,1),1));
        
        switch StatsUse
            case 'Centroid'
                D = pdist2(linFrame1Reg(:,1:2),linFrame2Reg(:,1:2));
            case 'All'
                D1 = pdist2(linFrame1Reg,linFrame2Reg);
                D2 = pdistCirc2(circFrame1,circFrame2,ones(size(circFrame1,2),1));
                
                D = (D1.^2 + D2.^2).^0.5;
        end
        
        %Find the minimum distance between each Frame1 point and all Frame2 points
        distsTmp = min(D,[],2); %locsF2 is the row of each cell in frame 2
        
        unscaledDists = [unscaledDists;distsTmp];
    end
end

h1 = histogram(axHandBig,unscaledDists);
hold(axHandBig,'on')
h1.Normalization = 'pdf';
h1.LineWidth = 1;
ylabel(axHandBig,'PDF')
xlabel(axHandBig,'Unnormalized step size')
axHandBig.Box = 'on';
axHandBig.LineWidth = 1.5;

xLims = [0,prctile(unscaledDists,99.5)];
yLims = get(axHandBig,'YLim');
yLims(1) = 0;
plot(axHandBig,[prctile(unscaledDists,IncProp * 100),prctile(unscaledDists,IncProp * 100)],[0,yLims(2)],'Color','r','LineWidth',2)
axis(axHandBig,[xLims,yLims])

legend(axHandBig,'Steps','Inclusion proportion');

%Display trackability
plot(axHandSmall,1:size(trackability),trackability)
xlabel(axHandSmall,'Frame number','FontSize',10)
ylabel(axHandSmall,'Trackability (bits per object)','FontSize',10)
axis(axHandSmall,'tight')
axHandSmall.Box = 'on';
axHandSmall.LineWidth = 1.5;

hold(axHandBig,'off')