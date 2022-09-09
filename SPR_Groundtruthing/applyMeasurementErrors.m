function measuredTruth = applyMeasurementErrors(groundTruth,measSettings)
%APPLYMEASUREMENTERRORS applys normally distributed noise to synthetic
%object data to simulate errors associated with feature measurement.
%
%   -INPUTS:
%       =groundTruth: the measurements of rod position, length, fluoresence
%       intensity and orientation, as output by the SPR simulations. Should
%       contain the trackableData field, which contains this data in the
%       usual trackableData format (slice representation).
%       =measSettings: structure specifying the standard deviation of the
%       noise associated with each feature in groundTruth
%
%   -OUTPUTS:
%       -measuredTruth: The ground truth data with measurement noise
%       applied.
%
%   Author: Oliver J. Meacock, 2022

%Apply measurement noise
for i = 1:size(groundTruth.trackableData.Length,2)
    groundTruth.trackableData.Length{i} = groundTruth.trackableData.Length{i} + randn(size(groundTruth.trackableData.Length{i}))*measSettings.Lstd;
    groundTruth.trackableData.ChannelMean{i} = groundTruth.trackableData.ChannelMean{i} + repmat(randn(size(groundTruth.trackableData.ChannelMean{i},1),1),1,3)*measSettings.Fstd;
    groundTruth.trackableData.Centroid{i}(:,1:2) = groundTruth.trackableData.Centroid{i}(:,1:2) + randn(size(groundTruth.trackableData.Centroid{i},1),2)*measSettings.Cstd;
    groundTruth.trackableData.Centroid{i}(groundTruth.trackableData.Centroid{i}<0) = 0;
    groundTruth.trackableData.Centroid{i}(groundTruth.trackableData.Centroid{i}>measSettings.fieldSize) = measSettings.fieldSize;
    groundTruth.trackableData.Orientation{i} = wrapToPi(groundTruth.trackableData.Orientation{i} + randn(size(groundTruth.trackableData.Orientation{i}))*measSettings.PhiStd);
end

measuredTruth = groundTruth;