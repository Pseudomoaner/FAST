function [fT,fR] = calcFrictionTensors(a,u,f0)
%Calculates the translational and rotational friction tensors for each cell.
[fPar,fPerp,fRot] = calcGeomFactors(a);
fR = f0 * fRot;
fT = zeros(3,3,size(a,1));
for i = 1:size(a,1)
    uSq = u(i,:)'*u(i,:);
    fT(:,:,i) = f0 * (fPar(i)*uSq + fPerp(i)*(eye(3) - uSq)); %Sets the basis of the different parallel and perpendicular friction coefficients to be oriented along the cell axis.
end