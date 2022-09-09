function [field] = simulateWensinkFieldBurnIn(startField,fS,dS)
%Separate simulation to allow simulation to settle into passive configuration without cell motility, growth or tilting taking place.
field = startField;

fC = 0;
for i = 1:fS.burnInSteps
    fprintf('Burn-in frame is %i of %i.\n',i,fS.burnInSteps)
    
    field = field.stepModel(fS.burnIndt,fS.f0,inf,0,fS.divThresh,fS.postDivMovement,fS.colJigRate,dS.colourCells);
end