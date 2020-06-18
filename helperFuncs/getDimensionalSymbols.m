function [tSym,xSym] = getDimensionalSymbols(root)
%GETDIMENSIONALSYMBOLS reads the symbols used to represent the spatial and
%temporal dimensions in the current dataset. Returns ? for either if not
%available.
%
%   INPUTS:
%       -root: String defining the location where the 'Metadata.mat' file
%       for this dataset is stored
%
%   OUTPUTS:
%       -tSym: Cell containing the symbol representing time
%       -xSym: Cell containing the symbol representing space
%
%   Author: Oliver J. Meacock, (c) 2020   

if exist(fullfile(root,'Metadata.mat'),'file')
    load(fullfile(root,'Metadata.mat'),'metaStore')
    
    if isfield(metaStore,'timeSym')
        tSym = string(metaStore.timeSym);
    else
        tSym = {'?'};
    end
    
    if isfield(metaStore,'xSym')
        xSym = string(metaStore.xSym);
    else
        xSym = {'?'};
    end
else
    xSym = {'?'};
    tSym = {'?'};
end