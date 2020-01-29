function A = im_hessangle2(im, scale)
%IM_HESSANGLE2 calculates the magnitude of the eigenvalues at each location
%in an input image at the given spatial scale
%
%   INPUTS:
%       -im: Input matrix defining image, matrix of doubles
%       -scale: width (in pixels) of currently specified ridge
%   
%   OUTPUTS:
%       -A: Matrix of eigenvalue magnitudes at this spatial scale
%
%   Authors: Joeseph Harvey (c) 2014 and Oliver J. Meacock (c) 2019

%Run ridge detection filtering stages - g2 corresponds to the values of the Hessian matrix for each point in the greyscale intensity matrix.
g2 = im_hessstrflt2(im, scale);

tmp = sqrt((g2(:,:,1)- g2(:,:,3)).*(g2(:,:,1)- g2(:,:,3)) + 4 * g2(:,:,2).*g2(:,:,2)); 
%Components of the eigenvectors associated with the Hessian g2 (in polar coordinates)
eigvalue1 = (g2(:,:,1) + g2(:,:,3) + tmp)/2; %Formula for eigenvalues that falls out from working through the 2x2 case. Not Gamma normalized in this case (ie. is not normalized according to scale - see eqn 47 of Lindeberg 1996)
eigvalue2 = (g2(:,:,1) + g2(:,:,3) - tmp)/2;

%Calculate magnitude of the maximum eigenvalues/vectors of the Hessian at each point in the image
A = eigvalue1.*(abs(eigvalue1)>=abs(eigvalue2)) + eigvalue2.*(abs(eigvalue1)<abs(eigvalue2));
