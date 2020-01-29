function plotTrackLengthDistribution(Tracks,axHand,minTrackLength) 
%PLOTTRACKLENGTHDISTRIBUTION plots the distribution of track lengths in 
%terms of time steps (as opposed to physical units). Also indicates the
%currently selected length cutoff with a vertical line.
%
%   INPUTS:
%       -Tracks: Current version of your tracks. Differs from procTracks 
%       (the final output of the tracking module) in that this raw version
%       contains tracks below the length cutoff as well.
%       -axHand: Handle to axes in which the track length distribution
%       should be plotted.
%       -minTrackLength: Length cutoff - tracks below this length will be
%       excluded from the final (processed) procTracks structure.
%
%   Author: Oliver J. Meacock (c) 2019

cla(axHand)

TrackLens = zeros(size(Tracks));
for i = 1:size(Tracks,2)
    TrackLens(i) = size(Tracks{i},1);
end
lenList = 1:max(TrackLens);

lenCounts = zeros(size(lenList));
lenInd = 1;
for i = lenList
    lenCounts(lenInd) = sum(TrackLens == i) * i; %The number of datapoints included in this 
    lenInd = lenInd + 1;
end

lenPcrt = 100 * (lenCounts/sum(lenCounts));

plot(axHand,lenList,lenPcrt,'b','LineWidth',1);
xlabel(axHand,'Track length')
ylabel(axHand,'Percentage of data')

xLims = get(axHand,'XLim');
yLims = get(axHand,'YLim');

hold(axHand,'on')
plot(axHand,[minTrackLength,minTrackLength],[0,100],'Color',[1,0,0],'LineWidth',2);
axis(axHand,[xLims,yLims])
hold(axHand,'off')

legend(axHand,'Data percentage distribution','Minimum track length')