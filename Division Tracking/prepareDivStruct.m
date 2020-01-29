function featureStruct = prepareDivStruct(divSettings)
%PREPAREDIVSTRUCT creates a structure that defines models of how different
%features of the procTracks track data structure interact when predicting
%the position of daughter cells in the normalised feature space.
%
%For more details, see: https://mackdurham.group.shef.ac.uk/FAST_DokuWiki/dokuwiki/doku.php?id=usage:advanced_usage#updating_the_division_detection_format_structure_with_new_features
%
%   INPUTS:
%       -divSettings: Structure containing user-defined settings for how
%       the division tracker GUI should be applied. Includes feature
%       selections.
%
%   OUTPUTS:
%       -featureStruct: Structure defining the interrelations between
%       different features in the procTracks data structure.
%
%   Author: Oliver J. Meacock (c) 2019

%I have a general desire to incorporate velocity based tracking at some stage... but not to begin with.

featureStruct = struct();

if divSettings.Centroid == 1
    featureStruct.('x').('Locations') = 1; 
    featureStruct.x.('divArguments') = {'x','phi','majorLen'};
    featureStruct.x.('postDivScale1') = @(x) x(1) + cosd(-x(2))*x(3)*0.25;
    featureStruct.x.('postDivScale2') = @(x) x(1) - cosd(-x(2))*x(3)*0.25;
    featureStruct.x.('StatsType') = 'Linear'; %Linear or circular - alters how differences are calculated later on.
    featureStruct.('y').('Locations') = 1;
    featureStruct.y.('divArguments') = {'y','phi','majorLen'};
    featureStruct.y.('postDivScale1') = @(x) x(1) + sind(-x(2))*x(3)*0.25;
    featureStruct.y.('postDivScale2') = @(x) x(1) - sind(-x(2))*x(3)*0.25;
    featureStruct.y.('StatsType') = 'Linear';
end

% if trackSettings.Velocity == 1
%     featureStruct.('Velocity').('Locations') = [1,2]; %Locations tells it where to look in the PCs.Cells(i).(featurename)(x) call, where x is replaced by the numbers shown here.
%     if trackSettings.divDect
%         featureStruct.Centroid.('postDivScale') = @(x,c) [x(3), x(4);x(3), x(4)]; %Function handle that tells it how much to expect the value to change after division. x is the vector of linear features, c the vector of circular features.
%     end
%     featureStruct.Centroid.('StatsType') = 'Linear'; %Linear or circular - alters how differences are calculated later on.
% end

if divSettings.Area == 1
    featureStruct.('area').('Locations') = 1; 
    featureStruct.area.('divArguments') = {'area'};
    featureStruct.area.('postDivScale1') = @(x) x/2;
    featureStruct.area.('postDivScale2') = @(x) x/2;
%     featureStruct.area.('postDivScale1') = @(x) x/3;
%     featureStruct.area.('postDivScale2') = @(x) x/3;
    featureStruct.area.('StatsType') = 'Linear';
end

if divSettings.Length == 1
    featureStruct.('majorLen').('Locations') = 1; 
    featureStruct.majorLen.('divArguments') = {'majorLen'};
    featureStruct.majorLen.('postDivScale1') = @(x) x/2;
    featureStruct.majorLen.('postDivScale2') = @(x) x/2;
%     featureStruct.majorLen.('postDivScale1') = @(x) x/1.5;
%     featureStruct.majorLen.('postDivScale2') = @(x) x/1.5;
    featureStruct.majorLen.('StatsType') = 'Linear';
end

if divSettings.Width == 1
    featureStruct.('minorLen').('Locations') = 1; 
    featureStruct.minorLen.('divArguments') = {'minorLen'};
    featureStruct.minorLen.('postDivScale1') = @(x) x;
    featureStruct.minorLen.('postDivScale2') = @(x) x;
%     featureStruct.minorLen.('postDivScale1') = @(x) x/2;
%     featureStruct.minorLen.('postDivScale2') = @(x) x/2;

    featureStruct.minorLen.('StatsType') = 'Linear';
end

if divSettings.Orientation == 1
    featureStruct.('phi').('Locations') = 1; 
    featureStruct.phi.('divArguments') = {'phi'};
    featureStruct.phi.('postDivScale1') = @(x) x;
    featureStruct.phi.('postDivScale2') = @(x) x;
%     featureStruct.phi.('postDivScale1') = @(x) mod(x + 180,180)-90; %For use with eukaryotic nuclear divisions
%     featureStruct.phi.('postDivScale2') = @(x) mod(x + 180,180)-90;
    featureStruct.phi.('StatsType') = 'Circular';
    featureStruct.phi.('Range') = [-90,90];
end

if ~isempty(divSettings.MeanInc)
    logicAvail = false(size(divSettings.availableMeans));
    logicUsed = false(size(divSettings.MeanInc));
    logicAvail(divSettings.availableMeans) = true;
    logicUsed(divSettings.MeanInc) = true;
    
    featureStruct.('ChannelMean').('Locations') = find(logicUsed(logicAvail));
    featureStruct.ChannelMean.('divArguments') = {'ChannelMean'};
    featureStruct.ChannelMean.('postDivScale1') = @(x) x;
    featureStruct.ChannelMean.('postDivScale2') = @(x) x;
    featureStruct.ChannelMean.('StatsType') = 'Linear';
end

if ~isempty(divSettings.StdInc)
    logicAvail = false(size(divSettings.availableStds));
    logicUsed = false(size(divSettings.StdInc));
    logicAvail(divSettings.availableStds) = true;
    logicUsed(divSettings.StdInc) = true;
    
    featureStruct.('ChannelStd').('Locations') = find(logicUsed(logicAvail));
    featureStruct.ChannelStd.('divArguments') = {'ChannelStd'};
    featureStruct.ChannelStd.('postDivScale1') = @(x) x;
    featureStruct.ChannelStd.('postDivScale2') = @(x) x;
    featureStruct.ChannelStd.('StatsType') = 'Linear';
end

if divSettings.SpareFeat1 == 1
    featureStruct.('sparefeat1').('Locations') = 1;
    featureStruct.sparefeat1.('divArguments') = {};
    featureStruct.sparefeat1.('postDivScale1') = @(x) x;
    featureStruct.sparefeat1.('postDivScale2') = @(x) x;
    featureStruct.sparefeat1.('StatsType') = 'Linear';
end

if divSettings.SpareFeat2 == 1
    featureStruct.('sparefeat2').('Locations') = 1; 
    featureStruct.sparefeat2.('divArguments') = {};
    featureStruct.sparefeat2.('postDivScale1') = @(x) x;
    featureStruct.sparefeat2.('postDivScale2') = @(x) x;
    featureStruct.sparefeat2.('StatsType') = 'Linear';
end

if divSettings.SpareFeat3 == 1
    featureStruct.('sparefeat3').('Locations') = 1; 
    featureStruct.sparefeat3.('divArguments') = {};
    featureStruct.sparefeat3.('postDivScale1') = @(x) x;
    featureStruct.sparefeat3.('postDivScale2') = @(x) x;
    featureStruct.sparefeat3.('StatsType') = 'Linear';
end

if divSettings.SpareFeat4 == 1
    featureStruct.('sparefeat4').('Locations') = 1; 
    featureStruct.sparefeat4.('divArguments') = {};
    featureStruct.sparefeat4.('postDivScale1') = @(x) x;
    featureStruct.sparefeat4.('postDivScale2') = @(x) x;
    featureStruct.sparefeat4.('StatsType') = 'Linear';
end