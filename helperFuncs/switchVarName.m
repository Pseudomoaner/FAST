function outName = switchVarName(root,inName,inField,outField)
%SWITCHVARNAME is used to switch between variants names of a given
%variable, particularly machine readable, human readable and human readable
%with symbols (used for procTracks, dropdown menus and axis labels,
%respectively).
%
%   INPUTS:
%       -root: String containing the root directory for this dataset.
%       -inName: String containing the original name of the variable.
%       -inField: String defining the name of the string switched from. One
%       of ptName, hName or hsName.
%       -outField: Same as inField, for the target field.
%
%   OUTPUTS:
%       -outName: Switched variable name.
%
%   Author: Oliver J. Meacock (c) 2020

featNameStruct = prepareSpecialFeatureStructure(root);

specNamePos = arrayfun(@(x) strcmp(x.(inField),inName),featNameStruct);
if sum(specNamePos) == 1
    outName = featNameStruct(specNamePos).(outField);
else
    outName = inName;
end