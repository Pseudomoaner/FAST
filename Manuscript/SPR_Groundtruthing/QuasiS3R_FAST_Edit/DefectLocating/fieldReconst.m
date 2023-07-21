function cellImg = fieldReconst(trackableData,fS,pS,frameInd)

cellImg = zeros(round(fS.fieldHeight/pS.pixSize),round(fS.fieldWidth/pS.pixSize));
xs = trackableData.Centroid{frameInd}(:,1);
ys = trackableData.Centroid{frameInd}(:,2);
phis = rad2deg(trackableData.Orientation{frameInd});
majors = (cos(trackableData.Tilt{frameInd}).*(trackableData.Length{frameInd}-fS.lam) + fS.lam)/2;
minors = repmat(fS.lam/2,size(xs,1),1);
cellImg = paintEllipse(cellImg,xs,ys,majors,minors,phis,ones(size(xs)),pS.pixSize,fS.boundaryConditions,fS.fieldWidth,fS.fieldHeight);