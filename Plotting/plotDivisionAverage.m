function plotExport = plotDivisionAverage(plotSubdivisions,plotSettings,pGs,root,axHand)
%PLOTDIVISIONAVERAGE plots the average of many different tracks, centred
%automatically detected division events. Divisions are detected using the
%division detection module.
%
%   INPUTS:
%       -plotSubs: The sub-population(s) of track data that you want to 
%       plot. A 4x1 cell array, containing the specified data for all 
%       (cell 1) and each individual (cells 2-4) sub-population.
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

plotExport = cell(4,1);

hold(axHand,'on')
axHand.LineWidth = 2;
axHand.Box = 'on';

legCount = 1;
legNames = {};

for i = 1:size(plotSubdivisions,1)
    maxLen = 0;
    for j = 1:size(plotSubdivisions{i},2)
        if max(plotSubdivisions{i}(j).times) - min(plotSubdivisions{i}(j).times) > maxLen
            maxLen = max(plotSubdivisions{i}(j).times) - min(plotSubdivisions{i}(j).times);
        end
    end
    
    if rem(maxLen,2) ~= 0 %Make sure maxLen is even
        maxLen = maxLen + 1;
    end
    halfMaxLen = maxLen/2;
    
    divFrame = NaN(size(plotSubdivisions{i},2),maxLen);
    for j = 1:size(plotSubdivisions{i},2)
        if ~isempty(plotSubdivisions{i}(j).D1) && ~isempty(plotSubdivisions{i}(j).D2) %ie this track ends at division's beginning
            half2Inds = floor(size(plotSubdivisions{i}(j).(plotSettings.data1),1)/2)+1:size(plotSubdivisions{i}(j).(plotSettings.data1),1);
            if ~isempty(half2Inds)
                half2Times = plotSubdivisions{i}(j).times(half2Inds);
                %Add to half2Times so they index up to halfMaxLen
                regTimes = half2Times + (halfMaxLen - half2Times(end))+1;
                divFrame(j,regTimes) = plotSubdivisions{i}(j).(plotSettings.data1)(half2Inds);
            end
        end
        if ~isempty(plotSubdivisions{i}(j).M) %ie this track begins at division's end
            half1Inds = 1:floor(size(plotSubdivisions{i}(j).(plotSettings.data1),1)/2);
            if ~isempty(half1Inds)
                half1Times = plotSubdivisions{i}(j).times(half1Inds);
                %Add to half2Times so they index from halfMaxLen
                regTimes = half1Times - half1Times(1) + halfMaxLen + 1;
                divFrame(j,regTimes) = plotSubdivisions{i}(j).(plotSettings.data1)(half1Inds);
            end
        end
    end
    timeVals = (-halfMaxLen+0.5:halfMaxLen-0.5)*plotSettings.dt;
    
    dataMeans = nanmean(divFrame,1);
    nanMeans = isnan(dataMeans);
    timeVals(isnan(dataMeans)) = [];
    dataMeans(isnan(dataMeans)) = [];
    
    if plotSettings.check2 == 1 && ~isempty(dataMeans)%Corresponds to showing all traces (vs. just the mean trace)
        plotExport{i}.subTimes = cell(size(plotSubdivisions{i},2),1);
        plotExport{i}.subData = cell(size(plotSubdivisions{i},2),1);
        for j = 1:size(divFrame,1)
            notNanInds = ~isnan(divFrame(j,~nanMeans));
            subTimes = timeVals(notNanInds);
            tmpData = divFrame(j,~nanMeans);
            subData = tmpData(notNanInds);         
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
    elseif ~isempty(dataMeans)
        legH(legCount) = plot(axHand,timeVals,dataMeans,pGs.lineStyles{i},'Color',pGs.plotColours{i},'LineWidth',2);
        legNames = [legNames;[pGs.popTags{i},' means']];
        legCount = legCount + 1;
        
        plotExport{i}.dataMeans = dataMeans;
        plotExport{i}.times = timeVals;
    end
    
    if plotSettings.check1 == 1 && ~isempty(dataMeans) %check1 corresponds to error area showing
        dataStd = nanstd(divFrame,0,1);
        dataStd(isnan(dataStd)) = [];
        
        areaY = [dataMeans'-dataStd',2*dataStd'];
        
        h = area(timeVals',areaY,'EdgeColor','none');
        h(1).FaceColor = [1,1,1];
        h(2).FaceColor = pGs.plotColours{i};
        h(1).FaceAlpha = 0;
        h(2).FaceAlpha = 0.5;
        
        legH(legCount) = h(2);
        legNames = [legNames;[pGs.popTags{i},' s.d.']];
        legCount = legCount + 1;
        
        plotExport{i}.dataStd = dataStd;
    end
    
end

if plotSettings.legendSwitch == 1
    legend(legH,legNames)
end

[tSym,~] = getDimensionalSymbols(root);

xlabel(axHand,['Time relative to division / ',tSym{1}],'FontSize',15)
ylabel(axHand,switchVarName(root,plotSettings.data1,'ptName','hsName'),'FontSize',15)
hold(axHand,'off')