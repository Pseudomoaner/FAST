function [negDefCents,negDefOris,posDefCents,posDefOris] = measureDefects(trackableData,fieldSettings,procSettings)

negDefCents = cell(size(trackableData.Centroid,1),1);
posDefCents = cell(size(trackableData.Centroid,1),1);
posDefOris = cell(size(trackableData.Centroid,1),1);
negDefOris = cell(size(trackableData.Centroid,1),1);

for i = 1:size(trackableData.Centroid,2)
    imgDat = fieldReconst(trackableData,fieldSettings,procSettings,i);
    oriDat = findImageOrients(imgDat,procSettings.tensorSize/procSettings.pixSize);
    
    oriX = cos(oriDat);
    oriY = -sin(oriDat);
    
    [posDefCents{i},negDefCents{i},posDefOris{i},negDefOris{i}] = analyseDefects(oriX,oriY,0,false);
    
    posDefCents{i} = flip(posDefCents{i},2)*procSettings.pixSize;
    negDefCents{i} = flip(negDefCents{i},2)*procSettings.pixSize;
end