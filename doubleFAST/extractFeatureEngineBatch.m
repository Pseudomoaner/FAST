function extractFeatureEngineBatch(root,featSettings)

cellFeaturesPath = [root,filesep,'CellFeatures.mat'];

segmentRoot = [root,filesep,'Segmentations',filesep];

%If metadata from the bioformats import exists, use that. Otherwise, try to get it from the .tif image metadata. If that fails too, get it from the user.
metaRoot = [root,filesep,'Metadata.mat'];
if exist(metaRoot,'file')
    load(metaRoot)
    featSettings.maxX = metaStore.maxX * metaStore.dx;
    featSettings.maxY = metaStore.maxY * metaStore.dx;
    featSettings.pixSize = metaStore.dx;
    
    maxT = metaStore.maxT;
    if isfield(featSettings,'dt')
        featSettings.dt = metaStore.dt;
    elseif maxT > 1
        inputdlg('Temporal resolution not available in image metadata. Please manually insert number of time units between frames:');
    end
else
    bfRoot = [root,filesep,'Channel_1',filesep];
    bfPath = [bfRoot,sprintf('Frame_%04d.tif',0)];
    imgInfo = imfinfo(bfPath);
    
    %Various image parameters
    if isempty(imgInfo(1).XResolution)
        tmpCell = inputdlg('Pixel resolution not available in image metadata. Please manually insert number of spatial units per pixel:');
        featSettings.pixSize = str2double(tmpCell{1});
    else
        featSettings.pixSize = 1/(imgInfo(1).XResolution);
    end
    featSettings.maxX = imgInfo(1).Width * featSettings.pixSize;
    featSettings.maxY = imgInfo(1).Height * featSettings.pixSize;
    
    if ~isfield(featSettings,'dt')
        tmpCell = inputdlg('Temporal resolution not available in image metadata. Please manually insert number of time units between frames:');
        featSettings.dt = str2double(tmpCell{1});
    end
    
    frameCont = dir(bfRoot);
    frameCount = 0;
    for i = 1:size(frameCont,1)
        if numel(regexp(frameCont(i).name,'Frame_\d{4}.tif')) == 1
            frameCount = frameCount + 1;
        end
    end
    
    maxT = frameCount;
end

%Storage for different components of the extracted cell profiles
if featSettings.Centroid == 1
    Centroids = cell(maxT,1);
end
if featSettings.Orient == 1
    Orientations = cell(maxT,1);
end
if featSettings.Length == 1
    Lengths = cell(maxT,1);
end
if featSettings.Width == 1
    Widths = cell(maxT,1);
end
if featSettings.Area == 1
    Areas = cell(maxT,1);
end
if numel(featSettings.MeanInc) >= 1
    ChannelMeans = cell(maxT,1);
end
if numel(featSettings.StdInc) >= 1
    ChannelStds = cell(maxT,1);
end

progressbar(0,0);

for i = 1:maxT
    %Load the segmentation and (if needed) the original channel frames.
    segFrame = imread([segmentRoot,sprintf('Frame_%04d.tif',i-1)]);
    segFrame = bwlabeln(segFrame,8);
    
    if numel(featSettings.MeanInc) > 0 || numel(featSettings.StdInc) > 0
        chanFrames = cell(featSettings.noChannels,1);
        
        for chan = 1:featSettings.noChannels
            chanRoot = [root,filesep,sprintf('Channel_%01d',chan),filesep];
            chanFrame = double(imread([chanRoot,sprintf('Frame_%04d.tif',i-1)]));
            chanFrames{chan,1} = chanFrame;
        end
        
        %Initialize feature storage
        ChannelMeans{i} = zeros(max(segFrame(:)),numel(featSettings.MeanInc));
        ChannelStds{i} = zeros(max(segFrame(:)),numel(featSettings.StdInc));
    end
    
    if featSettings.Centroid == 1
        Centroids{i} = zeros(max(segFrame(:)),2);
    end
    if featSettings.Orient == 1
        Orientations{i} = zeros(max(segFrame(:)),1);
    end
    if featSettings.Length == 1
        Lengths{i} = zeros(max(segFrame(:)),1);
    end
    if featSettings.Width == 1
        Widths{i} = zeros(max(segFrame(:)),1);
    end
    if featSettings.Area == 1
        Areas{i} = zeros(max(segFrame(:)),1);
    end
    
    segMax = max(segFrame(:));
    stats = regionprops(segFrame,'Centroid','Area','BoundingBox'); %You're almost certainly going to need the bounding box - may as well get the centroid while you're at it, even if it goes unused.
    for Seg = 1:segMax
        %Measure properties of each cell
        oneCell = segFrame == Seg;
        if sum(oneCell(:)) < 20 %Generally, feature detection is going to be pretty terrible if object is too small relative to the pixel area. This is a fairly arbitrary threshold, which in principle should be guarunteed by sensible segmentation parameters anyway.
            if featSettings.Centroid == 1
                Centroids{i}(Seg,:) = stats(Seg).Centroid * featSettings.pixSize;
            end
            if featSettings.Length == 1
                Lengths{i}(Seg) = NaN;
            end
            if featSettings.Width == 1
                Widths{i}(Seg) = NaN;
            end
            if featSettings.Area == 1
                Areas{i}(Seg) = stats(Seg).Area * (featSettings.pixSize^2);
            end
            if featSettings.Orient == 1
                Orientations{i}(Seg) = NaN;
            end
            if numel(featSettings.MeanInc) > 0
                %Insert measured cell properties into appropriate storage locations
                ChannelMeans{i}(Seg,:) = nan(1,numel(featSettings.MeanInc));
            end
            if numel(featSettings.StdInc) > 0
                ChannelStds{i}(Seg,:) = nan(1,numel(featSettings.StdInc));
            end
        else
            BB = stats(Seg).BoundingBox;
            BB = round(BB);
            SubSeg = oneCell(BB(2):BB(2)+BB(4)-1,BB(1):BB(1)+BB(3)-1);
            
            if featSettings.Orient == 1 || featSettings.Length == 1 || featSettings.Width == 1 %The rotation operation takes the most time, so only do it if absolutely necessary.
                switch featSettings.morphologyAlg
                    case 1
                        [Orient,Length,Width] = rotationMeasures(SubSeg);
                    case 2
                        [Orient,Length,Width] = rotationMeasuresMaxPerimDist(SubSeg);
                end
                Orient = -Orient;
            end
            
            if numel(featSettings.MeanInc) > 0 || numel(featSettings.StdInc) > 0
                
                cellIntensities = zeros(1,numel(featSettings.MeanInc));
                cellStds = zeros(1,numel(featSettings.StdInc));
                
                usedChans = union(featSettings.StdInc,featSettings.MeanInc);
                
                meanInd = 1;
                stdInd = 1;
                for chan = usedChans'
                    SubImg = chanFrames{chan,1}(BB(2):BB(2)+BB(4)-1,BB(1):BB(1)+BB(3)-1);
                    imgInts = SubImg(logical(SubSeg));
                    
                    if ~isempty(find(featSettings.MeanInc == chan,1))
                        cellIntensities(1,meanInd) = mean(imgInts);
                        meanInd = meanInd + 1;
                    end
                    if ~isempty(find(featSettings.StdInc == chan,1))
                        cellStds(1,stdInd) = std(imgInts);
                        stdInd = stdInd + 1;
                    end
                end
                
                %Insert measured cell properties into appropriate storage locations
                ChannelMeans{i}(Seg,:) = cellIntensities;
                ChannelStds{i}(Seg,:) = cellStds;
                
            end
            
            if featSettings.Centroid == 1
                Centroids{i}(Seg,:) = stats(Seg).Centroid * featSettings.pixSize;
            end
            if featSettings.Length == 1
                Lengths{i}(Seg) = Length * featSettings.pixSize;
            end
            if featSettings.Width == 1
                Widths{i}(Seg) = Width * featSettings.pixSize;
            end
            if featSettings.Area == 1
                Areas{i}(Seg) = stats(Seg).Area * (featSettings.pixSize^2);
            end
            if featSettings.Orient == 1
                Orientations{i}(Seg) = Orient;
            end
        end
    end
    progressbar(i/maxT)
