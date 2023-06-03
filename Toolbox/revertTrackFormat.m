function Track = revertTrackFormat(fromMappings,toMappings)
%REVERTTRACKFORMAT converts the fromMappings (track representation) data
%structure to the format output by the doDirectLinkingRedux function. This
%is useful for using the scoreTrackQuality function, which requires data in
%this format.
%
%   INPUTS:
%   fromMappings: The mapping from the track to the slice representation,
%   with slice time in the first column of each cell and object index in 
%   the second column.
%   toMappings: The mapping from the slice representation to the track
%   representation.
%
%   OUTPUTS:
%   -Track: Cell array with one cell per frame of the input dataset,
%   with each cell containing an O by 2 matrix where O is the total
%   number of objects in that frame. Column 1 indicates the frame this
%   object links to, column 2 the object index within this frame.
%   Output by doDirectLinkingRedux.m
%
%   Author: Oliver J. Meacock

%Initialise structure
Track = cell(size(toMappings));

for i = 1:size(toMappings,1)
    Track{i} = zeros(size(toMappings{i}));
end

%Go through track by track
for i = 1:size(fromMappings,2)
    for j = 1:size(fromMappings{i},1)-1
        Track{fromMappings{i}(j,1)}(fromMappings{i}(j,2),:) = [fromMappings{i}(j+1,1),fromMappings{i}(j+1,2)];
    end
    Track{fromMappings{i}(end,1)}(fromMappings{i}(end,2),:) = [NaN,NaN];
end