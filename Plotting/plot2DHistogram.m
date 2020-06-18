function plotExport = plot2DHistogram(plotSubs,plotSettings,pGs,root,axHand)
%PLOT2DHISTOGRAM plots a 2D histogram (heatmap) of the specified data.
%
%Options are:
%   Checkbox 1: Will use every datapoint in every track as the input
%   dataset, in place of just the whole-track average.
%   Edit box 2: Spacing of the heatmap in the x-direction
%   Edit box 3: Spacing of the heatmap in the y-direction
%
%   INPUTS:
%       -plotSubs: The sub-population(s) of track data that you want to 
%       plot. A 4x1 cell array, containing the specified data for all 
%       (cell 1) and each individual (cells 2-4) sub-population.
%       -plotSettings: Settings for plotting, generated by the user within
%       the plotting GUI
%       -pGs: Structure specifying the graphical settings you want to use
%       within this plot (Not actually used in this function).
%       -axHand: A handle to the axis that you want to plot into.
%
%   OUTPUTS:
%       -exportData: 2D histogram data, with the data for each population
%       split into a separate cell.
%
%   Author: Oliver J. Meacock, (c) 2019

hold(axHand,'on')
axHand.LineWidth = 2;
axHand.Box = 'on';

for i = 1:size(plotSubs,1)
    if ~isempty(plotSubs{i})
        xData = [];
        yData = [];
        for j = 1:size(plotSubs{i},2)
            if plotSettings.check1 == 1 %check1 corresponds to showing all datapoints (instead of whole-track means)
                %Some data fields (e.g. velocity) are second or greater order, and
                %are shorter than the first order fields. Need to trim to
                %fit.
                if size(plotSubs{i}(j).(plotSettings.data1),1) > size(plotSubs{i}(j).(plotSettings.data2),1)              
                xData = [xData;plotSubs{i}(j).(plotSettings.data1)(1:size(plotSubs{i}(j).(plotSettings.data2),1))];
                yData = [yData;plotSubs{i}(j).(plotSettings.data2)];
                elseif size(plotSubs{i}(j).(plotSettings.data1),1) < size(plotSubs{i}(j).(plotSettings.data2),1)
                    xData = [xData;plotSubs{i}(j).(plotSettings.data1)];
                    yData = [yData;plotSubs{i}(j).(plotSettings.data2)(1:size(plotSubs{i}(j).(plotSettings.data1),1))];
                else
                    xData = [xData;plotSubs{i}(j).(plotSettings.data1)];
                    yData = [yData;plotSubs{i}(j).(plotSettings.data2)];
                end
            else
                xData = [xData;nanmean(plotSubs{i}(j).(plotSettings.data1))];
                yData = [yData;nanmean(plotSubs{i}(j).(plotSettings.data2))];
            end
        end
        
        maxX = max(xData);
        minX = min(xData);
        maxY = max(yData);
        minY = min(yData);
        
        nX = ceil((maxX-minX)/plotSettings.edit2); %Edit 2 is the x-spacing
        nY = ceil((maxY-minY)/plotSettings.edit3); %Edit 3 is the y-spacing
        
        [Cnts,Ctrs] = hist3([yData,xData],'Nbins',[nY,nX]);
        
        plotExport.Counts = Cnts;
        plotExport.Centres = Ctrs;
        
        imagesc(axHand,Ctrs{2},Ctrs{1},Cnts)
        axHand.YDir = 'normal';
        
        %Deal with the colourmap
        cmap = colormap(plotSettings.ColourMap);
        upsample = floor(max(Cnts(:))./size(cmap,1));
        if upsample > 0
            cmapBig = [interp(cmap(:,1),upsample),interp(cmap(:,2),upsample),interp(cmap(:,3),upsample)];
            cmapBig(cmapBig>1) = 1;
            cmapBig(cmapBig<0) = 0;
        else
            cmapBig = cmap;
        end        
        cmapBig(1,:) = [1,1,1];
        colormap(axHand,cmapBig)
    end
end

xlabel(axHand,switchVarName(root,plotSettings.data1,'ptName','hsName'),'FontSize',15)
ylabel(axHand,switchVarName(root,plotSettings.data2,'ptName','hsName'),'FontSize',15)
axis(axHand,'tight')
hold(axHand,'off')