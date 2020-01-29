function [Tracks,Initials,fromLinFeatMats,fromCircFeatMats,toLinFeatMats,toCircFeatMats,acceptDiffs,rejectDiffs] = doDirectLinkingRedux(fromLinFeatMats,fromCircFeatMats,toLinFeatMats,toCircFeatMats,linkStats,tgtDensity,gapSize,returnSteps,debugSet)
%DODIRECTLINKINGREDUX performs object-object linking based on minimisation
%of the distance between sequential objects in the normalised displacement
%space.
%
%   INPUTS:
%       -fromLinFeatMats: Feature matrices for the linear features
%       (e.g. position, length). Output from gatherLinkStats.m.
%       -fromCircFeatMats: Feature matrices for the circular features
%       (e.g. orientation, direction of motion). Output from 
%       gatherLinkStats.m.
%       -toLinFeatMats: Feature matrices for the linear features. Typically
%       identical to fromLinFeatMats initially, but is eventually modified.
%       -toCircFeatMats: Feature matrices for the circular features. Typically
%       identical to fromCircFeatMats initially, but is eventually modified.
%       -linkStats: Statistics necessary for normalisation of features
%       provided in fromLinFeatMats and fromCircFeatMats. Output from
%       gatherLinkStats
%       -tgtDensity: User-defined cutoff threshold to separate positive
%       links from negative links. Negative links are not assigned.
%       -gapSize: User-defined maximal gap (in frames) that can be bridged
%       by the algorithm.
%       -returnSteps: Set true to return the displacements (in the normalised
%       feature space) of the positive and negative links. Used for
%       plotting projections of the normalised displacement space.
%       -debugSet: Set true if FAST is in debug mode.
%
%   OUTPUTS:
%       -Tracks: Cell array with one cell per frame of the input dataset,
%       with each cell containing an O by 2 matrix where O is the total
%       number of objects in that frame. Column 1 indicates the frame this
%       object links to, column 2 the object index within this frame. Use
%       extractDataTrack.m to convert to a more standard data track format.
%       -Initials: Cell array with one cell per frame of the input dataset,
%       with each cell containing an O by 1 logical vector. Each element
%       indicates if the corresponding object is at the start of a track.
%       Used by extractDataTrack.m.
%       -fromLinFeatMats: Feature matrices for linear features. This
%       version has had all objects assigned FROM deleted.
%       -fromCircFeatMats: Feature matrices for circular features. This
%       version has had all objects assigned FROM deleted.
%       -toLinFeatMats: Feature matrices for linear features. This
%       version has had all objects assigned TO deleted.
%       -toCircFeatMats: Feature matrices for circular features. This
%       version has had all objects assigned TO deleted.
%       -acceptDiffs:Displacements (in normalised feature space) of the 
%       accepted links. Undefined if returnSteps is set to false.
%       -rejectDiffs: Displacements (in normalised feature space) of the 
%       rejected links. Undefined if returnSteps is set to false.
%
%   Author: Oliver J. Meacock (c) 2019

fromLinFeatMatsCpy = fromLinFeatMats;
fromCircFeatMatsCpy = fromCircFeatMats;
toLinFeatMatsCpy = toLinFeatMats;
toCircFeatMatsCpy = toCircFeatMats;

%Preallocate tracks
Tracks = cell(size(fromLinFeatMats));
Initials = cell(size(fromLinFeatMats));
for i = 1:size(fromLinFeatMats,1)
    Tracks{i} = nan(size(fromLinFeatMats{i},1),2);
    Initials{i} = true(size(fromLinFeatMats{i},1),1);
end

if returnSteps %If the user wants to inspect the (normalized) steps calculated during this part of the algorithm
    acceptDiffs = [];
    rejectDiffs = [];
end

%Unpack the linkStats structure (to reduce line lengths later)
linDs = linkStats.linDs; 
linEs = linkStats.linEs;
linMs = linkStats.linMs;
circDs = linkStats.circDs;
circEs = linkStats.circEs;
circMs = linkStats.circMs;
trackability = linkStats.trackability;

%Calculate the desired inclusion radius from the target density
noFeats = size(linDs,2) + size(circDs,2);
densities = 10.^(-trackability);
rescale = tgtDensity./densities;
incRads = NsphereVol2Rad(rescale,noFeats);

debugprogressbar([0.4;0;0],debugSet);

