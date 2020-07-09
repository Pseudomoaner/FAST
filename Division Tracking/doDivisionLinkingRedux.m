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
%   Author: Oliver J. Meacock (c) 2019

if returnSteps
    acceptDiffs = [];
    rejectDiffs = [];
end

%Unpack the linkStats structure (to reduce line lengths later)
covDf = linkStats.covDfs;
linMs = linkStats.linMs;
circMs = linkStats.circMs;

if ~isempty(tgtMat.lin) && ~isempty(pred1Mat.lin) && ~isempty(pred2Mat.lin)
    %Normalize steps by subtracting mean drift from second frame and dividing both by the SD.
    linFrameT = tgtMat.lin(:,2:end);
    linFrameP1 = pred1Mat.lin(:,2:end) + repmat(linMs,size(pred1Mat.lin,1),1);
    linFrameP2 = pred2Mat.lin(:,2:end) + repmat(linMs,size(pred2Mat.lin,1),1);
    
    fullLinFrameT = repmat(reshape(linFrameT,[size(linFrameT,1),1,size(linFrameT,2)]),[1,size(linFrameP1,1),1]);
    fullLinFrameP1 = repmat(reshape(linFrameP1,[1,size(linFrameP1,1),size(linFrameP1,2)]),[size(linFrameT,1),1,1]);
    fullLinFrameP2 = repmat(reshape(linFrameP2,[1,size(linFrameP2,1),size(linFrameP2,2)]),[size(linFrameT,1),1,1]);
    
    if ~ isempty(circMs)
        circFrameT = tgtMat.circ(:,2:end);
        circFrameP1 = pred1Mat.circ(:,2:end) + repmat(circMs,size(pred1Mat.circ,1),1);
        circFrameP2 = pred2Mat.circ(:,2:end) + repmat(circMs,size(pred2Mat.circ,1),1);
        
        fullCircFrameT = repmat(reshape(circFrameT,[size(circFrameT,1),1,size(circFrameT,2)]),[1,size(circFrameP1,1),1]);
        fullCircFrameP1 = repmat(reshape(circFrameP1,[1,size(circFrameP1,1),size(circFrameP1,2)]),[size(circFrameT,1),1,1]);
        fullCircFrameP2 = repmat(reshape(circFrameP2,[1,size(circFrameP2,1),size(circFrameP2,2)]),[size(circFrameT,1),1,1]);
    else
        fullCircFrameT = zeros(size(fullLinFrameT,1),size(fullLinFrameT,2),0);
        fullCircFrameP1 = zeros(size(fullLinFrameP1,1),size(fullLinFrameP1,2),0);
        fullCircFrameP2 = zeros(size(fullLinFrameP2,1),size(fullLinFrameP2,2),0);
    end
    deltaF1 = cat(3,fullLinFrameP1-fullLinFrameT,mod(fullCircFrameP1-fullCircFrameT+0.5,1)-0.5);
    deltaF2 = cat(3,fullLinFrameP2-fullLinFrameT,mod(fullCircFrameP2-fullCircFrameT+0.5,1)-0.5);
    
    [covEig,covDiag] = eig(covDf);
    adjCov = covEig*(covDiag^(-1/2))*covEig'; %Principal inverse square root (equivalent to covDfs^-1/2, but we need covEig for rotating back into the feature basis later so may as well write it out in full)
    
    %I'll assume here that there is sufficiently little data that we can go
    %stright to the 'normalised' distance matrices (without worrying about the
    %two sweeps performed in doDirectLinkingRedux to speed things up)
    D1 = zeros(size(deltaF1,1),size(deltaF1,2));
    D2 = zeros(size(deltaF2,1),size(deltaF2,2));
    for i = 1:size(D1,1)
        for j = 1:size(D1,2)
            D1(i,j) = norm(adjCov*squeeze(deltaF1(i,j,:)));
        end
    end
    for i = 1:size(D2,1)
        for j = 1:size(D2,2)
            D2(i,j) = norm(adjCov*squeeze(deltaF2(i,j,:)));
        end
    end
    
    %Some of these will correspond to predictation and targets at the same time point. That makes no sense - you can't be in both a pre and post-division state at once - set these comparisons to be infinitely large.
    TT = repmat(tgtMat.lin(:,2),1,size(pred1Mat.lin,1));
    TP = repmat(pred1Mat.lin(:,2)'-1,size(tgtMat.lin,1),1);
    sameT = TT == TP;
    
    D1(sameT) = Inf;
    D2(sameT) = Inf;
    
    %Set comparisons of self to self to Inf (stop links to self)
    indT = repmat(tgtMat.lin(:,1),1,size(pred1Mat.lin,1));
    indP = repmat(pred1Mat.lin(:,1)'-1,size(tgtMat.lin,1),1);
    sameInd = indT == indP;
    
    D1(sameInd) = Inf;
    D2(sameInd) = Inf;
    
    %This is a hack to make sure the following code terminates if D1 or D2 is empty
    if isempty(D1)
        D1 = incRad + 1;
    end
    if isempty(D2)
        D2 = incRad + 1;
    end
    
    cycleCount = 0;
    linkArray1 = [];
    tgtMatCpy = tgtMat; %Need to make a copy so you can still delete rows/columns during sweep 1 while retaining the original data for sweep 2.
    
    Mmaps = [pred1Mat.lin(:,1),(1:size(pred1Mat.lin,1))']; %Maps from track index to distance matrix index, for use during reconstruction of feature differences
    Dmaps = [tgtMat.lin(:,1),(1:size(tgtMat.lin,1))'];
    
    %Run through the distance matrix for the first daughter cell location prediction and the second cell location prediction separately - ensures each mother can be assigned to a maximum of two daughters (one from each prediction matrix)   
    while min(D1(:)) < incRad %Assume 'diffusive' motion within the isotropic Gaussian feature space (displacement proportional to sqrt time).
        
        %Find the minimum distance between frames at the moment
        [minVal,minInd] = min(D1(:));
        [Ind1,Ind2] = ind2sub(size(D1),minInd);
        motherID = pred1Mat.lin(Ind2,1);
        daughterID = tgtMatCpy.lin(Ind1,1);
        
        if returnSteps
            mIdx = Mmaps(Mmaps(:,1) == motherID,2);
            dIdx = Dmaps(Dmaps(:,1) == daughterID,2);
            Mmaps(Mmaps(:,1) == motherID,:) = [];
            Dmaps(Dmaps(:,1) == daughterID,:) = [];
            
            singDHF = adjCov*squeeze(deltaF1(dIdx,mIdx,:));
            acceptDiffs = [acceptDiffs,covEig'*singDHF];
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
                motherID = pred1Mat.lin(Ind2,1);
                daughterID = tgtMatCpy.lin(Ind1,1);
                
                mIdx = Mmaps(Mmaps(:,1) == motherID,2);
                dIdx = Dmaps(Dmaps(:,1) == daughterID,2);
                Mmaps(Mmaps(:,1) == motherID,:) = [];
                Dmaps(Dmaps(:,1) == daughterID,:) = [];
                
                singDHF = adjCov*squeeze(deltaF1(dIdx,mIdx,:));
                rejectDiffs = [rejectDiffs,covEig'*singDHF];
                
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
    
    Mmaps = [pred2Mat.lin(:,1),(1:size(pred2Mat.lin,1))'];
    Dmaps = [tgtMat.lin(:,1),(1:size(tgtMat.lin,1))'];
    
    %Run through the distance matrix for the first daughter cell location prediction and the second cell location prediction separately - ensures each mother can be assigned to a maximum of two daughters (one from each prediction matrix)   
    while min(D2(:)) < incRad %Assume 'diffusive' motion within the isotropic Gaussian feature space (displacement proportional to sqrt time).
        
        %Find the minimum distance between frames at the moment
        [minVal,minInd] = min(D2(:));
        [Ind1,Ind2] = ind2sub(size(D2),minInd);
        motherID = pred2Mat.lin(Ind2,1);
        daughterID = tgtMatCpy.lin(Ind1,1);
        
        if returnSteps
            mIdx = Mmaps(Mmaps(:,1) == motherID,2);
            dIdx = Dmaps(Dmaps(:,1) == daughterID,2);
            Mmaps(Mmaps(:,1) == motherID,:) = [];
            Dmaps(Dmaps(:,1) == daughterID,:) = [];
            
            singDHF = adjCov*squeeze(deltaF2(dIdx,mIdx,:));
            acceptDiffs = [acceptDiffs,covEig'*singDHF];
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
                motherID = pred2Mat.lin(Ind2,1);
                daughterID = tgtMatCpy.lin(Ind1,1);
                
                mIdx = Mmaps(Mmaps(:,1) == motherID,2);
                dIdx = Dmaps(Dmaps(:,1) == daughterID,2);
                Mmaps(Mmaps(:,1) == motherID,:) = [];
                Dmaps(Dmaps(:,1) == daughterID,:) = [];
                
                singDHF = adjCov*squeeze(deltaF2(dIdx,mIdx,:));
                rejectDiffs = [rejectDiffs,covEig'*singDHF];
                
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
