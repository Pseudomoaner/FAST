function out = lineSegmentIntersectPeriodic(XY1,XY2,acceptGrid,boundX,boundY,Width,Height)
%LINESEGMENTINTERSECTPERIODIC Intersections of line segments.
%   OUT = LINESEGMENTINTERSECT(XY1,XY2) finds the 2D Cartesian Coordinates of
%   intersection points between the set of line segments given in XY1 and XY2.
%
%   XY1 and XY2 are N1x4 and N2x4 matrices. Rows correspond to line segments. 
%   Each row is of the form [x1 y1 x2 y2] where (x1,y1) is the start point and 
%   (x2,y2) is the end point of a line segment:
%
%                  Line Segment
%       o--------------------------------o
%       ^                                ^
%    (x1,y1)                          (x2,y2)
%
%   acceptGrid is an N1xN2 matrix with putative intersections marked with 1s, 0s
%   elsewhere. If you have a sparse problem (e.g. many short lines spread
%   over a large area), it can be faster to calculate this beforehand.
%   Otherwise, leave as []. Note that this will mean that only those
%   elements with intersections will have data values - the other entries
%   will remain zero.
%
%   OUT is a structure with fields:
%
%   'intAdjacencyMatrix' : N1xN2 indicator matrix where the entry (i,j) is 1 if
%       line segments XY1(i,:) and XY2(j,:) intersect.
%
%   'intMatrixX' : N1xN2 matrix where the entry (i,j) is the X coordinate of the
%       intersection point between line segments XY1(i,:) and XY2(j,:).
%
%   'intMatrixY' : N1xN2 matrix where the entry (i,j) is the Y coordinate of the
%       intersection point between line segments XY1(i,:) and XY2(j,:).
%
%   'intNormalizedDistance1To2' : N1xN2 matrix where the (i,j) entry is the
%       normalized distance from the start point of line segment XY1(i,:) to the
%       intersection point with XY2(j,:).
%
%   'intNormalizedDistance2To1' : N1xN2 matrix where the (i,j) entry is the
%       normalized distance from the start point of line segment XY1(j,:) to the
%       intersection point with XY2(i,:).
%
%   'parAdjacencyMatrix' : N1xN2 indicator matrix where the (i,j) entry is 1 if
%       line segments XY1(i,:) and XY2(j,:) are parallel.
%
%   'coincAdjacencyMatrix' : N1xN2 indicator matrix where the (i,j) entry is 1 
%       if line segments XY1(i,:) and XY2(j,:) are coincident.

% Version: 1.00, April 03, 2010
% Version: 1.10, April 10, 2010
% Version: 1.20, May 07, 2015
% Author:  U. Murat Erdem, modified by Oliver Meacock

% CHANGELOG:
%
% Ver. 1.00: 
%   -Initial release.
% 
% Ver. 1.10:
%   - Changed the input parameters. Now the function accepts two sets of line
%   segments. The intersection analysis is done between these sets and not in
%   the same set.
%   - Changed and added fields of the output. Now the analysis provides more
%   information about the intersections and line segments.
%   - Performance tweaks.
%   
% Ver. 1.20:
%   -Added support for sparse collections of line segments (the whole
%   acceptGrid thing).
%
% I opted not to call this 'curve intersect' because it would be misleading
% unless you accept that curves are pairwise linear constructs.
% I tried to put emphasis on speed by vectorizing the code as much as possible.
% There should still be enough room to optimize the code but I left those out
% for the sake of clarity.
% The math behind is given in:
%   http://local.wasp.uwa.edu.au/~pbourke/geometry/lineline2d/
% If you really are interested in squeezing as much horse power as possible out
% of this code I would advise to remove the argument checks and tweak the
% creation of the OUT a little bit.

%%% Argument check.
%-------------------------------------------------------------------------------

validateattributes(XY1,{'numeric'},{'2d','finite'});
validateattributes(XY2,{'numeric'},{'2d','finite'});

[n_rows_1,n_cols_1] = size(XY1);
[n_rows_2,n_cols_2] = size(XY2);

if n_cols_1 ~= 4 || n_cols_2 ~= 4
    error('Arguments must be a Nx4 matrices.');
end


