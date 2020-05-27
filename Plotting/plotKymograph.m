function [exportData,axHands] = plotKymograph(procTracks,plotSettings,root,axHand)
%PLOTKYMOGRAPH plots a kymograph (space-time plot) of the specified object
%in each of the channels available from the input image.
%
%   INPUTS:
%       -procTracks: Tracks, generated by the diffusionTracker.m script
%       -plotSettings: Settings for plotting, generated by the user within
%       the plotting GUI
%       -root: A string specifying the root directory for the current
%       analysis
%       -axHand: A handle to the axis that the axis that you wish to be
%       plotting into.
%
%   OUTPUTS:
%       -exportData: kymograph data, in the form of a cell array with each cell
%       containing the kymograph for a single channel.
%       -axHands: Handles to each of the subaxes generated by this
%       function, each corresponding to a separate channel.
%
%   Author: Oliver J. Meacock, (c) 2019

axHand.Box = 'off';

%Start by figuring out how big a box you'll need to cut out from each frame, and where you should cut it out from
plotTrack = procTracks(plotSettings.edit1); %edit1 is the track ID input
xs = round(plotTrack.x./plotSettings.pixSize);
ys = round(plotTrack.y./plotSettings.pixSize);
Lens = plotTrack.majorLen./plotSettings.pixSize;
Wids = plotTrack.minorLen./plotSettings.pixSize;
Phis = plotTrack.phi;
Frames = plotTrack.times;

%Update Phis so it wraps around properly
Phis = wrapAngleTimecourse(Phis);

%Figure out how many channels there are
chanNo = 0;
dirNames = dir(root);
for i = 1:size(dirNames,1)
    if ~isempty(regexp(dirNames(i).name,'Channel_\d','ONCE'))
        chanNo = chanNo + 1;
    end
end

exportData = cell(chanNo + 1,1);

folderNames = {};
titleNames = {};

for i = 1:chanNo
    folderNames = [folderNames;['Channel_',num2str(i)]];
    titleNames = [titleNames;['Channel ',num2str(i)]];
end

%Rotate all cell images to align them
xWindowStage1 = ceil(max(Lens) + max(Wids));
yWindowStage1 = ceil(max(Lens) + max(Wids));

%Find the half window size
xHalfWindowStage1 = floor(xWindowStage1/2);
yHalfWindowStage1 = floor(yWindowStage1/2);
xWindowStage1 = xHalfWindowStage1*2 + 1;
yWindowStage1 = yHalfWindowStage1*2 + 1;

xWindowStage2 = ceil(max(Wids));
yWindowStage2 = ceil(max(Lens));

xHalfWindowStage2 = floor(xWindowStage2/2) + 1;
yHalfWindowStage2 = floor(yWindowStage2/2) + 1;
xWindowStage2 = xHalfWindowStage2*2 + 1;
yWindowStage2 = yHalfWindowStage2*2 + 1;

%Initialize the frames
for i = 1:size(folderNames,1)
    imgSet{i} = zeros(yWindowStage2,size(xs,1));
end

