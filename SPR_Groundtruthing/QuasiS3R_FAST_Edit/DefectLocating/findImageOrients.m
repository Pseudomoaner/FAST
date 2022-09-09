function orients = findImageOrients(img,SD)
%FINDIMAGEORIENTS uses the same tensor method algorithm to determine local
%orientation as OrientationJ.
 
[gX,gY] = imgradientxy(img);
Ixx = gX.*gX;
Iyy = gY.*gY;
Ixy = gX.*gY;

tIxx = imgaussfilt(Ixx,SD,'FilterSize',2*ceil(SD*8)+1); %Extra filter size should suffice to ensure smoothness of image gradients (i.e. no zero values)
tIyy = imgaussfilt(Iyy,SD,'FilterSize',2*ceil(SD*8)+1);
tIxy = imgaussfilt(Ixy,SD,'FilterSize',2*ceil(SD*8)+1);

orients = 0.5 * atan2(2*tIxy,tIyy-tIxx);