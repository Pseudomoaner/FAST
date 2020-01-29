function [] = importBioformatsData(rootdir,imgName,metaStore)

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
    
    progressbar('Total completion','Current channel');
    
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
            
            progressbar((c-1)/noC,(t-1)/noT)
        end
    end
    
    progressbar(1,1)
    
    %Copy and save metadata
    omeMetadata = reader.getMetadataStore();
    metaStore.maxX = reader.getSizeX();
    metaStore.maxY = reader.getSizeY();
    metaStore.maxT = reader.getSizeT();
    
    if metaStore.maxT > 1 %May be processing a single frame, in which case time information won't exist
        metaStore.dt = double(omeMetadata.getPixelsTimeIncrement(0).value);
        metaStore.timeSym = omeMetadata.getPixelsTimeIncrement(0).unit().getSymbol();
    end
    
    if metaStore.upsample
        metaStore.dx = double(omeMetadata.getPixelsPhysicalSizeX(0).value)/2;
        metaStore.dy = double(omeMetadata.getPixelsPhysicalSizeY(0).value)/2;
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
    hErr = errordlg('This file does not appear to be readable by Bioformats. Please try again.','Bioformats import error');
    uiwait(hErr);
end