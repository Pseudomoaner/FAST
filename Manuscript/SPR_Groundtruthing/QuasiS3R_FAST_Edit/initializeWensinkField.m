function [Field,frameNo] = initializeWensinkField(fS,dS,cS,cST,bS,bST,frameNo)

%Initiate model and draw initial state

Field = WensinkField(fS.fieldWidth,fS.fieldHeight,fS.U0,fS.lam,fS.boundaryConditions);
Field = Field.populateField(bST,bS,cST,cS);
Field.drawField(dS.posVec,dS.colourCells,fS.maxX);
pause(0.1)

%Initial 'burn-in' - let initial random configuration settle.
for i = 1:fS.burnInSteps
    Field = Field.stepModel(fS.burnIndt,fS.f0,0,0,0,0,fS.divThresh,fS.postDivMovement,fS.colJigRate,dS.colourCells);
%     if rem(i,fS.FrameSkip) == 0
%         Field.drawField(dS.posVec);
%         pause(0.01)
%         if dS.saveFrames
%             overlay_image_path_temp = [dS.overlay_image_path,int2str(frameNo),'.jpg'];
%             overlay_image_path_temp = [dS.imagedirectory, filesep, overlay_image_path_temp];
%             
%             export_fig(overlay_image_path_temp,'-jpg','-m1')
%             reopenimage = imread(overlay_image_path_temp);
%             cropped=imcrop(reopenimage,dS.cropRect);
%             imwrite(cropped,overlay_image_path_temp,'jpeg')
%             
%             disp([overlay_image_path_temp,' saved.'])
%             
%             cla
%         end
%         frameNo = frameNo + 1;
%     end
end

[crossCell1,crossCell2] = Field.findCrossingCells(1:length(Field.aCells),1:length(Field.aCells));

while ~isempty(crossCell1)
    
    disp('Starting uncrossing')
    
    %After the initial burn in relaxation, jump any remaining crossing cells into non-crossing positions.
    Field = Field.jumpCrossersIntoSpaces();
    
    disp('Uncrossed cells')
    
    %Run additional burn in to let any closely spaced cells separate.
    for i = 1:fS.burnInSteps
        Field = Field.stepModel(fS.burnIndt,fS.f0,0,0,0,0,fS.divThresh,fS.postDivMovement,fS.colJigRate,dS.colourCells);
%         if rem(i,fS.FrameSkip) == 0
%             Field.drawField(dS.posVec);
%             pause(0.01)
%             if dS.saveFrames
%                 overlay_image_path_temp = [dS.overlay_image_path,int2str(frameNo),'.jpg'];
%                 overlay_image_path_temp = [dS.imagedirectory, filesep, overlay_image_path_temp];
%                 
%                 export_fig(overlay_image_path_temp,'-jpg','-m1')
%                 reopenimage = imread(overlay_image_path_temp);
%                 cropped=imcrop(reopenimage,dS.cropRect);
%                 imwrite(cropped,overlay_image_path_temp,'jpeg')
%                 
%                 disp([overlay_image_path_temp,' saved.'])
%                 
%                 cla
%             else
%                 Frames(frameNo) = getframe;
%             end
%             frameNo = frameNo + 1;
%         end
    end
    
    [crossCell1,crossCell2] = Field.findCrossingCells(1:length(Field.aCells),1:length(Field.aCells));
end