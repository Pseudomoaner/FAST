function [] = importBioformatsDataBatch(rootdir,imgName,metaStore)
%IMPORTBIOFORMATSDATABATCH uses Bioformats to import the user-specified 
%imaging dataset.
%
%   INPUTS:
%       -rootdir: String defining the location of the target root
%       directory.
%       -imgName: Name of the imaging dataset within this root directory,
%       with extension.
%       -metaStore: Metadata storage from a dataset that has already been
%       successfully read, and will act as the template for all future 
%       datasets. Contains import settings (upsampling etc.)
%
%   Author: Oliver J. Meacock (c) 2019

if isempty(metaStore)
    metaStore = struct();
end

%Allow Bioformats import
if ~isfield(metaStore,'upsample')
    butChoice = questdlg({'Upsample imaging data (useful for low magnification datasets)?','','Image path is:',fullfile(rootdir,imgName)},'Excuse me,');
    switch butChoice
        case 'Yes'
            metaStore.upsample = true;
        case 'No'
            metaStore.upsample = false;
        case 'Cancel'
            return
    end
end

%Load data
try
    reader = bfGetReader([rootdir,filesep,imgName]);
    noSeries = reader.getSeriesCount();
    %FAST only works if only one data series is present in the original data. If there is more than one, post warning message and process the first one.
    if noSeries > 1
        hErr = warndlg('FAST only supports single data series, and will process data for only the first series in this dataset. For processing multiple data series, please refer to the FAST documentation (https://mackdurham.group.shef.ac.uk/FAST_DokuWiki/dokuwiki/doku.php?id=extra:faqs#can_i_process_multi-position_datasets).','Multiple data series detected');
        uiwait(hErr)
    end
    reader.setSeries(0);
    noC = reader.getSizeC();
    noT = reader.getSizeT();
    noZ = reader.getSizeZ();
    %FAST only works with 2D data.
    if noZ > 1
        hErr = errordlg('FAST only works with 2D image sequences (number of Z planes in this dataset > 1). Please flatten dataset and retry, or run external 3D segmentation and feature extraction and refer to the FAST documentation to import (https://mackdurham.group.shef.ac.uk/FAST_DokuWiki/dokuwiki/doku.php?id=usage:advanced_usage#import_of_non-segmentable_objects).','Bioformats import error');
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
catch
    progressbar(1,1) %Make sure the modal loading bar has definitely closed
    hErr = errordlg({'This file does not appear to be readable by Bioformats. Please try again.','','Image path is:',fullfile(rootdir,imgName)},'Bioformats import error');
    uiwait(hErr);
    return
end
    
%Copy and save metadata
try
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
            hErr = warndlg({'Units of time were not available in image metadata. Please input values manually...','','Image path is:',fullfile(rootdir,imgName)},'Bioformats import error');
            uiwait(hErr);
            while ~(sum(isstrprop(timeData{1},'digit'))>0 && (sum(isstrprop(timeData{1},'digit')) + sum(timeData{1} == '.')) == numel(timeData{1})) || ~(isa(timeData{2},'string') || isa(timeData{2},'char'))                
                timeData = inputdlg({'Time increment','Units'},'Please input time units:');
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
        warning(['Image path is:',fullfile(rootdir,imgName)])
    end
catch
    progressbar(1,1) %Make sure the modal loading bar has definitely closed
    hErr = warndlg({'Physical units were not available in image metadata. Please input values manually...','','Image path is:',fullfile(rootdir,imgName)},'Bioformats import error');  
    uiwait(hErr);
    
    metaStore.maxX = reader.getSizeX();
    metaStore.maxY = reader.getSizeY();
    metaStore.maxT = reader.getSizeT();
    
    spCell = {'',''};
    while numel(spCell{1}) < 1 || numel(spCell{2}) < 1 || isnan(str2double(spCell{1}))
        spCell = inputdlg({'Number of spatial units per pixel:','Spatial symbol:'});
    end
    metaStore.dx = str2double(spCell{1});
    metaStore.dy = str2double(spCell{1});
    metaStore.xSym = spCell(2);
    metaStore.ySym = spCell(2);
    
    if metaStore.maxT > 1
        tCell = {'',''};
        while numel(tCell{1}) < 1 || numel(tCell{2}) < 1 || isnan(str2double(tCell{1}))
            tCell = inputdlg({'Number of time units between frames:','Time symbol:'});
        end
        metaStore.dt = str2double(tCell{1});
        metaStore.timeSym = tCell(2);
    end
end
progressbar(1,1) %Make sure the modal loading bar has definitely closed

metaName = [rootdir,filesep,'Metadata.mat'];
save(metaName,'metaStore')