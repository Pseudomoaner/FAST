function outRad = NsphereVol2Rad(vol,n)
%NSPHEREVOL2RAD returns the radius of the n-dimensional hypersphere with
%volume vol.

outRad = ((vol .* gamma(1+n/2))./(pi^(n/2))).^(1/n);