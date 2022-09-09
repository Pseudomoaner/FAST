function [boxes, N_x, N_y] = GridAndBinPoints2D(p_x,p_y,max_x,max_y,h)
% GRIDANDBINPOINTS2D fits a regular grid of square elements, having length
% <h>, around a set of points <p_x, p_y>.
% A grid-plotting option is included (commented out) for debugging
% purposes.

% fit an N_x-by-N_y grid of squares around the points (we assume field starts at (0,0)
N_x = floor(max_x/h)+1;       % number of squares along x
N_y = floor(max_y/h)+1;       % number of squares along y

h_adj_y = max_y/N_y;          % Size of grid sqare in y direction
h_adj_x = max_x/N_x;          % Size of grid sqare in x direction

ind_x = floor(p_x/h_adj_x);         % square indices along x for each point
ind_y = floor(p_y/h_adj_y);         % square indices along y for each point
boxes = ind_x + N_x*ind_y + 1;          % box indices, counting along then up the grid

% optional: plot the resulting grid
% figure('color','w')
% g_x = linspace(min_x,min_x+N_x*h,N_x+1);
% g_y = linspace(min_y,min_y+N_y*h,N_y+1);
% [G_X,G_Y] = meshgrid(g_x,g_y);
% mesh(G_X,G_Y,zeros(size(G_X))), hold on
% plot(p_x,p_y,'x')
% view(2)

end