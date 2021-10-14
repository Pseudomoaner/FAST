function [] = segmentAndSave(root,debugSet,noFrames,segmentParams)
%SEGMENTANDSAVE applys FAST's segmentation routine to every image in the
%specified imaging dataset and saves results to the specified directory.
%
%   INPUTS:
%       -root: String specifying the root of the currently selected data directory
%       -debugSet: Whether FAST is currently in debug mode (true if so,
%       false if not).
%       -noFrames: Integer specifying the total number of frames in the 
%       currently selected dataset.
%       -segmentParams: Structure of parameters chosen within FAST's segmentation GUI,
%       specifying the options used during the segmentation routine.
%
%   Author: Oliver J. Meacock (c) 2019

inDir = [root,filesep,'Channel_',num2str(segmentParams.segmentChan),filesep];
outDir = [root,filesep,'Segmentations',filesep];
if ~exist(outDir,'dir')
    mkdir(outDir);
end

debugprogressbar(0,debugSet);

for j = 1:noFrames
    
    %Get brightfield image data
    currFrame = j - 1;
    img = double(imread([inDir,sprintf('Frame_%04d.tif',currFrame)]));
    
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
    
    %Measure areas of each object, and remove those that are too
    %small.
    se = strel('disk',0);
    erodeImg = imerode(tempSeg,se);
    RPs = regionprops(erodeImg,'PixelList','Area');
    NoCCs = size(RPs);
    usefulObjectsX = [];
    usefulObjectsY = [];
    for i = 1:NoCCs(1)
        if RPs(i).Area > segmentParams.Alow && RPs(i).Area < segmentParams.Ahigh
            usefulObjectsX = [usefulObjectsX;RPs(i).PixelList(1,1)]; %Conveniently eliminates any cells that do not have a centroid within the boundary of the cell - weird, curvy cells or joined cells.
            usefulObjectsY = [usefulObjectsY;RPs(i).PixelList(1,2)];
        end
    end
    tempSeg = bwselect(tempSeg,usefulObjectsX,usefulObjectsY,8);
    
    %Clear boundary touching objects and assign a unique ID number to each segmented out cell
    tempSeg = imclearborder(tempSeg,4);
    tempSeg = imfill(tempSeg,'holes'); %Also fill in any holes that might appear in the cells as a result of ridge detection.
    segment = bwlabel(tempSeg,4);
    
    %If requested, find the intensities of each object in this original
    %segmentation and apply a Gaussian-mixture model to split the high- from
    %low- intensity objects. Then delete any that are in the opposite peak from
    %what you are hoping to segment (e.g. if foreground colour is black, delete
    %any objects in the bright peak).
    if segmentParams.remHalos
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
    
    %Save the segmentation
    frameFName = [outDir,sprintf('Frame_%04d.tif',currFrame)];
    imwrite(segment,frameFName);
    
    %Update the user
    debugprogressbar(j/noFrames,debugSet);
end

save([root,filesep,'SegmentationSettings.mat'],'segmentParams')