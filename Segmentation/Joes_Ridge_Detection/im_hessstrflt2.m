function g2 =  im_hessstrflt2(init_im, scale)
%IM_HESSSTRFLT2 calculates the Hessian matrix of the given input image, at
%the given spatial scale.
%
%   INPUTS:
%       -init_im: The input image, a matrix of doubles
%       -scale: The currently specified scale over which smoothing should
%       be apllied
%
%   OUTPUTS:
%       -g2: The components of the Hessian at each spatial location in the
%       image. First two dimensions correspond to the dimensions of the
%       input image, while three components in the third dimension are the
%       components of the Hessian (noting its symmetry).
%
%   Authors: Joeseph Harvey (c) 2014 and Oliver J. Meacock (c) 2019

%Create normalized kernals - x^2, y^2 and xy (horizontal, vertical and diagonal edge detectors)
[y,x]=meshgrid(-3:6/scale:3,-3:6/scale:3);
g2a=(2*(x.^2)-1).*exp(-(x.^2+y.^2));
% imshow(g2a)
g2a=g2a/sum(abs(g2a(:)));

g2b=2*x.*y.*exp(-(x.^2+y.^2));
% figure
% imshow(g2b)
g2b=g2b/sum(abs(g2b(:)));

g2c=(2*(y.^2)-1).*exp(-(x.^2+y.^2));
% figure
% imshow(g2c)
g2c=g2c/sum(abs(g2c(:)));

%Filter image with edge detectors
g2a_rst=imfilter(init_im, g2a, 'symmetric', 'same');
g2(:,:,1)=g2a_rst;
g2b_rst=imfilter(init_im, g2b, 'symmetric', 'same');
g2(:,:,2)=g2b_rst;
g2c_rst=imfilter(init_im, g2c, 'symmetric', 'same');
g2(:,:,3)=g2c_rst;