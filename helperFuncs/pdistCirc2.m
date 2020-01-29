function distMat = pdistCirc2(vecSet1,vecSet2,angMax)
%Calculates the circular disance between all vectors of vecSet1 and
%vecSet2. Does so assuming each NixM array vecSet1 and vecSet2 consists of
%Ni observations in M variables. Each vary should vary between 0 and a
%corresponding wraparound distance angMax.

if ~isempty(angMax)
    
    %Initialise storage matrix
    distMatFull = zeros(size(vecSet1,1),size(vecSet2,1),size(vecSet1,2));
    
    %For each variable, find the corresponding minimised wraparound distance
    %when subtracting dataset 2 from 1.
    for i = 1:size(vecSet1,2)
        for j = 1:size(vecSet1,1) %For each vector in set 1
            rawDiff = vecSet1(j,i) - vecSet2(:,i);
            rawDiff(rawDiff < -angMax(i)/2) = rawDiff(rawDiff < -angMax(i)/2) + angMax(i);
            rawDiff(rawDiff > angMax(i)/2) = rawDiff(rawDiff > angMax(i)/2) - angMax(i);
            distMatFull(j,:,i) = rawDiff;
        end
    end
    
    distMat = sqrt(sum(distMatFull.^2,3));
else
    distMat = zeros(size(vecSet1,1),size(vecSet2,1));
end