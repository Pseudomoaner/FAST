function [] = densityScatter(x,y,nBins,smoothWind,cMap,axHand)
%DENSITYSCATTER creates a scatter plot, with each point coloured by the
%local density of the data.
%
%   INPUTS:
%       -x: Values for plotting on the x-axis
%       -y: Values for plotting on the y-axis
%       -nBins: Number of bins (both x and y directions)
%       -smoothWind: Size (std) of Gaussian kernal used to filter density
%       map. Can leave empty if you want to skip smoothing.
%       -cMap: String defining the built-in Matlab colormap you want to use
%       to color points.
%       -axHand: Handle to axis into which plot should be inserted
%
%   Author: Oliver J. Meacock, (c) 2020

[NRaw,cents] = hist3([x,y],'Nbins',[nBins,nBins]);

%Apply smoothing to density map, if requested
if ~isempty(smoothWind)
    N = imgaussfilt(NRaw,smoothWind);
else
    N = NRaw;
end

%Choice between using inbuilt colormap, or user-defined colormap
if ischar(cMap)
    cMapVals = colormap(cMap);
else
    cMapVals = cMap;
end

noCLevels = size(cMapVals,1);

%Map each bin to a specific color using a linear density mapping
maxN = max(N(:));
Nleveled = round((N*noCLevels)/maxN);

%Run through each colour level, and plot all points that belong to that
%colour level
hold(axHand,'on')

xCentList = cents{1};
yCentList = cents{2};
dx = xCentList(2) - xCentList(1);
dy = yCentList(2) - yCentList(1);
xEdgeList = [xCentList-dx/2,xCentList(end)+dx/2];
yEdgeList = [yCentList-dy/2,yCentList(end)+dy/2];

for c = 1:size(cMapVals,1)
    currC = cMapVals(c,:);
    currBins = (Nleveled+1) == c;
    currBins(NRaw == 0) = false; %Need this to avoid including bins that contain no points 
    [currBinsr,currBinsc] = ind2sub(size(Nleveled),find(currBins));
    
    currXLimsLo = xEdgeList(currBinsr); %Lower x-limit of bins of current shading
    currXLimsHi = xEdgeList(currBinsr+1); %Likewise for upper x-limit
    currYLimsLo = yEdgeList(currBinsc);
    currYLimsHi = yEdgeList(currBinsc+1);
    
    currPts = sum(and(and(x >= currXLimsLo, x <= currXLimsHi),and(y >= currYLimsLo, y <= currYLimsHi)),2);
    
    currScat = scatter(axHand,x(logical(currPts)),y(logical(currPts)),10,currC,'filled');
    
    currScat.MarkerEdgeColor = 'none';
end