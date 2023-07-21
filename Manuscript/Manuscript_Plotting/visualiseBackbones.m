clear all
close all

gray = imread('C:\Users\omeacock\Desktop\FAST_Datasets\T6SS\SM6_1\Channel_1\Frame_0000.tif');
red = imread('C:\Users\omeacock\Desktop\FAST_Datasets\T6SS\SM6_1\Channel_2\Frame_0000.tif');
grn = imread('C:\Users\omeacock\Desktop\FAST_Datasets\T6SS\SM6_1\Channel_3\Frame_0000.tif');
seg = imread('C:\Users\omeacock\Desktop\FAST_Datasets\T6SS\SM6_1\Segmentations\Frame_0000.tif');

se = strel('disk',1);
skel = double(imdilate(bwskel(logical(seg)),se));

red = double(red)/255;
grn = double(grn)/255;
gray = double(gray)/255;

objs = bwlabel(seg);

redOuts = zeros(size(red));
grnOuts = zeros(size(grn));

for i = 1:max(objs(:))
    mask = objs == i;
    border = imdilate(bwperim(imdilate(mask,se)),se);

    redSum = sum(red(mask));
    grnSum = sum(grn(mask));

    if redSum > grnSum
        redOuts(border) = 1;
    else
        grnOuts(border) = 1;
    end
end

imshow(cat(3,red+skel+redOuts,grn+skel+grnOuts,grn+grnOuts),[])