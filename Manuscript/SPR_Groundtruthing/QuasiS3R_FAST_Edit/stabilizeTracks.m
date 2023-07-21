function [UndriftCentroid,cumDisp] = stabilizeTracks(CentroidStore,timeStore,dt)
    %Subtracts the mean drift across all cells between each frame and the
    %next, removing any drift caused by changes in camera/field position.
    
    %Find latest time point
    maxT = 0;
    for j = 1:length(timeStore)
        if max(timeStore{j}) > maxT
            maxT = max(timeStore{j});
        end
    end
    maxF = round(maxT/dt);
    
    dispStore = cell(maxF-1,1);
    for j = 1:length(timeStore)
        currDisps = diff(CentroidStore{j},1,1);
        for k = 1:length(timeStore{j})-1
            currTime = round(timeStore{j}(k)/dt);
            dispStore{currTime} = [dispStore{currTime};currDisps(k,:)];
        end
    end
    
    meanDisp = zeros(maxF-1,3);
    for j = 1:length(dispStore)
        if ~isempty(dispStore{j})
            meanDisp(j,:) = mean(dispStore{j},1);
        else
            meanDisp(j,:) = zeros(1,3);
        end
    end
    
    cumDisp = cumsum(meanDisp); %Cumulative average displacement - tells you where the frame is now relative to the original position of the frame.
    
    %Adjust the tracks by removing the culmative frame movement
    UndriftCentroid = CentroidStore;
    for j = 1:length(timeStore)
        for k = 1:length(timeStore{j})
            currTime = round(timeStore{j}(k)/dt);
            if currTime ~= maxF
                UndriftCentroid{j}(k,:) = UndriftCentroid{j}(k,:) - cumDisp(currTime,:);
            else
                UndriftCentroid{j}(k,:) = UndriftCentroid{j}(k,:) - cumDisp(end,:);
            end
        end
    end
end