function [] = plotLineageTrees(data,overlaySettings,axHand)
%PLOTLINEAGETREES overlays each lineage that intersects with the current
%timepoint on the given axes.
%
%   INPUTS:
%       -data: the procTracks structure, containing your track data. Must
%       include D1, D2 and M fields, indicating the two daughters and the
%       mother of the current track.
%       -overlaySettings: The user-defined settings, contained in a
%       structure generated by the overlayTester GUI
%       -axHand: Handle to the axes that you want to plot to.
%
%   Author: Oliver J. Meacock, (c) 2019

FrameNo = overlaySettings.showFrame + overlaySettings.frameOffset + 1;
cmap = colormap(overlaySettings.cmapName);

%Start by running the lineage reconstructions
maxA = 0; %Maximal (global) age
lineageCnt = 1;
allLinInds = {};
allLinLens = {};
for cInd = 1:size(data,2)
    if isempty(data(cInd).M)
        [linInds,linLens] = getLineageIndices(data,cInd,0);
        allLinInds{lineageCnt} = linInds;
        allLinLens{lineageCnt} = linLens;
        lineageCnt = lineageCnt + 1;
        
        if maxA < max(linLens)
            maxA = max(linLens);
        end
    end
end

for lInd = 1:size(allLinInds,2)
    
    %We only want to plot this lineage if it intersects the current timepoint
    minT = inf;
    maxT = 0;
    for lnInd = 1:size(allLinInds{lInd},1)
        cInd = allLinInds{lInd}(lnInd);
        if min(data(cInd).times) < minT
            minT = min(data(cInd).times);
        end
        if max(data(cInd).times) > maxT
            maxT = max(data(cInd).times);
        end
    end
    
    if minT < FrameNo && maxT > FrameNo %If that is the case...
        for lnInd = 1:size(allLinInds{lInd},1) %For each track in this lineage...
            cInd = allLinInds{lInd}(lnInd);
            currTInds = find(data(cInd).times(1:end-1) < FrameNo);
            for tInd = currTInds
                xCoords = data(cInd).x(tInd:tInd+1)/overlaySettings.pixSize;
                yCoords = data(cInd).y(tInd:tInd+1)/overlaySettings.pixSize;
                
                lineColInd = round(data(cInd).generationalAge(tInd)*size(cmap,1)/maxA);
                
                if lineColInd == 0
                    lineColInd = 1;
                end
                
                lineCol = cmap(lineColInd,:);
                
                plot(axHand,xCoords,yCoords,'Color','k','LineWidth',3.5)
                plot(axHand,xCoords,yCoords,'Color',lineCol,'LineWidth',1.5)
            end
            
            %Plot all the division events (if present)
            if ~isempty(data(cInd).D1) && FrameNo > data(cInd).times(end)
                dau1 = data(cInd).D1;
                dau2 = data(cInd).D2;
                
                %Only plot the division event if both daughters are
                %assigned to
                if ~isempty(dau1) && ~isempty(dau2)
                    xCoords = [data(dau1).x(1),data(cInd).x(end),data(dau2).x(1)]/overlaySettings.pixSize;
                    yCoords = [data(dau1).y(1),data(cInd).y(end),data(dau2).y(1)]/overlaySettings.pixSize;
                    
                    plot(axHand,xCoords,yCoords,'Color',lineCol,'LineWidth',4)
                end
            end
        end
    end
end