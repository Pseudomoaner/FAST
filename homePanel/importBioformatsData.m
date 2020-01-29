function [] = importBioformatsData(rootdir,imgName,metaStore,debugSet)
%IMPORTBIOFORMATSDATA uses Bioformats to import the user-specified imaging
%dataset.
%
%   INPUTS:
%       -rootdir: String defining the location of the target root
%       directory.
%       -imgName: Name of the imaging dataset within this root directory,
%       with extension.
%       -metaStore: Metadata storage, can be left empty if metadata hasn't
%       been read yet. Also contains import settings (upsampling etc.)
%       -debugSet: Whether you are in debug mode (true) or not (false).
%
%   Author: Oliver J. Meacock (c) 2019

if isempty(metaStore)
    metaStore = struct();
end

%Allow Bioformats import
if ~isfield(metaStore,'upsample')
    butChoice = questdlg('Upsample imaging data (useful for low magnification datasets)?','Excuse me,');
    switch butChoice
        case 'Yes'
            metaStore.upsample = true;
        case 'No'
            metaStore.upsample = false;
        case 'Cancel'
            return
    end
end

try
    reader = bfGetReader([rootdir,filesep,imgName]);
    noSeries = reader.getSeriesCount();
    %FAST only works if only one data series is present in the original data. If there is more than one, post warning message and process the first one.
    if noSeries > 1
        hErr = warndlg('The FAST GUI only supports single data series, and will process data for only the first series in this dataset. For processing multiple data series, please refer to the FAST batch processing documentation.','Multiple data series detected');
        uiwait(hErr)
    end
    reader.setSeries(0);
    noC = reader.getSizeC();
    noT = reader.getSizeT();
    noZ = reader.getSizeZ();
    %FAST only works with 2D data.
    if noZ > 1
        hErr = errordlg('FAST only works with 2D image sequences (number of Z planes in this dataset > 1). Please flatten dataset and retry, or run external 3D segmentation and feature extraction and use the tracking GUI directly.','Bioformats import error');
        uiwait(hErr)
        return
    end
    
    debugprogressbar([0;0],debugSet);
    
    for c = 1:noC
        chanRoot = [rootdir,filesep,'Channel_',num2str(c)]; %Name of the output channel directory
        if ~exist(chanRoot,'dir')
            mkdir(chanRoot)
        end
        
        for t = 1:noT
            imgName = [chanRoot,filesep,sprintf('Frame_%04d.tif',t-1)];
            iPlane = reader.getIndex(0,c-1,t-1)+1;
            I = double(bfGetPlane(reader, iPlane));
            
            if metaStore.upsample
                I = interp2(I,1);
            end
            
            I = uint16(I);
            
            imwrite(I,imgName);
            
            debugprogressbar([(c-1)/noC;(t-1)/noT],debugSet)
        end
    end
    
    debugprogressbar([1;1],debugSet)
    
    %Copy and save metadata
    omeMetadata = reader.getMetadataStore();
    metaStore.maxX = reader.getSizeX();
    metaStore.maxY = reader.getSizeY();
    metaStore.maxT = reader.getSizeT();
    
    if metaStore.maxT > 1 %May be processing a single frame, in which case time information won't exist
        try
            metaStore.dt = double(omeMetadata.getPixelsTimeIncrement(0).value);
            metaStore.timeSym = omeMetadata.getPixelsTimeIncrement(0).unit().getSymbol();
        catch
            timeData = cell(2,1);
            while ~(sum(isstrprop(timeData{1},'digit'))>0 && sum(isstrprop(timeData{1},'digit')) == numel(timeData{1})) || ~(isa(timeData{2},'string') || isa(timeData{2},'char'))
                timeData = inputdlg({'Time increment','Units'},'Time information not available in image metadata. Please input manually:');
            end
            
            metaStore.dt = str2double(timeData{1});
            metaStore.timeSym = timeData{2};
        end
    else
        metaStore.dt = NaN;
        metaStore.timeSym = NaN;
    end
    
    if metaStore.upsample
        metaStore.dx = double(omeMetadata.getPixelsPhysicalSizeX(0).value)/2;
        metaStore.dy = double(omeMetadata.getPixelsPhysicalSizeY(0).value)/2;
        metaStore.maxX = metaStore.maxX * 2;
        metaStore.maxY = metaStore.maxY * 2;
    else
        metaStore.dx = double(omeMetadata.getPixelsPhysicalSizeX(0).value);
        metaStore.dy = double(omeMetadata.getPixelsPhysicalSizeY(0).value);
    end
    metaStore.xSym = omeMetadata.getPixelsPhysicalSizeX(0).unit().getSymbol();
    metaStore.ySym = omeMetadata.getPixelsPhysicalSizeY(0).unit().getSymbol();
    
    if metaStore.dx ~= metaStore.dy || ~strcmp(metaStore.ySym,metaStore.xSym)
        warning('X and Y dimension resolutions are different! FAST will use the x-dimension resolution for both, but some tracked values may need adjustment after processing.')
    end
    
    metaName = [rootdir,filesep,'Metadata.mat'];
    save(metaName,'metaStore')
catch
    debugprogressbar([1;1],debugSet) %Make sure the modal loading bar has definitely closed
    hErr = errordlg('This file does not appear to be readable by Bioformats. Please try again.','Bioformats import error');
    uiwait(hErr);
end