function imgOut = plotSegmentationOnPicture(segment,img,data,Frame,pxSize,colVecs)
%PLOTSEGMENTATIONONPICTURE is used during tracking/division detection validation. It paints all
%detected objects in the currently selected pair of sequential frames (1/2), using the
%defined input colours to identify successfully linked objects, and
%colouring unlinked objects yellow in frame A and magenta in frame B.
%
%   INPUTS:
%       -segment: The binary segmentation image for the current frame.
%       -img: The grayscale underlay image for the current frame. 
%       -data: Similar (and often identical to) procTracks, the set of
%       all tracks for this dataset. Not all need to contain the
%       currently selected pair of frames.
%       -Frame: Whether this is frame 1 or 2 (A or B) of the pair).
%       -pxSize: Physical size of pixels in images
%       -colVecs: N by 3 matrix of values between 0 and 1, where N is the
%       total number of tracks. Each row defines the RGB colour objects in
%       each track should be painted, if succesfully linked.
%
%   OUTPUTS:
%       -imgOut: Output painted image.
%
%   Author: Oliver J. Meacock (c) 2019

localTol = 2;

rCh = img(:,:,1);
gCh = img(:,:,2);
bCh = img(:,:,3);

%Centroid of each segment should be equal to the position of each cell (based on how I calculate cell position). Can work backwards from this to find the segmentation corresponding to each cell
segFrame = bwlabeln(segment,8);
stats = regionprops(segFrame,'Centroid');

centres = [];
for i = 1:size(stats,1)
    centres = [centres;stats(i).Centroid];
end

for cInd = 1:length(data) %Cell index
    if size(data(cInd).times,2) == 1 %If track only covers first or second (last) timepoint
        if data(cInd).times == 1 && Frame == 1 %If the track covers only the first of the two frames...
            xPx = round(data(cInd).x(1)/pxSize);
            yPx = round(data(cInd).y(1)/pxSize);
            
            goodX = and(round(centres(:,1)) <= xPx + localTol,round(centres(:,1)) >= xPx - localTol);
            goodY = and(round(centres(:,2)) <= yPx + localTol,round(centres(:,2)) >= yPx - localTol);
            
            segmentID = find(and(goodX,goodY));
            
            if ~isempty(segmentID)
                rCh(segFrame == segmentID) = 1; %Colour yellow
                gCh(segFrame == segmentID) = 1;
                bCh(segFrame == segmentID) = 0;
            end
            
        elseif data(cInd).times == 2 && Frame == 2 %If the track covers only the second of the two frames...
            xPx = round(data(cInd).x(1)/pxSize);
            yPx = round(data(cInd).y(1)/pxSize);
            
            goodX = and(round(centres(:,1)) <= xPx + localTol,round(centres(:,1)) >= xPx - localTol);
            goodY = and(round(centres(:,2)) <= yPx + localTol,round(centres(:,2)) >= yPx - localTol);
            
            segmentID = find(and(goodX,goodY));
            
            if ~isempty(segmentID)
                rCh(segFrame == segmentID) = 1; %Colour magenta
                gCh(segFrame == segmentID) = 0;
                bCh(segFrame == segmentID) = 1;
            end
          
        end
    elseif size(data(cInd).times,2) == 2
        tInd = find(data(cInd).times == Frame);
        xPx = round(data(cInd).x(tInd)/pxSize);
        yPx = round(data(cInd).y(tInd)/pxSize);

        goodX = and(round(centres(:,1)) <= xPx + localTol,round(centres(:,1)) >= xPx - localTol);
        goodY = and(round(centres(:,2)) <= yPx + localTol,round(centres(:,2)) >= yPx - localTol);
            
        segmentID = find(and(goodX,goodY));

        if ~isempty(segmentID)
            rCh(segFrame == segmentID) = colVecs(cInd,1);
            gCh(segFrame == segmentID) = colVecs(cInd,2);
            bCh(segFrame == segmentID) = colVecs(cInd,3);
        end
    end
end

imgOut = cat(3,rCh,gCh,bCh);