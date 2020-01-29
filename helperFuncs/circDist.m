function out = circDist(Zi,Zj)
%Simple Euclidean distance function for circular data. Please ensure data is bounded between 0 and 1 (can rescale later if necessary)
subtractor = repmat(Zi,size(Zj,1),1);
circVec = min(mod(Zj - subtractor,1),mod(subtractor - Zj,1));
out = sqrt(sum(circVec.^2,2));