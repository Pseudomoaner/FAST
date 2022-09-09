function [gridInds,wrapTypes] = Get2DGridSqNeighbourhoods(N_x, N_y)
% GET2DGRIDSQNEIGHBOURHOODS: given a 2-D regular N_x-by-N_y grid with
% left->right, bottom->top indexing, return a list of Moore Neighbourhoods
% <MNs> whose gth row contains the indexes of grid squares directly
% adjacent to g. Includes rim which allows calculation of periodic boundary conditions.

M = reshape(1:N_x*N_y,N_x,N_y)';            % arrange indices 1:N_x*N_y in a grid of the right shape
Mb = zeros(N_y+2,N_x+2);                    % preallocate a larger grid with a border of zeros
Mb(2:end-1,2:end-1) = M;                    % fill in the core of the grid, leaving a border of width 1
Mb(2:end-1,1) = Mb(2:end-1,end-1);          % Deal with periodic boundary conditions
Mb(2:end-1,end) = Mb(2:end-1,2);
Mb(1,2:end-1) = Mb(end-1,2:end-1);
Mb(end,2:end-1) = Mb(2,2:end-1);
Mb(1,1) = Mb(end-1,end-1);
Mb(1,end) = Mb(end-1,2);
Mb(end,1) = Mb(2,end-1);
Mb(end,end) = Mb(2,2);

Wb = zeros(size(Mb));                      % Matrix that details how to wrap around boundaries (0=none,1=x,2=y,3=xy)
Wb(2:end-1,[1,end]) = 1;
Wb([1,end],2:end-1) = 2;
Wb([1,end],[1,end]) = 3;
gridInds = zeros(N_x*N_y,9);                     % preallocate neighbour list
wrapTypes = zeros(size(gridInds));
for p=2:N_x+1                               % for every square in the grid, read off neighbours from Mb
    for q=2:N_y+1
        gridInds(p+(q-2)*N_x-1,:) = [Mb(q-1,p-1),Mb(q-1,p),Mb(q-1,p+1),...
                                Mb(q,  p-1),Mb(q,  p),Mb(q,  p+1),...
                                Mb(q+1,p-1),Mb(q+1,p),Mb(q+1,p+1)];
        wrapTypes(p+(q-2)*N_x-1,:) = [Wb(q-1,p-1),Wb(q-1,p),Wb(q-1,p+1),...
                                Wb(q,  p-1),Wb(q,  p),Wb(q,  p+1),...
                                Wb(q+1,p-1),Wb(q+1,p),Wb(q+1,p+1)];
    end
end
end