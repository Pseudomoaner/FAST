function cellDists = calcGriddedDistMat(Field,periodic)
%% CALCGRIDDEDDISTMAT
% GIVEN:
%   * Nx6 needle vector array <NVecs>
%   * cell configuration <SimList{s=sim}(t=time)>
%   * a hit threshold distance <h>, which should be set to be
%           h = max separation between needle and cell center compatible with contact
%             = 0.5*(max_cell_length + max_needle_length + 2*max_cell_radius)
%   ...
% COMPUTE
%   * Hits, a length-M array counting hits on each cell 1:M

% upload cell data for this configuration
M = size(Field.xCells,1)+size(Field.xBarr,1); % number of cells and barrier elements
len = [Field.lCells',Field.lBarr'];   % cell lengths
rad = repmat(Field.lam,1,M);   % cell radii

% define grid and sort needles, cells by centroids (2D)
pts_C = [Field.xCells,Field.yCells;Field.xBarr,Field.yBarr];  % cell and barrier centroids
[boxes_C, N_x, N_y] = GridAndBinPoints2D(pts_C(:,1),pts_C(:,2),Field.xWidth,Field.yHeight,Field.distThresh);

% use grid to define sq neighbourhoods (2D)
[MNs,WTs] = Get2DGridSqNeighbourhoods(N_x, N_y);        % list of <= 9 neighbours per sqare

% Step 4: get list of cells in each box square
[sq_cont] = GetGridSquareContents(boxes_C, N_x*N_y);% cell array indicating cells in each grid sqaure

%Preallocate a distance matrix with NaNs
cellDists = nan(M,M);

%Loop over cells
for i = 1:M
    this_sq = boxes_C(i); %Which box is this cell in?
    this_sq_nbours = MNs(this_sq,:);
    this_sq_nbours_wraps = WTs(this_sq,:);
   
    x_i = pts_C(i,1);
    y_i = pts_C(i,2);
    
    %Find the number of cells j this one will be compared with
    i_j_cnt = 0;
    for j = 1:length(this_sq_nbours)
        i_j_cnt = i_j_cnt + size(sq_cont{this_sq_nbours(j)},1);
    end
    
    i_inds = zeros(i_j_cnt,1);%List of indices of cells cell i is compared with
    i_dists = zeros(i_j_cnt,1);%List of distances resulting from these comparisons
    
    % go through neighbouring squares
    currInd = 0;
    for j = 1:length(this_sq_nbours)                    % for each neighbouring square...
        this_nbour = this_sq_nbours(j);                 % get neighbour square index
        this_nbour_wrap = this_sq_nbours_wraps(j);
        to_check = sq_cont{this_nbour};                 % Cells in this grid square to compare cell i with
        
        if ~isempty(to_check)
            if periodic
                %Apply periodic boundary conditions to x and y coordinates
                if this_nbour_wrap == 1 || this_nbour_wrap == 3
                    if x_i > pts_C(to_check(1),1)
                        x_j = pts_C(to_check,1) + Field.xWidth;
                    else
                        x_j = pts_C(to_check,1) - Field.xWidth;
                    end
                else
                    x_j = pts_C(to_check,1);
                end
                if this_nbour_wrap == 2 || this_nbour_wrap == 3
                    if y_i > pts_C(to_check(1),2)
                        y_j = pts_C(to_check,2) + Field.yHeight;
                    else
                        y_j = pts_C(to_check,2) - Field.yHeight;
                    end
                else
                    y_j = pts_C(to_check,2);
                end
            else
                if this_nbour_wrap == 0
                    x_j = pts_C(to_check,1);
                    y_j = pts_C(to_check,2);
                else
                    x_j = nan(size(to_check));
                    y_j = nan(size(to_check));
                end
            end
            
            i_inds(currInd+1:currInd + size(to_check,1)) = to_check;
            i_dists(currInd+1:currInd + size(to_check,1)) = sqrt((x_j - x_i).^2 + (y_j - y_i).^2);
            
            currInd = currInd + size(to_check,1);
        end
    end
    cellDists(i,i_inds) = i_dists;
end
end