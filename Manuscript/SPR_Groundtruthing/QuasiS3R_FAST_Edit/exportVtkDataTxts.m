function exportVtkDataTxts(trackableData,thisSimRoot,fieldSettings,tile,wrap)

outDir = [thisSimRoot,filesep,'VTK_exports'];
if ~exist(outDir,'dir')
    mkdir(outDir)
end

fNs = fieldnames(trackableData);

colNo = 0;
for i = 1:size(fNs,1)
    colNo = colNo + size(trackableData.(fNs{i}){1},2);
end

for i = 1:size(trackableData.(fNs{1}),2)
    fileFrame = [outDir,filesep,sprintf('Frame_%04d.mat',i)];
    rowNo = size(trackableData.(fNs{1}){i},1);
    
    if tile
        rowNoFull = rowNo * 9;
    else
        rowNoFull = rowNo;
    end
    
    savableMat = zeros(rowNoFull,colNo);
    
    for j = 1:size(trackableData.(fNs{1}){i},1)
        row = [];
        for k = 1:size(fNs,1)
            row = [row,trackableData.(fNs{k}){i}(j,:)];
        end
        
        %Apply wrapping of periodic boundary conditions for visualisation,
        %if requested
        if wrap(1)
            row(2) = mod(row(2) + fieldSettings.maxX/2,fieldSettings.maxX);
        end
        if wrap(2) 
            row(3) = mod(row(3) + fieldSettings.maxY/2,fieldSettings.maxY);
        end
        
        savableMat(j,:) = row;
        
        if tile
            %Apply periodic tiling
            savableMat(j + rowNo,:) = row;
            savableMat(j + rowNo,2) = savableMat(j + rowNo,2) + fieldSettings.maxX;
            savableMat(j + rowNo*2,:) = row;
            savableMat(j + rowNo*2,2) = savableMat(j + rowNo*2,2) - fieldSettings.maxX;
            savableMat(j + rowNo*3,:) = row;
            savableMat(j + rowNo*3,3) = savableMat(j + rowNo*3,3) + fieldSettings.maxY;
            savableMat(j + rowNo*4,:) = row;
            savableMat(j + rowNo*4,3) = savableMat(j + rowNo*4,3) - fieldSettings.maxY;
            savableMat(j + rowNo*5,:) = row;
            savableMat(j + rowNo*5,2) = savableMat(j + rowNo*5,2) + fieldSettings.maxX;
            savableMat(j + rowNo*5,3) = savableMat(j + rowNo*5,3) + fieldSettings.maxY;
            savableMat(j + rowNo*6,:) = row;
            savableMat(j + rowNo*6,2) = savableMat(j + rowNo*6,2) - fieldSettings.maxX;
            savableMat(j + rowNo*6,3) = savableMat(j + rowNo*6,3) + fieldSettings.maxY;
            savableMat(j + rowNo*7,:) = row;
            savableMat(j + rowNo*7,2) = savableMat(j + rowNo*7,2) - fieldSettings.maxX;
            savableMat(j + rowNo*7,3) = savableMat(j + rowNo*7,3) - fieldSettings.maxY;
            savableMat(j + rowNo*8,:) = row;
            savableMat(j + rowNo*8,2) = savableMat(j + rowNo*8,2) + fieldSettings.maxX;
            savableMat(j + rowNo*8,3) = savableMat(j + rowNo*8,3) - fieldSettings.maxY;
        end
    end
    save(fileFrame,'savableMat')
end

end