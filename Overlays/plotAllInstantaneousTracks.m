function [] = plotAllInstantaneousTracks(data,overlaySettings,colourmap,axHand,minData,maxData)
%PLOTALLINSTANTANEOUSTRACKS plots all tracks represented at the selected
%timepoint, colouring each segment according to the chosen colourmap.
%Tracks point backwards in time, becoming fainter the further back they go.
%
%   INPUTS: 
%       -data: procTrack data
%       -overlaySettings: settings structure that contains user defined
%       settings, including frame to display and data choice
%       -colourmap: string defining the colourmap to use 
%       -axHand: handle pointing to axes to plot to
%       -minData: minimum value across all tracks and timepoints of data field
%       selected for display (if applicable)
%       -maxData: maximum value across all tracks and timepoints of data field
%       selected for display (if applicable)
%
%   Author: Oliver J. Meacock, (c) 2019

FrameNo = overlaySettings.showFrame + overlaySettings.frameOffset + 1;
cmap = colormap(overlaySettings.cmapName); %Only gets used if the chosen information to be shown is 'Data'.

for cInd = 1:size(data,2)
    if FrameNo <= max(data(cInd).times) && FrameNo >= min(data(cInd).times) %If the frame number is within this track's limits
        [~,currInd] = min(abs(data(cInd).times - FrameNo));
    else
        currInd = [];
    end
    
    if ~isempty(currInd)
        remainingPos = [data(cInd).x(1:currInd),data(cInd).y(1:currInd)] / overlaySettings.pixSize;
        for j = 1:size(remainingPos,1)-1
            if strcmp(overlaySettings.info,'Data')
                if j > size(data(cInd).(overlaySettings.data),1)
                    thisDat = data(cInd).(overlaySettings.data)(end);
                else
                    thisDat = data(cInd).(overlaySettings.data)(j);
                end
                thisInd = ceil((thisDat - minData)*size(cmap,1)/(maxData - minData));
                if thisInd == 0
                    thisInd = 1;
                end
                thisCol = cmap(thisInd,:);
                %patchline([remainingPos(j,1),remainingPos(j+1,1)],[remainingPos(j,2),remainingPos(j+1,2)],'EdgeColor',thisCol,'linewidth',4,'edgealpha',j/size(remainingPos,1),'Parent',axHand)
                plot([remainingPos(j,1),remainingPos(j+1,1)],[remainingPos(j,2),remainingPos(j+1,2)],'Color',thisCol,'linewidth',1.5,'Parent',axHand)
            else
                %patchline([remainingPos(j,1),remainingPos(j+1,1)],[remainingPos(j,2),remainingPos(j+1,2)],'EdgeColor',colourmap(cInd,:),'linewidth',4,'edgealpha',j/size(remainingPos,1),'Parent',axHand)
                plot([remainingPos(j,1),remainingPos(j+1,1)],[remainingPos(j,2),remainingPos(j+1,2)],'Color',colourmap(cInd,:),'linewidth',1.5,'Parent',axHand)
            end
        end
        if strcmp(overlaySettings.info,'Data')
            if currInd > size(data(cInd).(overlaySettings.data),1)
                thisDat = data(cInd).(overlaySettings.data)(end);
            else
                thisDat = data(cInd).(overlaySettings.data)(currInd);
            end
            thisInd = ceil((thisDat - minData)*size(cmap,1)/(maxData - minData));
            if thisInd == 0
                thisInd = 1;
            end
            thisCol = cmap(thisInd,:);
            plot(axHand,remainingPos(end,1),remainingPos(end,2),'.','Color',thisCol,'MarkerSize',20)
        else
            plot(axHand,remainingPos(end,1),remainingPos(end,2),'.','Color',colourmap(cInd,:),'MarkerSize',20)
        end
    end
end