for i = 1:size(xs,1) %Loop through timepoints
    %We're going to chop out two images. The first is centred on the object, which can take any orientation. We rotate this and chop out the final cell from the rotated image.
    xMinStage1 = max(1,xs(i) - xHalfWindowStage1);
    xUnderhang = -(xs(i) - xHalfWindowStage1 - 1);
    xMaxStage1 = min(round(plotSettings.maxX/plotSettings.pixSize),xs(i) + xHalfWindowStage1);
    xOverhang = (xs(i) + xHalfWindowStage1) - round(plotSettings.maxX/plotSettings.pixSize);
    yMinStage1 = max(1,ys(i) - yHalfWindowStage1);
    yUnderhang = -(ys(i) - yHalfWindowStage1 - 1);
    yMaxStage1 = min(round(plotSettings.maxY/plotSettings.pixSize),ys(i) + yHalfWindowStage1);
    yOverhang = (ys(i) + yHalfWindowStage1) - round(plotSettings.maxY/plotSettings.pixSize);
    
    xMinStage2 = xHalfWindowStage1 - xHalfWindowStage2 + 1;
    xMaxStage2 = xHalfWindowStage1 + xHalfWindowStage2 + 1;
    yMinStage2 = yHalfWindowStage1 - yHalfWindowStage2 + 1;
    yMaxStage2 = yHalfWindowStage1 + yHalfWindowStage2 + 1;
    
    %Get the segmentation to act as a mask for each channel
    segFull = imread([root,filesep,'Segmentations',filesep,sprintf('Frame_%04d.tif',Frames(i)-1)]);
    stage1Seg = segFull(yMinStage1:yMaxStage1,xMinStage1:xMaxStage1);
    
    %Pad the cropped segmentation to full size, if the crop window is smaller than it should be in any direction
    if xUnderhang > 0
        stage1Seg = [zeros(size(stage1Seg,1),xUnderhang),stage1Seg];
    end
    if xOverhang > 0
        stage1Seg = [stage1Seg,zeros(size(stage1Seg,1),xOverhang)];
    end
    if yUnderhang > 0
        stage1Seg = [zeros(yUnderhang,size(stage1Seg,2));stage1Seg];
    end
    if yOverhang > 0
        stage1Seg = [stage1Seg;zeros(yOverhang,size(stage1Seg,2))];
    end
    rotSeg = imrotate(stage1Seg,90-Phis(i),'nearest','crop');
    stage2Seg = rotSeg(yMinStage2:yMaxStage2,xMinStage2:xMaxStage2);
    
    %Select largest single object within the segmentation chunk
    rps = regionprops(bwconncomp(stage2Seg,4),'Area','PixelList');
    maxInd = 1;
    for j = 2:size(rps,1)
        if rps(j).Area > rps(maxInd).Area
            maxInd = j;
        end
    end
    stage2Seg = bwselect(stage2Seg,rps(maxInd).PixelList(1,1),rps(maxInd).PixelList(1,2),4);
    
    se = strel('disk',1);
    stage2Seg = imdilate(stage2Seg,se);
    
    for j = 1:size(folderNames,1) %Loop through channels
        imgFull = imread([root,filesep,folderNames{j},filesep,sprintf('Frame_%04d.tif',Frames(i)-1)]);
        stage1 = imgFull(yMinStage1:yMaxStage1,xMinStage1:xMaxStage1);
        
        %Pad the cropped image to full size, if the crop window is smaller than it should be in any direction
        if xUnderhang > 0
            stage1 = [zeros(size(stage1,1),xUnderhang),stage1];
        end
        if xOverhang > 0
            stage1 = [stage1,zeros(size(stage1,1),xOverhang)];
        end
        if yUnderhang > 0
            stage1 = [zeros(yUnderhang,size(stage1,2));stage1];
        end
        if yOverhang > 0
            stage1 = [stage1;zeros(yOverhang,size(stage1,2))];
        end
        rotStage = imrotate(stage1,90-Phis(i),'bilinear','crop');
        stage2 = rotStage(yMinStage2:yMaxStage2,xMinStage2:xMaxStage2);
        stage2(~logical(stage2Seg)) = NaN;
        
        if plotSettings.check2 == 1 %Indicates that the user wants to normalise lengths (squish/stretch kymograph between the same limits for all timepoints).
            profile = nanmean(stage2,2);
            profLen = size(profile,1);
            currLen = Lens(i);
            maxLen = max(Lens);
            SF = currLen/maxLen;
            
            currInds = (1:size(profile,1))-(profLen/2); %Indices relative to the midpoint of the cell
            cutoutList = abs(currInds)<(currLen/2);
            cutoutInds = currInds(cutoutList);
            cutout = profile(cutoutList);
            scaledInds = (min(cutoutInds)+0.01):SF:(max(cutoutInds)-0.01);
            scaledProf = interp1(cutoutInds,cutout,scaledInds);
            
            %Pad scaled profile with zeros to ensure it fits within storage
            padSize = profLen - size(scaledProf,2);
            imgSet{j}(:,i) = [zeros(floor(padSize/2),1);scaledProf';zeros(ceil(padSize/2),1)];
        else
            imgSet{j}(:,i) = nanmean(stage2,2);
        end
    end
    exportData{j} = imgSet{j};
end

subplot(axHand)

%Deal with the colourmap
cmap = colormap(plotSettings.ColourMap);

for i = 1:size(folderNames,1)
    axHands(i) = subplot(size(folderNames,1),1,i);
    profLen = size(imgSet{i},1);
    
    if plotSettings.check2 == 1
        lenVals = linspace(-0.5,0.5,profLen);
        imagesc((0:size(imgSet{i},2)-1)*plotSettings.dt,lenVals,imgSet{i},'Parent',axHands(i))
    else
        lenVals = linspace((-profLen/2)*plotSettings.pixSize,(profLen/2)*plotSettings.pixSize,profLen);
        imagesc((0:size(imgSet{i},2)-1)*plotSettings.dt,lenVals,imgSet{i},'Parent',axHands(i))
        
        %If not equating lengths, indicate the cell limits using lines
        hold(axHands(i),'on')
        patchline((0:size(imgSet{i},2)-1)*plotSettings.dt,plotTrack.majorLen/2,'EdgeAlpha',0.6,'EdgeColor',[1,0,0],'LineWidth',2)
        patchline((0:size(imgSet{i},2)-1)*plotSettings.dt,-plotTrack.majorLen/2,'EdgeAlpha',0.6,'EdgeColor',[1,0,0],'LineWidth',2)
        hold(axHands(i),'off')
    end
    
    axHands(i).LineWidth = 1.5;
    
    colormap(axHands(i),cmap)
end

for i = 1:size(folderNames,1)
    pos = [0.33234,0.9434 - ((0.83351/size(folderNames,1))*i),0.62916,(0.83351/size(folderNames,1))-0.05];
    set(axHands(i),'Position',pos,'Units','normalized')
    title(axHands(i),titleNames{i})
    
    if plotSettings.check2 == 1
        ylabel(axHands(i),{'Distance from cell midpoint'; '(normalised)'})
    else
        ylabel(axHands(i),'Distance from cell midpoint')
    end
end

xlabel(axHands(end),'Time')