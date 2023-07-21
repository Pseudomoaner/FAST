function okSim = checkTimestepAppropriate(PCs,fS)
%Used to establish if the timestep parameter chosen to simulate thie set of parameters is appropriate.
%If it is too large, then the system should explode, with cells becomeing more
%widely separated than their theoretical speed limit allows.

frame1 = PCs.Centroid{1};
frame2 = PCs.Centroid{2};

%Choose only those cells cells that start near to the centre of the frame
goodStartInds = and(and(frame1(:,1) < fS.fieldWidth - 5,frame1(:,1) > 5),and(frame1(:,2) < fS.fieldHeight - 5,frame1(:,2) > 5));

frame1 = frame1(goodStartInds,:);
frame2 = frame2(goodStartInds,:);

%Calculate the distance moved by all central cells between frames
dists = sqrt(sum((frame1-frame2).^2,2));

%If any of the cells seem to have ended up jumping around, mark the simulation as crappy
if sum(dists > 10) >= 1
    okSim = false;
else
    okSim = true;
end