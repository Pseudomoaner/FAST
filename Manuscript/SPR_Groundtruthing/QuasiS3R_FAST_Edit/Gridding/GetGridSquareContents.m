function [sq_cont] = GetGridSquareContents(boxes, G)
% GETGRIDSQUARECONTENTS: Suppose we have allocated N points pt_ind=1:N to G grid squares sq_ind=1:G,
% resulting in the 1xN vector <boxes>, whose ith element is the square in
% which point pt_ind is found. Given a square <sq_ind>, return a 1xG cell array
% <sq_cont>, whose gth element is a (potentially empty) list of cell
% indices found in that square.

N = length(boxes);                      % number of cells
A = [(1:N)',boxes];                     % pair point squares with point indices
B = sortrows(A,2);                      % sort indices (1st col.) by square (2nd col.)

[a,b]=hist(boxes,unique(boxes));        % b: list of square indices with >0 pt; a: number of pts within each sq.
read_start = cumsum(a)-a+1;             % row to start reading on in table B
read_end = cumsum(a);                   % row to end reading on in table B
sq_cont = cell(G,1);                    % preallocate cell array
for sq_ind = 1:G                        % for each grid square:
    [col,~] = find(b==sq_ind);          %       check if this sq appears in b
    if isempty(col)                     %       if it doesn't...
        sq_cont{sq_ind} = [];           %       ... mark this square as empty.
    else                                %       if it does, read out its contents in B:
        sq_cont{sq_ind} = B(read_start(col):read_end(col),1);   
    end                                 %
end                                     % move to next grid square
end