function [Tracks,Initials] = buildModelPCsTracks(PCs,fS)
%This creates a tracking structure for the output of the Wensink model, under the assumption that there is no cell division.
%Now permits cell division modelling.

Tracks = cell(size(PCs.Orientation,2),1);
Initials = cell(size(PCs.Orientation,2),1);

beforeNo = 0;

%Begin by making tracks and initials with the assumption that each cell maintains its index over time
for i = 1:size(PCs.Orientation,2)
    Initials{i} = [zeros(beforeNo,1);ones(size(PCs.Orientation{i},1)-beforeNo,1)];
    beforeNo = size(PCs.Orientation{i},1);
    
    if i == size(PCs.Orientation,2) %if last timepoint
        Tracks{i} = nan(size(PCs.Orientation{i},1),2);
    else
        Tracks{i} = [ones(size(PCs.Orientation{i},1),1)*i + 1,(1:size(PCs.Orientation{i},1))'];
    end
end

%Check the size of each cell's centroid jump from one frame to the next. If it is bigger than the threshold (here the Euclidean distance between centre of the image and any corner), assume cell must have jumped due to boundary conditions
Threshold = sqrt((fS.maxX/2).^2 + (fS.maxY/2).^2);

for i = 1:size(PCs.Orientation,2)-1
    for j = 1:size(PCs.Centroid{i},1)
        nowPos = PCs.Centroid{i}(j,:);
        nextPos = PCs.Centroid{i+1}(j,:);
        eucDist = sqrt(sum((nowPos-nextPos).^2));
        
        if eucDist > Threshold
            Tracks{i}(j,:) = [NaN,NaN];
            Initials{i+1}(j) = 1;
        end
    end
end