function [stringArrayX,stringArrayY] = getDivPopupStrings(trackSettings)
%GETDIVPOPUPSTRINGS generates the strings that should be available in the
%popupmenus of the normalised displacement space window based on the
%currently selected features.
%
%   INPUTS:
%       -trackSettings: Structure containing the current settings (in
%       particular, the currently selected checkboxes in the feature
%       selection panel) from the divisionTracker GUI.
%   
%   OUTPUTS:
%       -stringArrayX: Cell array containing the strings that should be
%       displayed in the x popup menu
%       -stringArrayY: Cell array containing the strings that should be
%       displayed in teh y popup menu
%
%   Author: Oliver J. Meacock (c) 2019

stringArrayX = {'x variable'};
stringArrayY = {'y variable'};

stringArray = {'d(t)'};
% Below needs to be reinstated once velocity based tracking is included!
% if trackSettings.Velocity == 1
%     stringArray = [stringArray;'d(Vx)'];
%     stringArray = [stringArray;'d(Vy)'];
% end
if trackSettings.Centroid == 1
    stringArray = [stringArray;'d(x)'];
    stringArray = [stringArray;'d(y)'];
end
if trackSettings.Length == 1
    stringArray = [stringArray;'d(Length)'];
end
if trackSettings.Area == 1
    stringArray = [stringArray;'d(Area)'];
end
if trackSettings.Width == 1
    stringArray = [stringArray;'d(Width)'];
end
if trackSettings.Orientation == 1
    stringArray = [stringArray;'d(Orientation)'];
end
if ~isempty(trackSettings.MeanInc)
    for chan = trackSettings.MeanInc'
        stringArray = [stringArray;['d(Channel ',num2str(chan),' intensity)']];
    end
end
if ~isempty(trackSettings.StdInc)
    for chan = 1:trackSettings.StdInc'
        stringArray = [stringArray;['d(Channel ',num2str(chan),' variation)']];
    end
end
if trackSettings.SpareFeat1 == 1
    stringArray = [stringArray;'d(SpareFeat1)'];
end
if trackSettings.SpareFeat2 == 1
    stringArray = [stringArray;'d(SpareFeat2)'];
end
if trackSettings.SpareFeat3 == 1
    stringArray = [stringArray;'d(SpareFeat3)'];
end
if trackSettings.SpareFeat4 == 1
    stringArray = [stringArray;'d(SpareFeat4)'];
end

stringArrayX = [stringArrayX;stringArray];
stringArrayY = [stringArrayY;stringArray];