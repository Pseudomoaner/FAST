function outPhi = wrapAngleTimecourse(inPhi)
%WRAPPHIS takes the given list of angles and adds or subtracts increments 
%of 180 degrees to ensure that it changes smoothly over time.
%
%   INPUTS:
%       -inPhi: A tx1 vector of angles, assumed to be in degrees.
%
%   OUTPUTS:
%       -outPhi: A tx1 vector of angles, which changes smoothly.
%
%   Author: Oliver J. Meacock, (c) 2019

diffPhi = diff(inPhi);
stepsUp = diffPhi > 90;
stepsDown = diffPhi < -90;
cumulativeStepAdj = cumsum(stepsDown-stepsUp);
cumulativeStepAdj = [0;cumulativeStepAdj]; %Accounts for the fact that you can't test for a switch in the first timepoint (so inPhi and cumulativeStepAdj are different sizes)
outPhi = inPhi + cumulativeStepAdj*180;