function [varNameStruct] = prepareSpecialFeatureStructure(root)
%PREPARESPECIALFEATURESTRUCTURE creates a structure relating the names of
%the fields of procTracks to more user-friendly variable names. Also tags
%on units, if availible in the metadata.
%
%   INPUTS:
%       -root: String containing the location of the root directory in
%       which Metadata.mat (may) be found.
%   
%   OUTPUTS:
%       outputStruct: Structure containing strings for each of the
%       'special' variables (length, width, speed etc.)
%
%   Author: Oliver J. Meacock (c) 2020

%Get dimensional symbols (if they exist)
[tSym,xSym] = getDimensionalSymbols(root);

%Prepare structure
varNameStruct(1).ptName = 'majorLen'; %ProcTracks name
varNameStruct(1).hName = 'Length'; %Human name
varNameStruct(1).hsName = ['Length / ', xSym{1}]; %Human name with symbol
varNameStruct(2).ptName = 'minorLen'; 
varNameStruct(2).hName = 'Width'; 
varNameStruct(2).hsName = ['Width / ', xSym{1}]; 
varNameStruct(3).ptName = 'phi';
varNameStruct(3).hName = 'Orientation';
varNameStruct(3).hsName = 'Orientation / deg';
varNameStruct(4).ptName = 'theta';
varNameStruct(4).hName = 'Movement direction';
varNameStruct(4).hsName = 'Movement direction / deg';
varNameStruct(5).ptName = 'area';
varNameStruct(5).hName = 'Area';
varNameStruct(5).hsName = ['Area / ',xSym{1},'^2'];

if ~ismissing(tSym) %Can happen if you're analysing a single frame
    varNameStruct(6).ptName = 'age';
    varNameStruct(6).hName = 'Age';
    varNameStruct(6).hsName = ['Age / ',tSym{1}];
    varNameStruct(7).ptName = 'vmag';
    varNameStruct(7).hName = 'Speed';
    varNameStruct(7).hsName = ['Speed / ', xSym{1}, ' ', tSym{1}, '^{-1}'];
end

varNameStruct(8).ptName = 'x';
varNameStruct(8).hName = 'X-coordinate';
varNameStruct(8).hsName = ['X-coordinate / ', xSym{1}];
varNameStruct(9).ptName = 'y';
varNameStruct(9).hName = 'Y-coordinate';
varNameStruct(9).hsName = ['Y-coordinate /', xSym{1}];

%Add fields for possible imaging channels
load(fullfile(root,'CellFeatures.mat'),'featSettings') %As this function is only used in the overlays and plotting modules (which are only unlocked once feature extraction and then tracking is complete), think this is OK to assume exists by this point.
chanNo = featSettings.noChannels;

for i = 1:chanNo
    varNameStruct(8 + 2*i).ptName = ['channel_',num2str(i),'_mean'];
    varNameStruct(8 + 2*i).hName = ['Channel ',num2str(i),' mean'];
    varNameStruct(8 + 2*i).hsName = ['Channel ',num2str(i),' mean / A.U.'];
    
    varNameStruct(9 + 2*i).ptName = ['channel_',num2str(i),'_std'];
    varNameStruct(9 + 2*i).hName = ['Channel ',num2str(i),' standard deviation'];
    varNameStruct(9 + 2*i).hsName = ['Channel ',num2str(i),' standard deviation / A.U.'];
end