if ~isempty(acceptGrid)
    
    %Preallocate output
    out.intAdjacencyMatrix = zeros(size(acceptGrid));
    out.intMatrixX = zeros(size(acceptGrid));
    out.intMatrixY = zeros(size(acceptGrid));
    out.intNormalizedDistance1To2 = zeros(size(acceptGrid));
    out.intNormalizedDistance2To1 = zeros(size(acceptGrid));
    out.parAdjacencyMatrix = zeros(size(acceptGrid));
    out.coincAdjacencyMatrix = zeros(size(acceptGrid));
    
    %Fill up output, one element at a time. 
    inds = find(acceptGrid);
    [r,c] = ind2sub(size(acceptGrid),inds);
    
    for i = 1:length(r)
        X1 = XY1(r(i),1);
        X2 = XY1(r(i),3);
        X3 = XY2(c(i),1);
        X4 = XY2(c(i),3);
        
        Y1 = XY1(r(i),2);
        Y2 = XY1(r(i),4);
        Y3 = XY2(c(i),2);
        Y4 = XY2(c(i),4);
        
        X43 = (X4 - X3);
        X13 = (X1 - X3);
        X21 = (X2 - X1);
                
        if abs(X43) > boundX
            X43 = -sign(X43)*(Width - abs(X43));
        end
        if abs(X13) > boundX
            X13 = -sign(X13)*(Width - abs(X13));
        end
        if abs(X21) > boundX
            X21 = -sign(X21)*(Width - abs(X21));
        end
        
        Y43 = (Y4 - Y3);
        Y13 = (Y1 - Y3);
        Y21 = (Y2 - Y1);
        
        if abs(Y43) > boundY
            Y43 = -sign(Y43)*(Height - abs(Y43));
        end
        if abs(Y13) > boundY
            Y13 = -sign(Y13)*(Height - abs(Y13));
        end
        if abs(Y21) > boundY
            Y21 = -sign(Y21)*(Height - abs(Y21));
        end
        
        num_a = X43 * Y13 - Y43 * X13;
        num_b = X21 * Y13 - Y21 * X13;
        denom = Y43 * X21 - X43 * Y21;
        
        u_a = num_a/denom;
        u_b = num_b/denom;
                
        if u_a >= 0 && u_a <= 1 && u_b >= 0 && u_b <= 1
            out.intAdjacencyMatrix(r(i),c(i)) = 1; %Positions in which an intersection has occured
            out.intMatrixX(r(i),c(i)) = X1 + X21*u_a; %Location of the intersection - X
            out.intMatrixY(r(i),c(i)) = Y1 + Y21*u_a; %And Y coordinates.
            out.intNormalizedDistance1To2(r(i),c(i)) = u_a; %Normalized distance from point 1 to intersection (along line 1)
            out.intNormalizedDistance2To1(r(i),c(i)) = u_b; %Normalized distance from point 3 to intersection (along line 2)
            if denom == 0 && num_a == 0 && num_b == 0
                out.coincAdjacencyMatrix(r(i),c(i)) = 1; %When points are identical
                out.parAdjacencyMatrix(r(i),c(i)) = 1; %When lines are parallel
            elseif denom == 0
                out.parAdjacencyMatrix(r(i),c(i)) = 1;
            end
        end
    end
%%% Prepare matrices for vectorized computation of line intersection points.
%-------------------------------------------------------------------------------
else
    X1 = repmat(XY1(:,1),1,n_rows_2);
    X2 = repmat(XY1(:,3),1,n_rows_2);
    Y1 = repmat(XY1(:,2),1,n_rows_2);
    Y2 = repmat(XY1(:,4),1,n_rows_2);
    
    XY2 = XY2';
    
    X3 = repmat(XY2(1,:),n_rows_1,1);
    X4 = repmat(XY2(3,:),n_rows_1,1);
    Y3 = repmat(XY2(2,:),n_rows_1,1);
    Y4 = repmat(XY2(4,:),n_rows_1,1);
    
    X4_X3 = (X4-X3);
    Y1_Y3 = (Y1-Y3);
    Y4_Y3 = (Y4-Y3);
    X1_X3 = (X1-X3);
    X2_X1 = (X2-X1);
    Y2_Y1 = (Y2-Y1);
    
    numerator_a = X4_X3 .* Y1_Y3 - Y4_Y3 .* X1_X3;
    numerator_b = X2_X1 .* Y1_Y3 - Y2_Y1 .* X1_X3;
    denominator = Y4_Y3 .* X2_X1 - X4_X3 .* Y2_Y1;
    
    u_a = numerator_a ./ denominator;
    u_b = numerator_b ./ denominator;
    
    % Find the adjacency matrix A of intersecting lines.
    INT_X = X1+X2_X1.*u_a;
    INT_Y = Y1+Y2_Y1.*u_a;
    INT_B = (u_a >= 0) & (u_a <= 1) & (u_b >= 0) & (u_b <= 1);
    PAR_B = denominator == 0;
    COINC_B = (numerator_a == 0 & numerator_b == 0 & PAR_B);
    
    
    % Arrange output.
    out.intAdjacencyMatrix = INT_B;
    out.intMatrixX = INT_X .* INT_B;
    out.intMatrixY = INT_Y .* INT_B;
    out.intNormalizedDistance1To2 = u_a;
    out.intNormalizedDistance2To1 = u_b;
    out.parAdjacencyMatrix = PAR_B;
    out.coincAdjacencyMatrix= COINC_B;
end

end

