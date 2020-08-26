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
    
    tempImg = and(Texture, ~Ridges);
    
    %Apply a watershed transform to the image:
    dists = -bwdist(~tempImg);
    distA = imhmin(dists,segmentParams.waterThresh);
    distW = watershed(distA);
    
    tempImg(distW == 0) = 0;
    
    %Measure areas of each object, and remove those that are too
    %small.
    se = strel('disk',0);
    erodeImg = imerode(tempImg,se);
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
    tempImg = bwselect(tempImg,usefulObjectsX,usefulObjectsY,8);
    
    %Clear boundary touching objects and assign a unique ID number to each segmented out cell
    tempImg = imclearborder(tempImg,4);
    segment = bwlabel(tempImg,4);
    
    %Save the segmentation
    frameFName = [outDir,sprintf('Frame_%04d.tif',currFrame)];
    imwrite(segment,frameFName);
    
    %Update the user
    progressbar(j/noFrames);
end

save([root,filesep,'SegmentationSettings.mat'],'segmentParams')