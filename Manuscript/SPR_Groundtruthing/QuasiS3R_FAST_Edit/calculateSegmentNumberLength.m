function [n,l] = calculateSegmentNumberLength(a,lam)
%CALCULATESEGMENTNUMBERLENGTH calculates the number of Yukawa segments and 
%separation of those segments given the aspect ratio of the cells (a) and 
%the interaction distance of the cells.
%
%   a = a row vector of a series of cellular aspect ratios.
%   lam = the interaction distance of the Yukawa model. Equivalent to the width of the cell (so double the radius)
%   t = the tilts of all cells in the model
%
%   n = the number of segments in each cell.
%   l = the separation of each segment.

midInds = and(a > 1, a < 3);
maxInds = a >= 3;

n = zeros(size(a));
n(midInds) = 3;
n(maxInds) = round((9/8)*a(maxInds));

l = (lam * (a - 1)) ./ (n - 1); 

%Original code
% if obj.a > 1 && obj.a <= 3
%     n = 3;
% elseif obj.a > 3
%     n = round((9/8)*obj.a);
% end
% l = (obj.lam*(obj.a-1))/n;
% end