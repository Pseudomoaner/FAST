function [] = segmentAndSaveBatch(root,segmentParams)
%SEGMENTANDSAVEBATCH applys FAST's segmentation routine to every image in 
%the specified imaging dataset and saves results to the specified directory.
%
%   INPUTS:
%       -root: String specifying the root of the currently selected data directory
%       -segmentParams: Structure of parameters chosen within FAST's segmentation GUI,
%       specifying the options used during the segmentation routine.
%
%   Author: Oliver J. Meacock (c) 2019

frameCont = dir([root,filesep,'Channel_',num2str(segmentParams.segmentChan),filesep]);
noFrames = 0;
for i = 1:size(frameCont,1)
    if numel(regexp(frameCont(i).name,'Frame_\d{4}.tif')) == 1
        noFrames = noFrames + 1;
    end
end

inDir = [root,filesep,'Channel_',num2str(segmentParams.segmentChan),filesep];
outDir = [root,filesep,'Segmentations',filesep];
if ~exist(outDir,'dir')
    mkdir(outDir);
end

progressbar(0);

for j = 1:noFrames
    
    %Get brightfield image data
    currFrame = j - 1;
    img = double(imread([inDir,sprintf('Frame_%04d.tif',currFrame)]));
    %img = (img - min(img(:)))/(max(img(:)) - min(img(:)));
    
    %Set parameters
    MedFiltSize = 5;
    
    %Apply a median filter
    tempImg = medfilt2(img(:,:),[MedFiltSize,MedFiltSize]);
    
    if segmentParams.invert
        tempImg = max(tempImg(:))-tempImg;
    end
    
    %Apply texture analysis
    stdImg = stdfilt(tempImg,ones(segmentParams.Neighbourhood));
    kernel = ones(segmentParams.Neighbourhood) / segmentParams.Neighbourhood^2; % Mean kernel
    meanImg = conv2(tempImg, kernel, 'same'); % Convolve keeping size of I
    seImg = stdImg./(meanImg.^0.5); %Logic here is that dividing by meanImg gives COV. However, the COV itself scales as one over the square root of the image intensity (shot noise), so multiply by that number to get just the contribution from the cells.
    Texture = seImg > segmentParams.TextureThresh;
    
    seStre = strel('disk',(segmentParams.Neighbourhood-1)/2);
    Texture = imerode(Texture,seStre);
    
    %Do ridge-detection segmentation
    Ridges = bwRidgeCenterMod(tempImg,segmentParams.ridgeScale,segmentParams.ridgeThresh);
    se = strel('disk',segmentParams.ridgeErosion);
    Ridges = imerode(Ridges,se);
    Ridges = imdilate(Ridges,se);
    
    %Adjust the Ridges image to remove any tiny, disconnected bits of
    %ridges that might have sneaked in
    Ridges = bwareaopen(Ridges,segmentParams.RidgeAMin);
    
    tempSeg = and(Texture, ~Ridges);
    
    %Apply a watershed transform to the image:
    dists = -bwdist(~tempSeg);
    distA = imhmin(dists,segmentParams.waterThresh);
    distW = watershed(distA);
    
    tempSeg(distW == 0) = 0;
    
    %Clear boundary touching objects and assign a unique ID number to each segmented out cell
    tempSeg = imclearborder(tempSeg,4);
    tempSeg = imfill(tempSeg,'holes'); %Also fill in any holes that might appear in the cells as a result of ridge detection.
    
    %If requested, find the intensities of each object in this original
    %segmentation and apply a Gaussian-mixture model to split the high- from
    %low- intensity objects. Then delete any that are in the opposite peak from
    %what you are hoping to segment (e.g. if foreground colour is black, delete
    %any objects in the bright peak).
    if segmentParams.remHalos
        segment = bwlabel(tempSeg,4);
        
        if max(segment(:)) > 1 %Must be more than one object in segmentation, otherwise fitgmdist will complain
            objInts = zeros(max(segment(:)),1);
            for i = 1:max(segment(:))
                objInts(i) = mean(tempImg(segment(:) == i));
            end
            gmFit = fitgmdist(objInts,2);
            thresh = mean(gmFit.mu);
            remInds = find(objInts < thresh);
            
            for i = 1:size(remInds,1)
                tempSeg(segment == remInds(i)) = 0;
            end
            segment = bwlabel(tempSeg);
        end
    end
    
    %Measure areas of each object, and mark those that are too
    %small
    se = strel('disk',0);
    erodeImg = imerode(tempSeg,se);
    RPs = regionprops(erodeImg,'PixelList','Area');
    NoCCs = size(RPs);
    keepObjsX = [];
    keepObjsY = [];
    for i = 1:NoCCs(1)
        if RPs(i).Area > segmentParams.Alow
            keepObjsX = [keepObjsX;RPs(i).PixelList(1,1)];
            keepObjsY = [keepObjsY;RPs(i).PixelList(1,2)];
        end
    end
    tempSeg = bwselect(tempSeg,keepObjsX,keepObjsY,8);
    
    %If recursive watershed is selected, apply watershed algorithm repeatedly with
    %decreasing stringency to large objects. Otherwise, remove large objects directly.
    if segmentParams.waterRecur
        loopCnt = 1;
        stepRes = 4; %Controls how fine the step size of the recursive refinement of the watershed threshold should be.
        
        allAreas = vertcat(RPs.Area);
        tgtObjs = allAreas > segmentParams.Ahigh; %All objects that are currently too big
        while sum(tgtObjs) > 0
            %Apply more stringent watershed to currently too large objects
            for i = 1:size(RPs,1)
                if tgtObjs(i)
                    subObj = bwselect(tempSeg,RPs(i).PixelList(1,1),RPs(i).PixelList(1,2));
                    dists = -bwdist(~subObj);
                    distA = imhmin(dists,segmentParams.waterThresh - loopCnt/stepRes);
                    distW = watershed(distA);
                    
                    tempSeg(and(distW == 0,subObj)) = 0;
                end
            end
            
            %Recalculate area list with re-segmented objects.
            erodeImg = imerode(tempSeg,se);
            RPs = regionprops(erodeImg,'PixelList','Area');
            allAreas = vertcat(RPs.Area);
            tgtObjs = allAreas > segmentParams.Ahigh; %All objects that are currently too big
            
            loopCnt = loopCnt + 1;
        end
    else
        RPs = regionprops(erodeImg,'PixelList','Area');
        NoCCs = size(RPs);
        keepObjsX = [];
        keepObjsY = [];
        for i = 1:NoCCs(1)
            if RPs(i).Area < segmentParams.Ahigh
                keepObjsX = [keepObjsX;RPs(i).PixelList(1,1)];
                keepObjsY = [keepObjsY;RPs(i).PixelList(1,2)];
            end
        end
        tempSeg = bwselect(tempSeg,keepObjsX,keepObjsY,8);
    end
    
    %Do final labelling of each object
    segment = bwlabel(tempSeg);
    
    %Save the segmentation
    frameFName = [outDir,sprintf('Frame_%04d.tif',currFrame)];
    imwrite(segment,frameFName);
    
    %Update the user
    progressbar(j/noFrames);
end

save([root,filesep,'SegmentationSettings.mat'],'segmentParams')