function TrackableData = interfaceModelAndDiffusionTracker(Field,TrackableData,FrameNo)
%Creates an instance of PCs that is based on the given model frame.

if isempty(TrackableData)
    TrackableData = struct();
end

TrackableData.Length{FrameNo} = Field.aCells;
TrackableData.Orientation{FrameNo} = Field.thetCells;
TrackableData.Centroid{FrameNo} = [Field.xCells,Field.yCells,Field.zCells];
TrackableData.Tilt{FrameNo} = Field.phiCells;
TrackableData.Force{FrameNo} = Field.fCells;
TrackableData.ChannelMean{FrameNo} = Field.cCells;