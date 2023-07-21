clear all
close all

Root = 'N:\Big2DForceLengthSweep';
genericBranch = 'cellForce_%s_aspectRatios_%s_Repeat_1';
inTwig = 'SimulationResults.mat';
outTwig = 'Channel_1';

Forces = [0.25,0.5,1,2,4];
AspRats = [2,3,4,5,6,8];

Branches = cell(size(Forces,2)*size(AspRats,2),1);

count = 1;
for f = 1:size(Forces,2)
    for a = 1:size(AspRats,2)
        Branches{count} = sprintf(genericBranch,num2str(Forces(f)),num2str(AspRats(a)));
        count = count+1;
    end
end

outCellWidth = 5; %Width of exported rod image in pixels

for r = 1:size(Branches,1)
    load([Root,filesep,Branches{r},filesep,inTwig],'fieldSettings','dispSettings','trackableData')
    dispSettings.imagedirectory = [Root,filesep,Branches{r},filesep,outTwig];

    paintFieldReconstruction(trackableData,dispSettings,fieldSettings)
end