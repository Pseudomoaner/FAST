function [data,trackableData,toMappings,fromMappings,Tracks] = processModelPCs(PCs,pS,fS)

PCs.Orientation = PCs.Orientation(pS.startTime:end);
PCs.Centroid = PCs.Centroid(pS.startTime:end);
PCs.Length = PCs.Length(pS.startTime:end);
PCs.Tilt = PCs.Tilt(pS.startTime:end);
PCs.Force = PCs.Force(pS.startTime:end);
PCs.ChannelMean = PCs.ChannelMean(pS.startTime:end);
%Build tracks
[Tracks,Initials] = buildModelPCsTracks(PCs,fS);

[OrientationTracks,trackTimes,toMappings,fromMappings] = extractModelDataTrack(Tracks,Initials,PCs.Orientation);
LengthTracks = extractModelDataTrack(Tracks,Initials,PCs.Length);
CentroidTracks = extractModelDataTrack(Tracks,Initials,PCs.Centroid);
TiltTracks = extractModelDataTrack(Tracks,Initials,PCs.Tilt);
ForceTracks = extractModelDataTrack(Tracks,Initials,PCs.Force);
ChannelMeanTracks = extractModelDataTrack(Tracks,Initials,PCs.ChannelMean);

disp('Tracked...')

%Undrift tracks
UndriftCentroids = stabilizeTracks(CentroidTracks,trackTimes,1);

disp('Undrifted...')

%Velocity computations
[RawSpeed,RawPhi,SmoothSpeed,SmoothPhi] = getModelVelocities(CentroidTracks,trackTimes,pS.velocitySmoothingSize,fS.dt);

disp('Velocities found...')

%Remove short tracks
lengthDist = zeros(size(OrientationTracks));
for i = 1:length(lengthDist)
    lengthDist(i) = length(OrientationTracks{i});
end
UndriftCentroids(lengthDist < pS.minTrackLength) = [];
CentroidTracks(lengthDist < pS.minTrackLength) = [];
LengthTracks(lengthDist < pS.minTrackLength) = [];
OrientationTracks(lengthDist < pS.minTrackLength) = [];
TiltTracks(lengthDist < pS.minTrackLength) = [];
ForceTracks(lengthDist < pS.minTrackLength) = [];
ChannelMeanTracks(lengthDist < pS.minTrackLength) = [];
RawSpeed(lengthDist < pS.minTrackLength) = [];
RawPhi(lengthDist < pS.minTrackLength) = [];
SmoothSpeed(lengthDist < pS.minTrackLength) = [];
SmoothPhi(lengthDist < pS.minTrackLength) = [];
trackTimes(lengthDist < pS.minTrackLength) = [];
fromMappings(lengthDist < pS.minTrackLength) = [];

%Find reversals in tracks
% Reversals = findReversals(OrientationTracks,SmoothPhi,120);

%Store your variables in a trackmate style datastructure
data = struct();
for i = 1:length(OrientationTracks)
    data(i).x = CentroidTracks{i}(:,1);
    data(i).y = CentroidTracks{i}(:,2);
    data(i).stablex = UndriftCentroids{i}(:,1);
    data(i).stabley = UndriftCentroids{i}(:,2);
    data(i).length = length(OrientationTracks{i});
    data(i).start = trackTimes{i}(1);
    data(i).end = trackTimes{i}(end);
    data(i).duration = data(i).end - data(i).start;
    data(i).vmag = SmoothSpeed{i};
    data(i).phi = OrientationTracks{i};
    data(i).tilt = TiltTracks{i};
    data(i).theta = SmoothPhi{i};
    data(i).times = trackTimes{i};
    data(i).majorLen = LengthTracks{i};
    data(i).force = ForceTracks{i};
    data(i).chan1mean = ChannelMeanTracks{i}(:,1);
    data(i).chan2mean = ChannelMeanTracks{i}(:,2);
    data(i).chan3mean = ChannelMeanTracks{i}(:,3);
    %data(i).reverse = Reversals{i};
end

%Do some rejigging of data and settings store to bring them into line with the standard nomenclature
trackableData.Orientation = PCs.Orientation;
trackableData.Centroid = PCs.Centroid;
trackableData.Length = PCs.Length;
trackableData.Tilt = PCs.Tilt;
trackableData.Force = PCs.Force;
trackableData.ChannelMean = PCs.ChannelMean;

%And convert phi to be consistant with other data extraction (actually ends up inverted so you have to take the negative later, but better than having to reprocess all those films)
for i = 1:length(data)
    data(i).phi = -data(i).phi;
end

for i = 1:length(trackableData.Orientation)
    trackableData.Orientation{i} = -trackableData.Orientation{i};
end