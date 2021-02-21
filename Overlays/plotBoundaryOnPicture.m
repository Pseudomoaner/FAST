function imgOut = plotBoundaryOnPicture(segment,img,data,Frame,pxSize,overlaySettings,colourmap,minData,maxData)
%PLOTMASKONPICTURE plots the masks (segmentations) of the selected
%frame for all objects at the specified time.
%
%   INPUTS:
%       -segment: segmentation image
%       -img: underlay image (in three channels)
%       -data: track data
%       -Frame: frame for display
%       -pxSize: size of pixels in units specified in metadata
%       -overlaySettings: other settings specifying the overlay (including
%       selected field in data).
%       -colourmap: string specifying identity of colourmap to use to colour
%       masks
%       -minData: value of lowest value of selected data field across all
%       tracks and times
%       -minData: value of greatest value of selected data field across all
%       tracks and times
%
%   Author: Oliver J. Meacock, (c) 2019

rCh = img(:,:,1);
gCh = img(:,:,2);
bCh = img(:,:,3);

cmap = colormap(overlaySettings.cmapName);

%Centroid of each segment should be equal to the position of each cell (based on how I calculate cell position). Can work backwards from this to find the segmentation corresponding to each cell
segFrame = bwlabeln(segment,8);
stats = regionprops(segFrame,'Centroid','PixelIdxList');

centres = [];
centIDs = [];
for i = 1:size(stats,1)
    centres = [centres;stats(i).Centroid];
    centIDs = [centIDs;i];
end

localTol = 1;

for cInd = 1:length(data)
    tInd = find(data(cInd).times == Frame);
    
    if ~isempty(tInd) %If cell is tracked in this frame, insert into image
        %Find colour cell should be marked as
        if strcmp(overlaySettings.info,'Data') 
            if strcmp(overlaySettings.data,'population') %Special case for population labels
                thisDat = data(cInd).population;
                thisInd = ceil((thisDat - minData)*size(cmap,1)/(maxData - minData));
                if thisInd == 0
                    thisInd = 1;
                end
                thisCol = cmap(thisInd,:);
            elseif tInd <= size(data(cInd).(overlaySettings.data),1) %This condition can be false if you're looking at a higher-order measurement (e.g. velocity) and you're near the end of the track
                thisDat = data(cInd).(overlaySettings.data)(tInd);
                thisInd = ceil((thisDat - minData)*size(cmap,1)/(maxData - minData));
                if thisInd == 0
                    thisInd = 1;
                end
                thisCol = cmap(thisInd,:);
            end
        elseif tInd <= size(data(cInd).x,1)
            thisCol = colourmap(cInd,:);
        end
        
        xPx = round(data(cInd).x(tInd)/pxSize);
        yPx = round(data(cInd).y(tInd)/pxSize);
        
        if data(cInd).interpolated(tInd) == 1 %If the current timepoint is an interpolated timepoint (so no corresponding mask) draw a circle instead of boundary
            rad = data(cInd).minorLen(tInd)/(pxSize*2);
            [rCh,gCh,bCh] = drawCircleOnImg(xPx,yPx,rad,rCh,gCh,bCh,thisCol);
        elseif data(cInd).interpolated(tInd) == 0
            segmentID = centIDs(and(and(centres(:,1) < xPx + localTol,centres(:,1) > xPx - localTol),and(centres(:,2) < yPx + localTol,centres(:,2) > yPx - localTol)));
            
            oneCell = segFrame == segmentID;
            bound = bwperim(oneCell);
            
            se = strel('disk',2);
            bound = imdilate(bound,se);
        
            if ~isempty(bound) %In principle, should never be empty. But best to be on the safe side.
                rCh(bound) = thisCol(1);
                gCh(bound) = thisCol(2);
                bCh(bound) = thisCol(3);
            end
        end
    end
end

imgOut = cat(3,rCh,gCh,bCh);