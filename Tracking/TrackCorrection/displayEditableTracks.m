function imgHand = displayEditableTracks(GUIsets,currTracks,trackTimes,fromMappings,toMappings,segDat,cScheme,axH)
%DISPLAYEDITABLETRACKS paints the given input image to provide the user
%with feedback assisting in the track correction process.
%
%   INPUTS:
%       -GUIsets: Structure of settings provided by the user via the
%       CorrectTracks GUI. Includes data indicating objects selected by the
%       user.
%       -currTracks: Tracks as they currently stand, including all
%       previously applied corrections. Each field contains a cell array,
%       with each cell indexed by track ID and containing each track's data
%       corresponding to the name of the field.
%       -trackTimes: Frames for each track, formatted as a cell array with
%       each cell containing one track's frames.
%       -fromMappings: Mappings from current track to frame representation
%       -toMappings: Mappings from frame to current track representation
%       -segDat: Structure containing the binary segmentations for all the
%       frames in the dataset.
%       -cScheme: N by 3 matrix, with first dimension indexing the object ID
%       and second indexing the RGB channel. Only used if 'Cut' option is
%       specified, in which case it is used to colour all the objects in the
%       current frame.
%       -axH: Handle to axes image should be displayed in
%
%   OUTPUTS:
%       -imgHand: Handle to the presented image.
%
%   Author: Oliver J. Meacock (c) 2019

cla(axH)

imgPath = [GUIsets.underlayDir,filesep,sprintf('Frame_%04d.tif',GUIsets.frame-1)];
img = double(imread(imgPath));

%Enforce 8-bit representation
img = ceil((img - min(img(:)))/(max(img(:))-min(img(:))) * 255);

rCh = img;
gCh = img;
bCh = img;

se = strel('disk',2);
switch GUIsets.mode
    case 'Cut' %In this case, plot ALL boundaries between this frame and the next.
        if GUIsets.minF <= GUIsets.frame && GUIsets.maxF >= GUIsets.frame %Only do something if the currently selected frame is in the user-selected range
            for i = 1:max(segDat.frames{1}(:))
                oneCell = segDat.frames{1} == i;
                bound = bwperim(oneCell);
                bound = imdilate(bound,se);
                
                trackID = toMappings{GUIsets.frame-GUIsets.minF+1}(i,1);
                
                rCh(bound) = cScheme(trackID,1);
                gCh(bound) = cScheme(trackID,2);
                bCh(bound) = cScheme(trackID,3);
            end
            
            if ~isempty(GUIsets.cutID) && GUIsets.frame == GUIsets.cutT
                oneCell = segDat.frames{1} == GUIsets.cutID;
                bound = bwperim(oneCell);
                bound = imdilate(bound,se);
                
                rCh(bound) = 255;
                gCh(bound) = 210;
                bCh(bound) = 0;
            end
            
            imgHand = image(uint8(cat(3,rCh,gCh,bCh)),'Parent',axH);
            hold on
            axis equal
            axis tight
            axH.Box = 'off';
            axH.XTick = [];
            axH.YTick = [];
            
            if isfield(currTracks,'Centroid')
                tgts = toMappings{GUIsets.frame-GUIsets.minF+1};
                for i = 1:size(tgts,1)
                    trackID = tgts(i,1);
                    trackFrm = tgts(i,2);
                    
                    if size(currTracks.Centroid{trackID},1) > trackFrm %If there is at least one frame after this one
                        currPos = round(currTracks.Centroid{trackID}(trackFrm,:)/GUIsets.pxSize);
                        nextPos = round(currTracks.Centroid{trackID}(trackFrm + 1,:)/GUIsets.pxSize);
                        posDiff = nextPos - currPos;
                        
                        plot(currPos(1),currPos(2),'.','Color',cScheme(trackID,:)/255,'MarkerSize',8)
                        plotarrow(currPos(1),currPos(2),posDiff(1),posDiff(2),cScheme(trackID,:)/255,2,axH)
                    end
                end
            end
        else
            imgHand = image(uint8(cat(3,rCh,gCh,bCh)),'Parent',axH);
            hold on
            axis equal
            axis tight
            axH.Box = 'off';
            axH.XTick = [];
            axH.YTick = [];
        end
    case 'Fuse' %In this case, plot the boundaries of only those objects with tracks beginning or ending in the given frame.
        %Find start and end times of all tracks
        starts = zeros(size(trackTimes));
        ends = zeros(size(trackTimes));
        for i = 1:size(trackTimes,2)
            starts(i) = trackTimes{i}(1);
            ends(i) = trackTimes{i}(end);
        end
        
        %Plot future start points in shifting shades of orange
        for i = 1:size(starts,2)
            if starts(i) < GUIsets.frame + GUIsets.forLook && starts(i) > GUIsets.frame
                objID = fromMappings{i}(1,2);
                
                oneCell = segDat.frames{starts(i) - GUIsets.frame + 1} == objID;
                bound = bwperim(oneCell);
                bound = imdilate(bound,se);
                
                offset = 1 - ((starts(i) - GUIsets.frame)/GUIsets.forLook)*0.5;
                
                rCh(bound) = round(255*offset);
                gCh(bound) = round(200*offset);
                bCh(bound) = round(0*offset);
            elseif starts(i) == GUIsets.frame
                objID = fromMappings{i}(1,2);
                
                oneCell = segDat.frames{1} == objID;
                bound = bwperim(oneCell);
                bound = imdilate(bound,se);
                
                offset = 1 - ((starts(i) - GUIsets.frame + 1)/GUIsets.forLook);
                
                rCh(bound) = 255;
                gCh(bound) = 150;
                bCh(bound) = 0;
            end
        end
        
        %Plot current end points in cyan
        for i = 1:size(ends,2)
            if ends(i) == GUIsets.frame
                objID = fromMappings{i}(end,2);
                
                oneCell = segDat.frames{1} == objID;
                bound = bwperim(oneCell);
                bound = imdilate(bound,se);
                
                %If this is also a start point, make the current
                %colouration stripy
                if starts(i) == GUIsets.frame
                    xs = repmat(1:size(segDat.frames{1},2),size(segDat.frames{1},1),1);
                    bound(rem(xs,6) < 3) = 0;
                end
                
                rCh(bound) = 0;
                gCh(bound) = 255;
                bCh(bound) = 255;
            end
        end
        
        %Plot selected fusion end in blue and fusion start in red
        if ~isempty(GUIsets.tgtT)
            if GUIsets.tgtT < GUIsets.frame + GUIsets.forLook && GUIsets.tgtT >= GUIsets.frame
                oneCell = segDat.frames{GUIsets.tgtT - GUIsets.frame + 1} == GUIsets.tgtID;
                bound = bwperim(oneCell);
                bound = imdilate(bound,se);
                
                rCh(bound) = 255;
                gCh(bound) = 0;
                bCh(bound) = 0;
            end
        end 
        
        if ~isempty(GUIsets.srcT)
            if GUIsets.srcT == GUIsets.frame
                oneCell = segDat.frames{1} == GUIsets.srcID;
                bound = bwperim(oneCell);
                bound = imdilate(bound,se);
                
                rCh(bound) = 0;
                gCh(bound) = 0;
                bCh(bound) = 255;
            end
        end
        
        imgHand = image(uint8(cat(3,rCh,gCh,bCh)),'Parent',axH);
        axis equal
        axis tight
        axH.Box = 'off';
        axH.XTick = [];
        axH.YTick = [];
end