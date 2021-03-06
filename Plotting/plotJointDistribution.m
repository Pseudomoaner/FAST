function plotExport = plotJointDistribution(plotSubs,plotSettings,pGs,root,axHand)
%PLOTJOINTDISTRIBUTION generates a scatter plot of two selected
%track-associated measures. Uses the whole-track average - to treat each
%timepoint within each track individually, use plot2dHistogram instead.
%
%Options are:
%   Checkbox 1: Will write the correlation coefficient between the two
%   variables for each pair of (currently selected) populations in the top
%   left-hand corner.
%   Checkbox 2: Will write the linear regression model for the current pair
%   of variables for each pair of (currently selected) populations in the
%   top left-hand corner.
%
%   INPUTS:
%       -plotSubs: The sub-population(s) of track data that you want to 
%       plot. A 4x1 cell array, containing the specified data for all 
%       tracks (cell 1) and each individual sub-population (cells 2-4).
%       -plotSettings: Settings for plotting, generated by the user within
%       the plotting GUI
%       -pGs: Structure specifying the graphical settings you want to use
%       within this plot.
%       -axHand: A handle to the axis that you want to plot into.
%
%   OUTPUTS:
%       -exportData: Data export - precise form depends on options selected
%       within plotSettings. In general, consists of 4 cells, each
%       containing a structure with data processed based on currently
%       selected options.
%
%   Author: Oliver J. Meacock (c) 2019

plotExport = cell(4,1);

hold(axHand,'on')
axHand.LineWidth = 2;
axHand.Box = 'on';

legCount = 1;
legNames = {};

for i = 1:size(plotSubs,1)
    xData = [];
    yData = [];
    for j = 1:size(plotSubs{i},2)
        if plotSettings.check3 %check3 corresponds to showing all points in the chosen field (rather than just the mean)
            minSize = min(size(plotSubs{i}(j).(plotSettings.data1),1),size(plotSubs{i}(j).(plotSettings.data2),1));
            
            xData = [xData;plotSubs{i}(j).(plotSettings.data1)(1:minSize)];
            yData = [yData;plotSubs{i}(j).(plotSettings.data2)(1:minSize)];
        else
            xData = [xData;mean(plotSubs{i}(j).(plotSettings.data1))];
            yData = [yData;mean(plotSubs{i}(j).(plotSettings.data2))];
        end
    end
    
    if ~isempty(xData)
        if plotSettings.check4 %check4 corresponds to showing the local density of the scatter using colour
            %Get a symbol for the legend - will be plotted over later
            legH(legCount) = plot(axHand,xData(1),yData(1),pGs.pointStyles{i},'MarkerEdgeColor',pGs.plotColours{i},'MarkerSize',12);
            legNames = [legNames;pGs.popTags{i}];
            legCount = legCount + 1;
            
            %Compile a colourmap for this population
            baseC = pGs.plotColours{i};
            noCs = 65;
            
            lgtC = 0.5 + baseC/2;
            drkC = baseC/2;
            
            sampPts = [1,(noCs+1)/2,noCs];
            thisCmap = interp1(sampPts,[lgtC;baseC;drkC],1:noCs);
            
            densityScatter(xData,yData,300,3,thisCmap,axHand)
        else
            legH(legCount) = plot(axHand,xData,yData,pGs.pointStyles{i},'MarkerEdgeColor',pGs.plotColours{i},'MarkerSize',12);
            legNames = [legNames;pGs.popTags{i}];
            legCount = legCount + 1;
        end
    end
    
    plotExport{i}.xData = xData;
    plotExport{i}.yData = yData;
    
    if plotSettings.check1 == 1 && ~isempty(xData) %check1 corresponds to correlation coefficent showing
        [r,p] = corr(xData,yData,'rows','complete','Type','Spearman');
        text(0.01,0.98-0.05*(i-1),['r = ',num2str(r)],'Units','normalized','Color',pGs.plotColours{i},'FontSize',15)
        text(0.01,0.98-0.05*(i-1)-0.025,['p = ',num2str(p)],'Units','normalized','Color',pGs.plotColours{i},'FontSize',15)
        
        plotExport{i}.rho = r;
        plotExport{i}.p = p;
    end
    
    if plotSettings.check2 == 1 && ~isempty(yData) %check2 corresponds to plotting linear model
        X = [ones(size(xData,1),1),xData];
        b = X\yData;
        
        linX = linspace(min(xData),max(xData),100);
        linY = linX * b(2) + b(1);
        
        legH(legCount) = plot(axHand,linX,linY,'Color',pGs.plotColours{i},'LineWidth',2);
        legNames = [legNames;[pGs.popTags{i},' fit']];
        legCount = legCount + 1;
        
        plotExport{i}.linFit = b;
    end
end

if plotSettings.legendSwitch == 1
    legend(legH,legNames)
end
xlabel(axHand,switchVarName(root,plotSettings.data1,'ptName','hsName'),'FontSize',15)
ylabel(axHand,switchVarName(root,plotSettings.data2,'ptName','hsName'),'FontSize',15)
hold(axHand,'off')