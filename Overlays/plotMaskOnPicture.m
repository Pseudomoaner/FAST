function imgOut = plotMaskOnPicture(segment,img,data,Frame,pxSize,overlaySettings,colourmap,minData,maxData)
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
    
    if ~isempty(tInd) %If cell is tracked in this frame, use the segmentation as a mask
        xPx = round(data(cInd).x(tInd)/pxSize);
        yPx = round(data(cInd).y(tInd)/pxSize);
        
        segmentID = centIDs(and(and(centres(:,1) < xPx + localTol,centres(:,1) > xPx - localTol),and(centres(:,2) < yPx + localTol,centres(:,2) > yPx - localTol)));
        
        if ~isempty(segmentID) %In principle, should never be empty. But best to be on the safe side.
            if strcmp(overlaySettings.info,'Data')
                if tInd > size(data(cInd).(overlaySettings.data),1)
                    thisDat = data(cInd).(overlaySettings.data)(end);
                else
                    thisDat = data(cInd).(overlaySettings.data)(tInd);
                end
                
                if ~isnan(thisDat) %Always a small risk a fragment with NaN data has crept in...
                    thisInd = ceil((thisDat - minData)*size(cmap,1)/(maxData - minData));
                    if thisInd == 0
                        thisInd = 1;
                    end
                else
                    thisInd = 1;
                end
                thisCol = cmap(thisInd,:);
                
                rCh(stats(segmentID).PixelIdxList) = thisCol(1);
                gCh(stats(segmentID).PixelIdxList) = thisCol(2);
                bCh(stats(segmentID).PixelIdxList) = thisCol(3);
            elseif sum(colourmap(cInd,:)) ~= 3
                rCh(stats(segmentID).PixelIdxList) = colourmap(cInd,1);
                gCh(stats(segmentID).PixelIdxList) = colourmap(cInd,2);
                bCh(stats(segmentID).PixelIdxList) = colourmap(cInd,3);
            end
        end
    else %Otherwise, draw a circle on the frame based on an interpolation between the previously and next tracked points.
        tPre = find(data(cInd).times < Frame);
        tPost = find(data(cInd).times > Frame);
        if ~isempty(tPre) && ~isempty(tPost)
            tIndPre = tPre(end);
            tIndPost = tPost(1);
            
            tPre = data(cInd).times(tIndPre);
            tPost = data(cInd).times(tIndPost);
            
            tInterp = (Frame-tPre)/(tPost-tPre); %Factor to multiply interpolations by
            
            dX = data(cInd).x(tIndPost)-data(cInd).x(tIndPre);
            dY = data(cInd).y(tIndPost)-data(cInd).y(tIndPre);
            
            xPx = (data(cInd).x(tIndPre) + dX*tInterp)/pxSize;
            yPx = (data(cInd).y(tIndPre) + dY*tInterp)/pxSize;
            
            width = data(cInd).minorLen(tIndPre)/(pxSize*2);
            
            if strcmp(overlaySettings.info,'Data')
                if tPre > size(data(cInd).(overlaySettings.data),1)
                    thisDat = data(cInd).(overlaySettings.data)(end);
                else
                    thisDat = data(cInd).(overlaySettings.data)(tIndPre);
                end
                thisInd = ceil((thisDat - minData)*size(cmap,1)/(maxData - minData));
                if thisInd == 0
                    thisInd = 1;
                end
                thisCol = cmap(thisInd,:);
                
                [rCh,gCh,bCh] = drawCircleOnImg(xPx,yPx,width,rCh,gCh,bCh,thisCol);
            else
                [rCh,gCh,bCh] = drawCircleOnImg(xPx,yPx,width,rCh,gCh,bCh,colourmap(cInd,:));
            end
        end
    end
end

imgOut = cat(3,rCh,gCh,bCh);