function [fPar,fPerp,fRot] = calcGeomFactors(a)

%Calculates the geometric factors for this cell.
fPar = (2 * pi)./(log(a) - 0.207 + (0.980./a) - (0.133./(a.^2)));
fPerp = (4 * pi)./(log(a) + 0.839 + (0.185./a) + (0.233./(a.^2)));
fRot = ((a.^2) * pi)./(3*(log(a) - 0.662 + (0.917./a) - (0.050./(a.^2))));
