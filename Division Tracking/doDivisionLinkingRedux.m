function [linkArray1,linkArray2,acceptDiffs,rejectDiffs] = doDivisionLinkingRedux(tgtMat,pred1Mat,pred2Mat,linkStats,incRad,returnSteps)
%DODIRECTLINKINGREDUX performs object-object linking based on minimisation
%of the distance between sequential objects in the normalised displacement
%space.
%
%   INPUTS:
%       -tgtMat: The 'target' matrix, indicating the true feature values of
%       all daughter cells across all time points. Split into linear and
%       circular fields, 'lin' and 'circ', for linear and circular data.
%       -pred1Mat: The first 'prediction' matrix, indicating the predicted
%       feature values of daughter cells based on the values of the mothers
%       in the dataset.
%       -pred2Mat: The second 'prediction' matrix.
%       -linkStats: Statistics necessary for normalisation of features
%       provided in tgtMat and pred1Mat/pred2Mat. Output from
%       gatherDivisionStats.
%       -incRad: User-defined cutoff threshold to separate positive
%       links from negative links. Negative links are not assigned.
%       -returnSteps: Set true to return the displacements (in the normalised
%       feature space) of the positive and negative links. Used for
%       plotting projections of the normalised displacement space.
%
%   OUTPUTS:
%       -linkArray1: Array containing divisions detected for the first
%       daughter in each pair, with its predicted location given by 
%       pred1Mat. Column 1 contains the maternal track ID, column 2 the 
%       daughter track ID, column 3 the link score associated with this link.
%       -linkArray2: Array containing divisions detected for the second
%       daughter in each pair. Note that some mothers can give rise to a
%       single daughter if the second assignment has a link score above the
%       given threshold. This means linkArray2 can be a different length
%       from linkArray1.
%       -acceptDiffs:Displacements (in normalised feature space) of the 
%       accepted links. Undefined if returnSteps is set to false.
%       -rejectDiffs: Displacements (in normalised feature space) of the 
%       rejected links. Undefined if returnSteps is set to false.
%
%   Author: Oliver J. Meacock (c) 2019]

if returnSteps
    acceptDiffs = [];
    rejectDiffs = [];
end

%Unpack the linkStats structure (to reduce line lengths later)
linDs = linkStats.linDs; 
linCs = linkStats.linCs;
linMs = linkStats.linMs;
circDs = linkStats.circDs;
circCs = linkStats.circCs;
circMs = linkStats.circMs;

