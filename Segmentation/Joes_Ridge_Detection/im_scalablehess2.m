function Magnitude = im_scalablehess2(im, scale_range)
%IM_SCALABLEHESS2 calculates the magnitude of the eigenvalues of the
%Hessian of an input image.
%
%   INPUTS:
%       -im: Input image, matrix of double values
%       -scale_range: Scalar, or vector, defining range of ridge scales
%       calculation hould be performed over
%
%   OUTPUTS:
%       -Magnitude: Magnitude of the largest eigenvalue at each spatial
%       scale across spatial scales
%
%   Authors: Joeseph Harvey (c) 2014 and Oliver J. Meacock (c) 2019

dim = 0;
for scale = scale_range
    dim = dim + 1;
    Magnitude(:,:,dim) = im_hessangle2(im, scale);
end

[M, N] = size(im);
Magnitude = max(Magnitude, [], 3); %Maximal eigenvalue of the Hessian across spatial scales

Magnitude(Magnitude<0) = 0;
Magnitude = (Magnitude-min(Magnitude(:)))/(max(Magnitude(:))-min(Magnitude(:)) + realmin); %Set to vary between 0 and 1

