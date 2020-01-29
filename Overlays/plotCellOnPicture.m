function plotCellOnPicture(data,indexT,indexC,colVec,pxSize,scaleFactor,ellipseLineWidth,axHand)
%PLOTCELLONPICTURE generates the cell boundary reconstruction demanded by
%the 'ellipses' option in the overlay GUI. Applies it for a single object.
%
%   INPUTS:
%       -data: Equivalent to procTracks, the current track data.
%       -indexT: Time index (relative to the start of the currently
%       selected track) of the data you want to use for the current
%       reconstruction.
%       -indexC: Track index of the data you want to use for the current
%       reconstruction.
%       -colVec: Three element rgb vector indicating the currently selected
%       colour for the reconstruction.
%       -pxSize: Edge length (in physical units) of a single pixel.
%       -scaleFactor: How much you want to boost the size of the arrow. For
%       example, setting scaleFactor to 2 will make the plotted arrow twice
%       as big as the actual motion between the two frames.
%       -ellipseLineWidth: Width of the line used to plot the ellipse.
%       -axHand: Handle to the axes you want to plot the reconstruction
%       inside.
%
%   Author: Oliver J. Meacock (c) 2019

x = data(indexC).x(indexT)/pxSize;
y = data(indexC).y(indexT)/pxSize;
phi = pi/2 - deg2rad(data(indexC).phi(indexT));

if indexT < size(data(indexC).times,2) %If at last timepoint in track, won't have calculated a value for theta
    thet = - deg2rad(data(indexC).theta(indexT));
    vmag = data(indexC).vmag(indexT);
else
    thet = 0;
    vmag = 0;
end

len = data(indexC).majorLen(indexT)/(pxSize*2);
wid = data(indexC).minorLen(indexT)/(pxSize*2);

h = ellipse(wid,len,phi,x,y,colVec,[],axHand);

set(h,'LineWidth',ellipseLineWidth)

plotarrow(x,y,cos(thet),sin(thet),colVec,scaleFactor * vmag/pxSize,axHand);