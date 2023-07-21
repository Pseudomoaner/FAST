function [gradXYZ,gradTheta,gradPhi] = calcPotentialGradsCompiled(inField)
%CALCPORENTIALGRADSCOMPILED uses the .mex version of the potential gradient
%calculation functions, if available.
%
%   INPUTS:
%       -inField: The input WensinkField object
%
%   OUTPUTS:
%       -gradXYZ: The potential gradient, x, y and z components.
%       -gradTheta: The potential gradient, for reorientations in the
%       xy-plane
%       -gradPhi: The potential gradient, for reorientations in the polar
%       angle (wrt the xy-plane).
%
%   Author: Oliver J. Meacock, (c) 2020

boundX = inField.xWidth/2;
boundY = inField.yHeight/2;
Height = inField.yHeight;
Width = inField.xWidth;
lam = inField.lam;
U0 = inField.U0;

includeMat = inField.cellDists < inField.distThresh;
includeMat(logical(diag(ones(length(includeMat),1)))) = 0;
includeMat = includeMat(1:length(inField.nCells),:); %Alpha rods should include all cells, beta rods all cells and all barrier rods

gradXYZ = zeros(length(inField.nCells),3);
gradTheta = zeros(length(inField.nCells),1);
gradPhi = zeros(length(inField.nCells),1);
for i = 1:length(inField.nCells) %The index of the cell alpha.
    %Get indices of cells that this cell (alpha) interacts with
    betInds = find(includeMat(i,:));
    xs = [inField.xCells;inField.xBarr]; xBets = xs(betInds);
    ys = [inField.yCells;inField.yBarr]; yBets = ys(betInds);
    zs = [inField.zCells;inField.zBarr]; zBets = zs(betInds);
    ns = [inField.nCells;inField.nBarr]; nBets = ns(betInds);
    ls = [inField.lCells;inField.lBarr]; lBets = ls(betInds);
    thets = [inField.thetCells;inField.thetBarr]; thetBets = thets(betInds);
    phis = [inField.phiCells;inField.phiBarr]; phiBets = phis(betInds);
    
    %Get dynamics
    
    if length(inField.aCells) >= 1
        xAlph = inField.xCells(i);
        yAlph = inField.yCells(i);
        zAlph = inField.zCells(i);
        lAlph = inField.lCells(i);
        nAlph = inField.nCells(i);
        thetAlph = inField.thetCells(i);
        phiAlph = inField.phiCells(i);
    end
    
    if strcmp(inField.boundConds,'none')
        [dUdx,dUdy,dUdz,dUdthet,dUdphi] = mexCalcEnergyGradients(xBets,yBets,zBets,lBets,nBets,thetBets,phiBets,xAlph,yAlph,zAlph,lAlph,nAlph,thetAlph,phiAlph,U0,lam,boundX,boundY,Width,Height);
    elseif strcmp(inField.boundConds,'periodic')
        [dUdx,dUdy,dUdz,dUdthet,dUdphi] = mexCalcEnergyGradientsPeriodic(xBets,yBets,zBets,lBets,nBets,thetBets,phiBets,xAlph,yAlph,zAlph,lAlph,nAlph,thetAlph,phiAlph,U0,lam,boundX,boundY,Width,Height);
    end
    
    gradXYZ(i,:) = -[sum(dUdx)/2,sum(dUdy)/2,sum(dUdz)/2];
    gradTheta(i) = -sum(dUdthet)/2;
    gradPhi(i) = -sum(dUdphi)/2; 
end