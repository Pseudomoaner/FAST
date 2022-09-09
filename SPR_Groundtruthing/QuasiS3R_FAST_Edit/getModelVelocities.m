function [RawSpeed,RawPhi,SmoothSpeed,SmoothPhi] = getModelVelocities(Centroids,Times,smoothingSpan,tStep) %Calculates the raw velocities of all cells in sufficiently long tracks.

RawSpeed = cell(size(Centroids));
RawPhi = cell(size(Centroids));
SmoothSpeed = cell(size(Centroids));
SmoothPhi = cell(size(Centroids));

for i = 1:length(Times)
    if length(Times{i}) > 1
        rawX = Centroids{i}(:,1);
        rawY = Centroids{i}(:,2);
        if isempty(smoothingSpan)
            smoothedX = rawX;
            smoothedY = rawY;
        else
            smoothedX = smooth(Times{i},rawX,smoothingSpan);
            smoothedY = smooth(Times{i},rawY,smoothingSpan);
        end
        
        rawdX = diff(rawX);
        rawdY = diff(rawY);
        smoothdX = diff(smoothedX);
        smoothdY = diff(smoothedY);
        dt = diff(Times{i})'*tStep;
        
        rawVel = [rawdX./dt,rawdY./dt];
        smoothVel = [smoothdX./dt,smoothdY./dt];
        
        RawSpeed{i} = sqrt(sum(rawVel.^2,2));
        SmoothSpeed{i} = sqrt(sum(smoothVel.^2,2));
        
        RawPhi{i} = -atan2d(rawdY,rawdX);
        SmoothPhi{i} = -atan2d(smoothdY,smoothdX);
    else
        RawSpeed{i} = NaN;
        RawPhi{i} = NaN;
        SmoothSpeed{i} = NaN;
        SmoothPhi{i} = NaN;
    end
end