for j = 1:gapSize
    for i = 1:length(fromLinFeatMats) - j        
        if ~isempty(fromLinFeatMats{i}) && ~isempty(toLinFeatMats{i+j})
            linFrame1 = fromLinFeatMats{i}(:,2:end)./repmat(linDs(i,:),size(fromLinFeatMats{i},1),1);
            linFrame2 = (toLinFeatMats{i+j}(:,2:end) + repmat(sum(mean(linMs(i:i+j-1,:),1),1),size(toLinFeatMats{i+j},1),1))./repmat(linDs(i,:),size(toLinFeatMats{i+j},1),1);
            if ~ isempty(circMs)
                circFrame1 = fromCircFeatMats{i}(:,2:end)./repmat(circDs(i,:),size(fromCircFeatMats{i},1),1);
                circFrame2 = (toCircFeatMats{i+j}(:,2:end) + repmat(sum(mean(circMs(i:i+j-1,:),1),1),size(toCircFeatMats{i+j},1),1))./repmat(circDs(i,:),size(toCircFeatMats{i+j},1),1);
            else
                circFrame1 = zeros(size(fromCircFeatMats{i},1),1);
                circFrame2 = zeros(size(toCircFeatMats{i+j},1),1);
            end
            incRad = incRads(i); %Dynamically vary inclusion radius to keep density of target volume the same
            angMax = 1./circDs(i,:);
            
            D1 = pdist2(linFrame1,linFrame2);
            D2 = pdistCirc2(circFrame1,circFrame2,angMax);
            
            D = (D1.^2 + D2.^2).^0.5;
            
            %This is a hack to make sure the following code terminates if D is empty
            if isempty(D)
                D = incRad*sqrt(j) + 1;
            end
            
            %Most objects will normally be assignable to just a single object in the
            %next frame, based on the value of incRad, or none at all. Deal
            %with these cases first.
            Dnan = D;
            Dnan(D>incRad*sqrt(j)) = NaN;
            
            %Go through each row, assigning the single available link (or
            %none at all)
            delInds1 = [];
            delInds2 = [];
            
            nanNosDim1 = sum(~isnan(Dnan),1);
            
            for Ind1 = 1:size(Dnan,1) %For each row of D
                rowOpts = ~isnan(Dnan(Ind1,:));
                if sum(rowOpts) == 1 %Maybe assign link...
                    colNans = nanNosDim1(rowOpts);
                    if colNans == 1 %Actually assign link
                        Ind2 = find(rowOpts);
                        
                        frame1Loc = fromLinFeatMats{i}(Ind1,1);
                        frame2Loc = toLinFeatMats{i+j}(Ind2,1);
                        
                        delInds1 = [delInds1;Ind1];
                        delInds2 = [delInds2;Ind2];
                        
                        %The below will only activate if 'Test Track' has been
                        %pushed - so don't need to worry about dealing with
                        %frame-frame linking, which is only applicable to the
                        %whole dataset tracking step.
                        if returnSteps
                            fromFeatsLin = fromLinFeatMats{i}(Ind1,2:end)./linDs;
                            toFeatsLin = (toLinFeatMats{i+j}(Ind2,2:end) + linMs*j)./linDs;
                            if ~isempty(circMs)
                                fromFeatsCirc = fromCircFeatMats{i}(Ind1,2:end)./circDs;
                                toFeatsCirc = (toCircFeatMats{i+j}(Ind2,2:end) + circMs*j)./circDs;
                                
                                rawDiff = fromFeatsCirc - toFeatsCirc;
                                
                                for a = 1:size(angMax,2)
                                    rawDiff(rawDiff(:,a) < -angMax(a)/2,a) = rawDiff(rawDiff(:,a) < -angMax(a)/2,a) + angMax(a);
                                    rawDiff(rawDiff(:,a) > angMax(a)/2,a) = rawDiff(rawDiff(:,a) > angMax(a)/2,a) - angMax(a);
                                end
                            else
                                rawDiff = [];
                            end
                            acceptDiffs = [acceptDiffs;fromFeatsLin-toFeatsLin,rawDiff];
                        end
                        Tracks{i}(frame1Loc,1) = i + j;
                        Tracks{i}(frame1Loc,2) = frame2Loc;
                        Initials{i+j}(frame2Loc) = 0;
                    end
                end
            end
            
            %Eliminate from distance matrix and feature matrices
            D(delInds1,:) = [];
            D(:,delInds2) = [];
            
            fromLinFeatMats{i}(delInds1,:) = [];
            fromCircFeatMats{i}(delInds1,:) = [];
            toLinFeatMats{i+j}(delInds2,:) = [];
            toCircFeatMats{i+j}(delInds2,:) = [];
            
            cycleCount = 0;
            
            [minD,minInd] = min(D(:));
            
            while minD < incRad*sqrt(j) %Assume 'diffusive' motion within the isotropic Gaussian feature space (displacement proportional to sqrt time).                
                %Find the minimum distance between frames at the moment
                [Ind1,Ind2] = ind2sub(size(D),minInd);
                frame1Loc = fromLinFeatMats{i}(Ind1,1);
                frame2Loc = toLinFeatMats{i+j}(Ind2,1);
                
                if returnSteps
                    fromFeatsLin = fromLinFeatMats{i}(Ind1,2:end)./linDs;
                    toFeatsLin = (toLinFeatMats{i+j}(Ind2,2:end) + linMs*j)./linDs;
                    if ~isempty(circMs)
                        fromFeatsCirc = fromCircFeatMats{i}(Ind1,2:end)./circDs;
                        toFeatsCirc = (toCircFeatMats{i+j}(Ind2,2:end) + circMs*j)./circDs;
                    else
                        fromFeatsCirc = [];
                        toFeatsCirc = [];
                    end
                    acceptDiffs = [acceptDiffs;fromFeatsLin-toFeatsLin,pdistCirc2(fromFeatsCirc,toFeatsCirc,angMax)];
                end
                
                %Eliminate from distance matrix and feature matrices, and link cells.
                fromLinFeatMats{i}(Ind1,:) = [];
                fromCircFeatMats{i}(Ind1,:) = [];
                toLinFeatMats{i+j}(Ind2,:) = [];
                toCircFeatMats{i+j}(Ind2,:) = [];
                D(Ind1,:) = [];
                D(:,Ind2) = [];
                
                Tracks{i}(frame1Loc,1) = i + j;
                Tracks{i}(frame1Loc,2) = frame2Loc;
                Initials{i+j}(frame2Loc) = 0;
                
                cycleCount = cycleCount + 1;
                
                %This is another hack to make sure the code terminates if you've run out of cells to assign to or from.
                if isempty(D)
                    D = incRad*sqrt(j) + 1;
                end
                
                [minD,minInd] = min(D(:));
                
                debugprogressbar([0.4+((j-1)/gapSize)*0.2;(i-1)/(length(fromLinFeatMats) - j);cycleCount/size(D1,1)],debugSet)
            end
            
            %Do a last sweep through the distance matrix to get all the steps that didn't quite make the cut.
            if returnSteps
                while ~isempty(D)
                    if  D == incRad*sqrt(j) + 1
                        D = [];
                    else
                        %Find the minimum distance between frames at the moment
                        [~,minInd] = min(D(:));
                        [Ind1,Ind2] = ind2sub(size(D),minInd);
                        
                        fromFeatsLin = fromLinFeatMats{i}(Ind1,2:end)./linDs;
                        toFeatsLin = (toLinFeatMats{i+j}(Ind2,2:end) + linMs*j)./linDs;
                        if ~isempty(circMs)
                            fromFeatsCirc = fromCircFeatMats{i}(Ind1,2:end)./circDs;
                            toFeatsCirc = (toCircFeatMats{i+j}(Ind2,2:end) + circMs*j)./circDs;
                            rawDiff = fromFeatsCirc - toFeatsCirc;
                            
                            for a = 1:size(angMax,2)
                                rawDiff(rawDiff(:,a) < -angMax(a)/2,a) = rawDiff(rawDiff(:,a) < -angMax(a)/2,a) + angMax(a);
                                rawDiff(rawDiff(:,a) > angMax(a)/2,a) = rawDiff(rawDiff(:,a) > angMax(a)/2,a) - angMax(a);
                            end
                        else
                            rawDiff = [];
                        end
                        rejectDiffs = [rejectDiffs;fromFeatsLin-toFeatsLin,rawDiff];
                        
                        %Eliminate from distance matrix and feature matrices, and link cells.
                        fromLinFeatMats{i}(Ind1,:) = [];
                        fromCircFeatMats{i}(Ind1,:) = [];
                        toLinFeatMats{i+j}(Ind2,:) = [];
                        toCircFeatMats{i+j}(Ind2,:) = [];
                        D(Ind1,:) = [];
                        D(:,Ind2) = [];
                        
                        cycleCount = cycleCount + 1;
                    end
                end
            end
        end
    end
end