function [] = paintFieldReconstructionTwoPops(trackableData,dS,fS)

resolution = 0.2;

%Get the indicies of tracks of cells that have different parameters.
if std(trackableData.Force{1}) > 0.0001
    pop2 = trackableData.Force{1} > mean(trackableData.Force{1});
elseif std(trackableData.Length{1}) > 0.0001
    pop2 = trackableData.Length{1} > mean(trackableData.Length{1});
else
    error('Couldn''t find a second population!')
end

for i = 1:length(trackableData.Length)
    pop1cellImg = zeros(round(fS.fieldHeight/resolution),round(fS.fieldWidth/resolution));
    xs = trackableData.Centroid{i}(~pop2,1);
    ys = trackableData.Centroid{i}(~pop2,2);
    phis = rad2deg(trackableData.Orientation{i}(~pop2));
    majors = (cos(trackableData.Tilt{i}(~pop2)).*(trackableData.Length{i}(~pop2)-fS.lam) + fS.lam)/2;
    minors = repmat(fS.lam/2,size(xs,1),1);
    pop1cellImg = paintEllipse(pop1cellImg,xs,ys,majors,minors,phis,resolution);
    
    pop2cellImg = zeros(round(fS.fieldHeight/resolution),round(fS.fieldWidth/resolution));
    xs = trackableData.Centroid{i}(pop2,1);
    ys = trackableData.Centroid{i}(pop2,2);
    phis = rad2deg(trackableData.Orientation{i}(pop2));
    majors = (cos(trackableData.Tilt{i}(pop2)).*(trackableData.Length{i}(pop2)-fS.lam) + fS.lam)/2;
    minors = repmat(fS.lam/2,size(xs,1),1);
    pop2cellImg = paintEllipse(pop2cellImg,xs,ys,majors,minors,phis,resolution);
    
    fullImg = cat(3,pop2cellImg,or(pop1cellImg,pop2cellImg),pop1cellImg);
    
    Imgpath = sprintf(dS.ImgPath3,i);
    ImgpathTemp = [dS.imagedirectory, filesep, Imgpath];
    
    imwrite(fullImg,ImgpathTemp,'TIFF')
end