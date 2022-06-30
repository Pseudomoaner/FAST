function timePoints = extractTimePoints(fromMappings,toMappings,trackData,varName)
%EXTRACTTIMEPOINTS converts the input 'track' format data to a 'slice'
%representation. Useful for extracting the slice representation for values
%that can only be calculated in the track format (e.g. object velocity,
%direction of movement).
%
%   INPUTS
%   fromMappings = mapping from the original 'slice' representation of the
%   data (i.e. feature values associated with unknown tracks but defined
%   timepoints) to the 'track' representation of the data (i.e. feature
%   values associated with specific tracks). For more details, see the
%   'extractDataTrack' function.
%   toMappings = similar to fromMappings, but points from the 'track'
%   representation back to the 'slice' representation. 
%   trackData = initial 'track' format data.
%   varname = string defining the name of the field you want to convert
%   into a 'slice' representation.
%   
%   OUTPUTS
%   timePoints = data from chosen field in a 'slice' representation.

maxT = 1;
for i = 1:size(trackData,2)
    if max(trackData(i).times) > maxT
        maxT = max(trackData(i).times);
    end
end

timePoints = cell(1,maxT);
for i = 1:length(timePoints)
    timePoints{i} = nan(size(toMappings{i},1),1);
end

for i = 1:size(fromMappings,2)
    for j = 1:size(fromMappings{i},1)-1
        t = fromMappings{i}(j,1);
        timePoints{t}(fromMappings{i}(j,2)) = trackData(i).(varName)(j);
    end
end