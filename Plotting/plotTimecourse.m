function plotExport = plotTimecourse(plotSubs,plotSettings,pGs,root,axHand)
%PLOTTIMECOURSE plots the currently selected track-associated variable over
%time, either averaging by timepoint or showing all traces separately
%
%Options are:
%   Checkbox 1: Will display a shaded area, indicating the standard
%   deviation of the currently selected variable at each timepoint
%   (measured across all tracks at that timepoint)
%   Checkbox 2: Will plot each track individually, instead of summarising
%   as a single average line
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
    timeFrame = NaN(plotSettings.maxF,size(plotSubs{i},2));
    for j = 1:size(plotSubs{i},2)
        timeFrame(plotSubs{i}(j).times(1:size(plotSubs{i}(j).(plotSettings.data1),1)),j) = plotSubs{i}(j).(plotSettings.data1);
    end
    timeVals = (0:plotSettings.maxF-1)*plotSettings.dt;
    
    dataMeans = nanmean(timeFrame,2);
    timeVals(isnan(dataMeans)) = [];
    dataMeans(isnan(dataMeans)) = [];
    
    if plotSettings.check2 == 1 && ~isempty(timeFrame) %Corresponds to showing all traces (vs. just the mean trace)
        plotExport{i}.subTimes = cell(size(plotSubs{i},2),1);
        plotExport{i}.subData = cell(size(plotSubs{i},2),1);
        for j = 1:size(plotSubs{i},2)
            subTimes = plotSubs{i}(j).times(1:size(plotSubs{i}(j).(plotSettings.data1),1)) * plotSettings.dt;
            subData = plotSubs{i}(j).(plotSettings.data1);
            
            if j == 1
                legH(legCount) = plot(axHand,subTimes,subData,pGs.lineStyles{i},'Color',pGs.plotColours{i},'LineWidth',0.5);
                legNames = [legNames;pGs.popTags{i}];
                legCount = legCount + 1;
            else
                plot(axHand,subTimes,subData,pGs.lineStyles{i},'Color',pGs.plotColours{i},'LineWidth',0.5)
            end
            
            plotExport{i}.subTimes{j} = subTimes;
            plotExport{i}.subData{j} = subData;
        end
    elseif ~isempty(timeFrame)
        legH(legCount) = plot(axHand,timeVals,dataMeans,pGs.lineStyles{i},'Color',pGs.plotColours{i},'LineWidth',2);
        legNames = [legNames;pGs.popTags{i},' mean'];
        legCount = legCount + 1;
        
        plotExport{i}.dataMeans = dataMeans;
        plotExport{i}.times = timeVals;
    end
    
    if plotSettings.check1 == 1 && ~isempty(dataMeans) %check1 corresponds to error area showing
        dataStd = nanstd(timeFrame,0,2);
        dataStd(isnan(dataStd)) = [];
        
        areaY = [dataMeans-dataStd,2*dataStd];
        
        h = area(timeVals',areaY,'EdgeColor','none');
        h(1).FaceColor = [1,1,1];
        h(2).FaceColor = pGs.plotColours{i};
        h(1).FaceAlpha = 0;
        h(2).FaceAlpha = 0.5;
        
        legH(legCount) = h(2);
        legNames = [legNames;pGs.popTags{i},' s.d.'];
        legCount = legCount + 1;
        
        plotExport{i}.dataStd = dataStd;
    end
    
end

if plotSettings.legendSwitch == 1
    legend(legH,legNames)
end

[tSym,~] = getDimensionalSymbols(root);

xlabel(axHand,['Time / ',tSym{1}],'FontSize',15)
ylabel(axHand,switchVarName(root,plotSettings.data1,'ptName','hsName'),'FontSize',15)
hold(axHand,'off')