end

progressbar(1)

%Package data into a single structure and save
trackableData = struct();
if featSettings.Centroid == 1
    trackableData.Centroid = Centroids;
end
if featSettings.Orient == 1
    trackableData.Orientation = Orientations;
end
if featSettings.Length == 1
    trackableData.Length = Lengths;
end
if featSettings.Width == 1
    trackableData.Width = Widths;
end
if featSettings.Area == 1
    trackableData.Area = Areas;
end
if numel(featSettings.MeanInc) > 0
    trackableData.ChannelMean = ChannelMeans;
end
if numel(featSettings.StdInc) > 0
    trackableData.ChannelStd = ChannelStds;
end

save(cellFeaturesPath,'-v7.3','maxT','trackableData','featSettings')

%If there is only one timepoint available, still want to make data
%available for plotting and overlays. Convert to 'Tracks.mat' format for
%this.

featNames = fieldnames(trackableData);
if size(trackableData.(featNames{1}),1) == 1
    for i = 1:size(Centroids{1},1)
        if ~isnan(Lengths{1}(i)) %This ensures that any NaNs output by the ellipse detection code don't contaminate the pseudotracks.
            if featSettings.Centroid == 1
                procTracks(i).x = Centroids{1}(i,1);
                procTracks(i).y = Centroids{1}(i,2);
            end
            if featSettings.Orient == 1
                procTracks(i).phi = Orientations{1}(i);
            end
            if featSettings.Length == 1
                procTracks(i).majorLen = Lengths{1}(i);
            end
            if featSettings.Width == 1
                procTracks(i).minorLen = Widths{1}(i);
            end
            if featSettings.Area == 1
                procTracks(i).area = Areas{1}(i);
            end
            if numel(featSettings.MeanInc) > 0
                for chan = 1:size(featSettings.MeanInc,1)
                    fieldMean = ['channel_',num2str(featSettings.StdInc(chan)),'_mean'];
                    procTracks(i).(fieldMean) = ChannelMeans{1}(i,chan);
                end
            end
            if numel(featSettings.StdInc) > 0
                for chan = 1:size(featSettings.StdInc,1)
                    fieldStd = ['channel_',num2str(featSettings.StdInc(chan)),'_std'];
                    procTracks(i).(fieldStd) = ChannelStds{1}(i,chan);
                end
            end
            procTracks(i).times = 1;
        end
    end
    
    trackSettings.pixSize = featSettings.pixSize;
    trackSettings.maxX = featSettings.maxX;
    trackSettings.maxY = featSettings.maxY;
    trackSettings.minFrame = 0;
    trackSettings.maxFrame = 0;
    trackSettings.dt = 1;
    trackSettings.pseudoTracks = true;
    
    toMappings = cell(1);
    toMappings{1} = nan(size(procTracks));
    
    fromMappings = [];
    
    save([root,filesep,'Tracks.mat'],'-v7.3','procTracks','trackSettings','toMappings','fromMappings')
end