function chanSettings = ChannelPicker(meansActive,stdsActive,meansOn,stdsOn)
% CHANNELPICKER programmatically creates a small GUI that allows the user
% to select a subset of channels to process/include. Allows separate
% definition of mean and std channel information.
%
%   INPUTS:
%       -meansActive: Logical vector indicating the channel means that are
%       open to selection
%       -stdsActive: Logical vector indicating the channel standard
%       deviations that are open to selection
%   
%   OUTPUTS:
%       -chanSettings: A simple structure, containing the selected channels
%       as arrays of zeros and ones.
%
%   Author: Oliver J. Meacock, (c) 2019
    
    %Initialise such that if user clicks cross in top right hand corner,
    %returns zeros for all channels.
    chanSettings.chanMeans = zeros(numel(meansActive),1);
    chanSettings.chanStds = zeros(numel(stdsActive),1);
    
    noChans = max(numel(meansActive),numel(stdsActive));

    % Construct the components.
    f = figure('Visible','off','Position',[200,200,300,125+noChans*25],'DockControls','off','MenuBar','none','name','Please pick channels','NumberTitle','off','WindowStyle','modal');
    
    hTxt1 = uicontrol('Style','text','String','Include mean:','Position',[25,75+noChans*25,125,25],'FontSize',10,'HorizontalAlignment','left');
    hTxt2 = uicontrol('Style','text','String','Include std:','Position',[175,75+noChans*25,125,25],'FontSize',10,'HorizontalAlignment','left');
    
    hMeans = cell(numel(meansActive),1);
    hStds = cell(numel(stdsActive),1);
    for i = 1:noChans
        hMeans{i} = uicontrol('Style','checkbox',...
            'String',['Channel ',num2str(i)],'Position',[25,75 + (noChans-i)*25,125,25],'Value',1);
        if ~meansActive(i)
            hMeans{i}.Enable = 'off';
            hMeans{i}.Value = 0;
        else
            hMeans{i}.Enable = 'on';
            if meansOn(i)
                hMeans{i}.Value = 1;
            else
                hMeans{i}.Value = 0;
            end
        end
        hStds{i} = uicontrol('Style','checkbox',...
            'String',['Channel ',num2str(i)],'Position',[175,75 + (noChans-i)*25,125,25],'Value',1);
        if ~stdsActive(i)
            hStds{i}.Enable = 'off';
            hStds{i}.Value = 0;
        else
            hStds{i}.Enable = 'on';
            if stdsOn(i)
                hStds{i}.Value = 1;
            else
                hStds{i}.Value = 0;
            end
        end
    end
    
    for i = 1:noChans %This loop ensures that the previous settings are retained, even if the user hits the cross (instead of 'pick channels' or whatever)
        chanSettings.chanMeans(i) = hMeans{i}.Value;
        chanSettings.chanStds(i) = hStds{i}.Value;
    end
    
    hButton = uicontrol('Style','pushbutton','String','Make selection','Position',[100,25,100,25],'Callback',@button_Callback);
    
    f.Visible = 'on';
    
    waitfor(f) %Ensures the function doesn't terminate until either the button callback is triggered, or the figure is closed.
    
    function button_Callback(source,eventdata)
        % Get current status of checkboxes, close figure and return
        % settings.        
        for k = 1:noChans
            chanSettings.chanMeans(k) = hMeans{k}.Value;
            chanSettings.chanStds(k) = hStds{k}.Value;
        end
        
        close(f)
        return
    end
end