if ~isempty(tgtMat.lin) && ~isempty(pred1Mat.lin) && ~isempty(pred2Mat.lin)
    %Normalize steps by subtracting mean drift from second frame and dividing both by the SD.
    linFrameT = tgtMat.lin(:,2:end)./repmat(linDs,size(tgtMat.lin,1),1);
    linFrameP1 = (pred1Mat.lin(:,2:end) + repmat(linMs,size(pred1Mat.lin,1),1))./repmat(linDs,size(pred1Mat.lin,1),1);
    linFrameP2 = (pred2Mat.lin(:,2:end) + repmat(linMs,size(pred2Mat.lin,1),1))./repmat(linDs,size(pred2Mat.lin,1),1);
    
    if ~ isempty(circMs)
        circFrameT = tgtMat.circ(:,3:end)./repmat(circDs,size(tgtMat.circ,1),1);
        circFrameP1 = (pred1Mat.circ(:,3:end) + repmat(circMs,size(pred1Mat.circ,1),1))./repmat(circDs,size(pred1Mat.circ,1),1);
        circFrameP2 = (pred2Mat.circ(:,3:end) + repmat(circMs,size(pred1Mat.circ,1),1))./repmat(circDs,size(pred1Mat.circ,1),1);
    else
        circFrameT = 0;
        circFrameP1 = 0;
        circFrameP2 = 0;
    end
    angMax = 1./circDs;
    
    DL1 = pdist2(linFrameT,linFrameP1); %Distance between the target (daughter) and 1st predicted (from mother) cells - linear stats
    DL2 = pdist2(linFrameT,linFrameP2);
    DC1 = pdistCirc2(circFrameT,circFrameP1,angMax);
    DC2 = pdistCirc2(circFrameT,circFrameP2,angMax);
    
    D1 = (DL1.^2 + DC1.^2).^0.5; %Distance measure for the first predicted daughter location - targets (daughters) in the rows, predictions (mothers) in the columns
    D2 = (DL2.^2 + DC2.^2).^0.5; %Distance measure for the second predicted daughter location
    
    %Some of these will correspond to predictation and targets at the same time point. That makes no sense - you can't be in both a pre and post-division state at once - set these comparisons to be infinitely large.
    TT = repmat(tgtMat.lin(:,2),1,size(pred1Mat.lin,1));
    TP = repmat(pred1Mat.lin(:,2)'-1,size(tgtMat.lin,1),1);
    sameT = TT == TP;
    
    D1(sameT) = Inf;
    D2(sameT) = Inf;
    
    %Set comparisons of self to self to Inf (no links to self)
    indT = repmat(tgtMat.lin(:,1),1,size(pred1Mat.lin,1));
    indP = repmat(pred1Mat.lin(:,1)'-1,size(tgtMat.lin,1),1);
    sameInd = indT == indP;
    
    D1(sameInd) = Inf;
    D2(sameInd) = Inf;
    
    %This is a hack to make sure the following code terminates if D is empty
    if isempty(D1)
        D1 = incRad + 1;
    end
    if isempty(D2)
        D2 = incRad + 1;
    end
    
    cycleCount = 0;
    linkArray1 = [];
    tgtMatCpy = tgtMat;
    
    %Run through the distance matrix for the first daughter cell location prediction and the second cell location prediction separately - ensures each mother can be assigned to a maximum of two daughters (one from each prediction matrix)   
    while min(D1(:)) < incRad %Assume 'diffusive' motion within the isotropic Gaussian feature space (displacement proportional to sqrt time).
        
        %Find the minimum distance between frames at the moment
        [minVal,minInd] = min(D1(:));
        [Ind1,Ind2] = ind2sub(size(D1),minInd);
        motherID = pred1Mat.lin(Ind2,1);
        daughterID = tgtMatCpy.lin(Ind1,1);
        
        if returnSteps
            fromFeatsLin = pred1Mat.lin(Ind2,2:end)./linDs;
            toFeatsLin = (tgtMatCpy.lin(Ind1,2:end) - linMs)./linDs;
            if ~isempty(circMs)
                fromFeatsCirc = pred1Mat.circ(Ind2,3:end)./circDs;
                toFeatsCirc = (tgtMatCpy.circ(Ind1,3:end) - circMs)./circDs;
            else
                fromFeatsCirc = [];
                toFeatsCirc = [];
            end
            acceptDiffs = [acceptDiffs;fromFeatsLin-toFeatsLin,pdistCirc2(fromFeatsCirc,toFeatsCirc,angMax)];
        end
        
        %Eliminate from distance matrix and feature matrices, and link cells.
        pred1Mat.lin(Ind2,:) = [];
        pred1Mat.circ(Ind2,:) = [];
        tgtMatCpy.lin(Ind1,:) = [];
        tgtMatCpy.circ(Ind1,:) = [];
        D1(Ind1,:) = [];
        D1(:,Ind2) = [];
        
        linkArray1 = [linkArray1;motherID,daughterID,minVal];        
        cycleCount = cycleCount + 1;
        
        %This is another hack to make sure the code terminates if you've run out of cells to assign to or from.
        if isempty(D1)
            D1 = incRad + 1;
        end
    end
    
    %Do a last sweep through the distance matrix to get all the steps that didn't quite make the cut.
    if returnSteps
        while ~isempty(D1)
            if  D1 == incRad + 1
                D1 = [];
            else
                %Find the minimum distance between frames at the moment
                [~,minInd] = min(D1(:));
                [Ind1,Ind2] = ind2sub(size(D1),minInd);
                
                fromFeatsLin = pred1Mat.lin(Ind2,2:end)./linDs;
                toFeatsLin = (tgtMatCpy.lin(Ind1,2:end) - linMs)./linDs;
                if ~isempty(circMs)
                    fromFeatsCirc = pred1Mat.circ(Ind2,3:end)./circDs;
                    toFeatsCirc = (tgtMatCpy.circ(Ind1,3:end) - circMs)./circDs;
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
                pred1Mat.lin(Ind2,:) = [];
                pred1Mat.circ(Ind2,:) = [];
                tgtMatCpy.lin(Ind1,:) = [];
                tgtMatCpy.circ(Ind1,:) = [];
                D1(Ind1,:) = [];
                D1(:,Ind2) = [];
                
                cycleCount = cycleCount + 1;
            end
        end
    end
    
    cycleCount = 0;
    linkArray2 = [];
    tgtMatCpy = tgtMat;
    
    %Run through the distance matrix for the first daughter cell location prediction and the second cell location prediction separately - ensures each mother can be assigned to a maximum of two daughters (one from each prediction matrix)   
    while min(D2(:)) < incRad %Assume 'diffusive' motion within the isotropic Gaussian feature space (displacement proportional to sqrt time).
        
        %Find the minimum distance between frames at the moment
        [minVal,minInd] = min(D2(:));
        [Ind1,Ind2] = ind2sub(size(D2),minInd);
        motherID = pred2Mat.lin(Ind2,1);
        daughterID = tgtMatCpy.lin(Ind1,1);
        
        if returnSteps
            fromFeatsLin = pred2Mat.lin(Ind2,2:end)./linDs;
            toFeatsLin = (tgtMatCpy.lin(Ind1,2:end) - linMs)./linDs;
            if ~isempty(circMs)
                fromFeatsCirc = pred2Mat.circ(Ind2,3:end)./circDs;
                toFeatsCirc = (tgtMatCpy.circ(Ind1,3:end) - circMs)./circDs;
            else
                fromFeatsCirc = [];
                toFeatsCirc = [];
            end
            acceptDiffs = [acceptDiffs;fromFeatsLin-toFeatsLin,pdistCirc2(fromFeatsCirc,toFeatsCirc,angMax)];
        end
        
        %Eliminate from distance matrix and feature matrices, and link cells.
        pred2Mat.lin(Ind2,:) = [];
        pred2Mat.circ(Ind2,:) = [];
        tgtMatCpy.lin(Ind1,:) = [];
        tgtMatCpy.circ(Ind1,:) = [];
        D2(Ind1,:) = [];
        D2(:,Ind2) = [];
        
        linkArray2 = [linkArray2;motherID,daughterID,minVal];        
        cycleCount = cycleCount + 1;
        
        %This is another hack to make sure the code terminates if you've run out of cells to assign to or from.
        if isempty(D2)
            D2 = incRad + 1;
        end
    end
    
    %Do a last sweep through the distance matrix to get all the steps that didn't quite make the cut.
    if returnSteps
        while ~isempty(D2)
            if  D2 == incRad + 1
                D2 = [];
            else
                %Find the minimum distance between frames at the moment
                [~,minInd] = min(D2(:));
                [Ind1,Ind2] = ind2sub(size(D2),minInd);
                
                fromFeats = pred2Mat.lin(Ind2,2:end)./linDs;
                toFeats = (tgtMatCpy.lin(Ind1,2:end) - linMs)./linDs;
                if ~isempty(circMs)
                    fromFeatsCirc = pred2Mat.circ(Ind2,3:end)./circDs;
                    toFeatsCirc = (tgtMatCpy.circ(Ind1,3:end) - circMs)./circDs;
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
                pred2Mat.lin(Ind2,:) = [];
                pred2Mat.circ(Ind2,:) = [];
                tgtMatCpy.lin(Ind1,:) = [];
                tgtMatCpy.circ(Ind1,:) = [];
                D2(Ind1,:) = [];
                D2(:,Ind2) = [];
                
                cycleCount = cycleCount + 1;
            end
        end
    end
    
%     %In cases where the same target cell is linked to by both predictor arrays, accept the link that has the lower feature distance score
%     [~,eqTgt1,eqTgt2] = intersect(linkArray1(:,1),linkArray2(:,1));
%     eqTgt1f = find(eqTgt1);
%     eqTgt2f = find(eqTgt2);
%     eqScore1 = linkArray1(eqTgt1f,3);
%     eqScore2 = linkArray2(eqTgt2f,3);
%     
%     linkArray1(eqTgt1f(eqScore1 > eqScore2),:) = [];
%     linkArray2(eqTgt2f(eqScore1 < eqScore2),:) = [];
    
if ~isempty(linkArray1)
    linkArray1 = linkArray1(:,1:2);
end
if ~isempty(linkArray2)
    linkArray2 = linkArray2(:,1:2);
end
end