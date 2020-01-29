function [handles,plotSettings] = setupPlotGUIvisibilities(handles,plotSettings,procTracks,resetChecks)
%SETUPPLOTGUIVISIBILITIES is responsible for specifiying which elements of
%the plotTracks GUI are visible and/or available for modification at any
%given point, based on the currently selected plot type.
%
%   INPUTS:
%       -handles: Structure containing the elements of the plotTracks GUI
%       that you want to update.
%       -plotSettings: Structure containing plotting options, initially 
%       specified within the plotTracks GUI. May be updated by this function
%       -procTracks: Tracking data, the main output of the tracking GUI,
%       saved to the Tracks.mat file.
%       -resetChecks: Whether the checkboxes in the plotTracks GUI are to
%       be reset to 0 or not after this code terminates
%
%   OUTPUTS:
%       -handles: handles structure, with visibility and availability
%       options updated
%       -plotSettings: plotSettings structure, with checkbox settings reset
%       to 0 where needed
%
%   Author: Oliver J. Meacock

switch(plotSettings.plotType)
    case 'Choose plot type'
        handles.popupmenu2.Enable = 'off';
        handles.popupmenu3.Enable = 'off';
        handles.popupmenu7.Enable = 'off';
        handles.popupmenu7.Visible = 'off';
        
        handles.checkbox2.Enable = 'off';
        handles.checkbox2.Visible = 'off';
        handles.checkbox3.Enable = 'off';
        handles.checkbox3.Visible = 'off';
        handles.checkbox4.Enable = 'off';
        handles.checkbox4.Visible = 'off';
        handles.checkbox5.Enable = 'off';
        handles.checkbox5.Visible = 'off';
        handles.checkbox6.Enable = 'off';
        handles.checkbox6.Visible = 'off';
        
        %Setup text entry boxes
        handles.edit4.Enable = 'off';
        handles.edit5.Enable = 'off';
        handles.edit6.Enable = 'off';
        handles.edit7.Enable = 'off';
        handles.edit8.Enable = 'off';
        handles.edit4.Visible = 'off';
        handles.edit5.Visible = 'off';
        handles.edit6.Visible = 'off';
        handles.edit7.Visible = 'off';
        handles.edit8.Visible = 'off';
        handles.text12.Visible = 'off';
        handles.text13.Visible = 'off';
        handles.text14.Visible = 'off';
        handles.text15.Visible = 'off';
        handles.text16.Visible = 'off';
        handles.text17.Visible = 'off';
        
    case 'Timecourse'
        handles.popupmenu2.Enable = 'on';
        handles.popupmenu3.Enable = 'off';
        handles.popupmenu7.Enable = 'off';
        handles.popupmenu7.Visible = 'off';
        
        handles.checkbox2.Enable = 'on';
        handles.checkbox2.Visible = 'on';
        handles.checkbox2.String = 'Show standard deviation';
        handles.checkbox3.Enable = 'on';
        handles.checkbox3.Visible = 'on';
        handles.checkbox3.String = 'Show individual tracks';
        handles.checkbox4.Enable = 'off';
        handles.checkbox4.Visible = 'off';
        handles.checkbox5.Enable = 'off';
        handles.checkbox5.Visible = 'off';
        handles.checkbox6.Enable = 'off';
        handles.checkbox6.Visible = 'off';
        
        %Setup text entry boxes
        handles.edit4.Enable = 'off';
        handles.edit5.Enable = 'off';
        handles.edit6.Enable = 'off';
        handles.edit7.Enable = 'off';
        handles.edit8.Enable = 'off';
        handles.edit4.Visible = 'off';
        handles.edit5.Visible = 'off';
        handles.edit6.Visible = 'off';
        handles.edit7.Visible = 'off';
        handles.edit8.Visible = 'off';
        handles.text12.Visible = 'off';
        handles.text13.Visible = 'off';
        handles.text14.Visible = 'off';
        handles.text15.Visible = 'off';
        handles.text16.Visible = 'off';
        handles.text17.Visible = 'off';
        
        if resetChecks
            handles.checkbox2.Value = 0;
            plotSettings.check1 = 0;
            handles.checkbox3.Value = 0;
            plotSettings.check2 = 0;
        end
    case 'Histograms'
        handles.popupmenu2.Enable = 'on';
        handles.popupmenu3.Enable = 'off';
        handles.popupmenu7.Enable = 'off';
        handles.popupmenu7.Visible = 'off';
        
        handles.checkbox2.Enable = 'on';
        handles.checkbox2.Visible = 'on';
        handles.checkbox2.String = 'Rose plot';
        handles.checkbox3.Enable = 'on';
        handles.checkbox3.Visible = 'on';
        handles.checkbox3.String = 'T-test results';
        handles.checkbox4.Enable = 'on';
        handles.checkbox4.Visible = 'on';
        handles.checkbox4.String = 'Use track means';
        handles.checkbox5.Enable = 'off';
        handles.checkbox5.Visible = 'off';
        handles.checkbox6.Enable = 'off';
        handles.checkbox6.Visible = 'off';
        
        %Setup text entry boxes
        handles.edit4.Enable = 'off';
        handles.edit5.Enable = 'off';
        handles.edit6.Enable = 'off';
        handles.edit7.Enable = 'off';
        handles.edit8.Enable = 'off';
        handles.edit4.Visible = 'off';
        handles.edit5.Visible = 'off';
        handles.edit6.Visible = 'off';
        handles.edit7.Visible = 'off';
        handles.edit8.Visible = 'off';
        handles.text12.Visible = 'off';
        handles.text13.Visible = 'off';
        handles.text14.Visible = 'off';
        handles.text15.Visible = 'off';
        handles.text16.Visible = 'off';
        handles.text17.Visible = 'off';
        
        if resetChecks
            handles.checkbox2.Value = 0;
            plotSettings.check1 = 0;
            handles.checkbox3.Value = 0;
            plotSettings.check2 = 0;
            handles.checkbox4.Value = 0;
            plotSettings.check3 = 0;
        end
    case 'RMSD'
        handles.popupmenu2.Enable = 'off';
        handles.popupmenu3.Enable = 'off';        
        handles.popupmenu7.Enable = 'off';
        handles.popupmenu7.Visible = 'off';
        
        handles.checkbox2.Enable = 'on';
        handles.checkbox2.Visible = 'on';
        handles.checkbox2.String = 'Log-log axes';
        handles.checkbox3.Enable = 'on';
        handles.checkbox3.Visible = 'on';
        handles.checkbox3.String = 'Plot ballistic gradient';
        handles.checkbox4.Enable = 'on';
        handles.checkbox4.Visible = 'on';
        handles.checkbox4.String = 'Plot diffusive gradient';
        handles.checkbox5.Enable = 'on';
        handles.checkbox5.Visible = 'on';
        handles.checkbox5.String = 'Show sampling';
        handles.checkbox6.Enable = 'off';
        handles.checkbox6.Visible = 'off';
        
        %Setup text entry boxes
        handles.edit4.Enable = 'off';
        handles.edit5.Enable = 'off';
        handles.edit6.Enable = 'off';
        handles.edit7.Enable = 'off';
        handles.edit8.Enable = 'off';
        handles.edit4.Visible = 'off';
        handles.edit5.Visible = 'off';
        handles.edit6.Visible = 'off';
        handles.edit7.Visible = 'off';
        handles.edit8.Visible = 'off';
        handles.text12.Visible = 'off';
        handles.text13.Visible = 'off';
        handles.text14.Visible = 'off';
        handles.text15.Visible = 'off';
        handles.text16.Visible = 'off';
        handles.text17.Visible = 'off';
        
        if resetChecks
            handles.checkbox2.Value = 0;
            plotSettings.check1 = 0;
            handles.checkbox3.Value = 0;
            plotSettings.check2 = 0;
            handles.checkbox4.Value = 0;
            plotSettings.check3 = 0;
            handles.checkbox5.Value = 0;
            plotSettings.check4 = 0;
        end
    case 'Joint distribution'
        handles.popupmenu2.Enable = 'on';
        handles.popupmenu3.Enable = 'on';
        handles.popupmenu7.Enable = 'off';
        handles.popupmenu7.Visible = 'off';
        
        handles.checkbox2.Enable = 'on';
        handles.checkbox2.Visible = 'on';
        handles.checkbox2.String = 'Show correlation coefficient';
        handles.checkbox3.Enable = 'on';
        handles.checkbox3.Visible = 'on';
        handles.checkbox3.String = 'Plot linear fit';
        handles.checkbox4.Enable = 'off';
        handles.checkbox4.Visible = 'off';
        handles.checkbox5.Enable = 'off';
        handles.checkbox5.Visible = 'off';
        handles.checkbox6.Enable = 'off';
        handles.checkbox6.Visible = 'off';
        
        %Setup text entry boxes
        handles.edit4.Enable = 'off';
        handles.edit5.Enable = 'off';
        handles.edit6.Enable = 'off';
        handles.edit7.Enable = 'off';
        handles.edit8.Enable = 'off';
        handles.edit4.Visible = 'off';
        handles.edit5.Visible = 'off';
        handles.edit6.Visible = 'off';
        handles.edit7.Visible = 'off';
        handles.edit8.Visible = 'off';
        handles.text12.Visible = 'off';
        handles.text13.Visible = 'off';
        handles.text14.Visible = 'off';
        handles.text15.Visible = 'off';
        handles.text16.Visible = 'off';
        handles.text17.Visible = 'off';
        
        if resetChecks
            handles.checkbox2.Value = 0;
            plotSettings.check1 = 0;
            handles.checkbox3.Value = 0;
            plotSettings.check2 = 0;
        end
    case '2D histogram'
        handles.popupmenu2.Enable = 'on';
        handles.popupmenu3.Enable = 'on';
        handles.popupmenu7.Enable = 'on';
        handles.popupmenu7.Visible = 'on';
        
        handles.checkbox2.Enable = 'on';
        handles.checkbox2.Visible = 'on';
        handles.checkbox2.String = 'Show all sampling points';
        handles.checkbox3.Enable = 'off';
        handles.checkbox3.Visible = 'off';
        handles.checkbox4.Enable = 'off';
        handles.checkbox4.Visible = 'off';
        handles.checkbox5.Enable = 'off';
        handles.checkbox5.Visible = 'off';
        handles.checkbox6.Enable = 'off';
        handles.checkbox6.Visible = 'off';
        
        %Setup text entry boxes
        handles.edit4.Enable = 'off';
        handles.edit5.Enable = 'on';
        handles.edit6.Enable = 'on';
        handles.edit7.Enable = 'off';
        handles.edit8.Enable = 'off';
        handles.edit4.Visible = 'off';
        handles.edit5.Visible = 'on';
        handles.edit6.Visible = 'on';
        handles.edit7.Visible = 'off';
        handles.edit8.Visible = 'off';
        handles.text12.Visible = 'off';
        handles.text13.Visible = 'on';
        handles.text13.String = 'X bin spacing';
        handles.text14.Visible = 'on';
        handles.text14.String = 'Y bin spacing';
        handles.text15.Visible = 'off';
        handles.text16.Visible = 'off';
        handles.text17.Visible = 'on';
        
        if resetChecks
            handles.checkbox2.Value = 0;
            plotSettings.check1 = 0;
            handles.edit5.String = '1';
            handles.edit6.String = '1';
            handles.popupmenu7.Value = 1;
            
            %Get the range of the selected field
            xField = plotSettings.data1;
            yField = plotSettings.data2;

            xDat = [];
            yDat = [];
            
            for i = 1:size(procTracks,2)
                xDat = [xDat;procTracks(i).(xField)];
                yDat = [yDat;procTracks(i).(yField)];
            end
            
            minX = min(xDat);
            maxX = max(xDat);
            minY = min(yDat);
            maxY = max(yDat);
            
            plotSettings.edit2 = (maxX-minX)/20;
            plotSettings.edit2Min = (maxX-minX)/1000;
            plotSettings.edit2Max = maxX-minX;
            plotSettings.edit3 = (maxY-minY)/20;
            plotSettings.edit3Min = (maxY-minY)/1000;
            plotSettings.edit3Max = maxY-minY;
            
            plotSettings.ColourMap = handles.popupmenu7.String{1};
        end
   case 'Event centred average'
        handles.popupmenu2.Enable = 'on';
        handles.popupmenu3.Enable = 'off';
        handles.popupmenu7.Enable = 'off';
        handles.popupmenu7.Visible = 'off';
        
        handles.checkbox2.Enable = 'off';
        handles.checkbox2.Visible = 'off';
        handles.checkbox3.Enable = 'on';
        handles.checkbox3.Visible = 'on';
        handles.checkbox3.String = 'Show standard deviation';
        handles.checkbox4.Enable = 'on';
        handles.checkbox4.Visible = 'on';
        handles.checkbox4.String = 'Show individual tracks';
        handles.checkbox5.Enable = 'off';
        handles.checkbox5.Visible = 'off';
        handles.checkbox6.Enable = 'off';
        handles.checkbox6.Visible = 'off';
        
        %Setup text entry boxes
        handles.edit4.Enable = 'on';
        handles.edit5.Enable = 'off';
        handles.edit6.Enable = 'off';
        handles.edit7.Enable = 'off';
        handles.edit8.Enable = 'off';
        handles.edit4.Visible = 'on';
        handles.edit5.Visible = 'off';
        handles.edit6.Visible = 'off';
        handles.edit7.Visible = 'off';
        handles.edit8.Visible = 'off';
        handles.text12.Visible = 'on';
        handles.text12.String = 'Event class to use';
        handles.text13.Visible = 'off';
        handles.text14.Visible = 'off';
        handles.text15.Visible = 'off';
        handles.text16.Visible = 'off';
        handles.text17.Visible = 'off';
        
        if resetChecks
            handles.checkbox3.Value = 0;
            plotSettings.check2 = 0;
            handles.checkbox4.Value = 0;
            plotSettings.check3 = 0;
            
            %Find the largest event index used 
            maxE = 0;
            for i = 1:size(procTracks,2)
                if max(procTracks(i).event) > maxE
                    maxE = max(procTracks(i).event);
                end
            end
            handles.edit4.String = '1';
            plotSettings.edit1 = 1;
            plotSettings.edit1Min = 1;
            plotSettings.edit1Max = 0;
            plotSettings.edit1Max = maxE;
        end
    case 'Division centred average'
        handles.popupmenu2.Enable = 'on';
        handles.popupmenu3.Enable = 'off';
        handles.popupmenu7.Enable = 'off';
        handles.popupmenu7.Visible = 'off';
        
        handles.checkbox2.Enable = 'on';
        handles.checkbox2.Visible = 'on';
        handles.checkbox2.String = 'Show standard deviation';
        handles.checkbox3.Enable = 'on';
        handles.checkbox3.Visible = 'on';
        handles.checkbox3.String = 'Show individual tracks';
        handles.checkbox4.Enable = 'off';
        handles.checkbox4.Visible = 'off';
        handles.checkbox5.Enable = 'off';
        handles.checkbox5.Visible = 'off';
        handles.checkbox6.Enable = 'off';
        handles.checkbox6.Visible = 'off';
        
        %Setup text entry boxes
        handles.edit4.Enable = 'off';
        handles.edit5.Enable = 'off';
        handles.edit6.Enable = 'off';
        handles.edit7.Enable = 'off';
        handles.edit8.Enable = 'off';
        handles.edit4.Visible = 'off';
        handles.edit5.Visible = 'off';
        handles.edit6.Visible = 'off';
        handles.edit7.Visible = 'off';
        handles.edit8.Visible = 'off';
        handles.text12.Visible = 'off';
        handles.text13.Visible = 'off';
        handles.text14.Visible = 'off';
        handles.text15.Visible = 'off';
        handles.text16.Visible = 'off';        
        handles.text17.Visible = 'off';
        
        if resetChecks
            handles.checkbox2.Value = 0;
            plotSettings.check1 = 0;
            handles.checkbox3.Value = 0;
            plotSettings.check2 = 0;
        end
    case 'Cartouche'
        handles.popupmenu2.Enable = 'off';
        handles.popupmenu3.Enable = 'off';
        handles.popupmenu7.Enable = 'off';
        handles.popupmenu7.Visible = 'off';
        
        handles.checkbox2.Enable = 'off';
        handles.checkbox2.Visible = 'off';
        handles.checkbox3.Enable = 'off';
        handles.checkbox3.Visible = 'off';
        handles.checkbox4.Enable = 'off';
        handles.checkbox4.Visible = 'off';
        handles.checkbox5.Enable = 'on';
        handles.checkbox5.Visible = 'on';
        handles.checkbox5.String = 'Align cells?';
        handles.checkbox6.Enable = 'off';
        handles.checkbox6.Visible = 'off';
        
        %Setup text entry boxes
        handles.edit4.Enable = 'on';
        handles.edit5.Enable = 'on';
        handles.edit6.Enable = 'on';
        handles.edit7.Enable = 'off';
        handles.edit8.Enable = 'off';
        handles.edit4.Visible = 'on';
        handles.edit5.Visible = 'on';
        handles.edit6.Visible = 'on';
        handles.edit7.Visible = 'off';
        handles.edit8.Visible = 'off';
        handles.text12.Visible = 'on';
        handles.text12.String = 'Track ID';
        handles.text13.Visible = 'on';
        handles.text13.String = 'Start frame';
        handles.text14.Visible = 'on';
        handles.text14.String = 'Length';
        handles.text15.Visible = 'off';
        handles.text16.Visible = 'off';
        handles.text17.Visible = 'off';
        
        if resetChecks
            trackName = fieldnames(procTracks);
            
            handles.edit4.String = '1';
            plotSettings.edit1 = 1;
            plotSettings.edit1Min = 1;
            plotSettings.edit1Max = size(procTracks,2);
            handles.edit5.String = '1';
            plotSettings.edit2 = 1;
            plotSettings.edit2Min = 1;
            plotSettings.edit2Max = size(procTracks(1).(trackName{1}),1);
            handles.edit6.String = num2str(size(procTracks(1).(trackName{1}),1));
            plotSettings.edit3 = size(procTracks(1).(trackName{1}),1);
            plotSettings.edit3Min = 1;
            plotSettings.edit3Max = size(procTracks(1).(trackName{1}),1) - plotSettings.edit2 + 1;
            handles.checkbox5.Value = 0;
            plotSettings.check4 = 0;
        end
    case 'Kymograph'
        handles.popupmenu2.Enable = 'off';
        handles.popupmenu3.Enable = 'off';
        handles.popupmenu7.Enable = 'off';
        handles.popupmenu7.Visible = 'off';
        
        handles.checkbox2.Enable = 'off';
        handles.checkbox2.Visible = 'off';
        handles.checkbox3.Enable = 'on';
        handles.checkbox3.Visible = 'on';
        handles.checkbox3.String = 'Equate lengths?';
        handles.checkbox4.Enable = 'off';
        handles.checkbox4.Visible = 'off';
        handles.checkbox5.Enable = 'off';
        handles.checkbox5.Visible = 'off';
        handles.checkbox6.Enable = 'off';
        handles.checkbox6.Visible = 'off';
        
        %Setup text entry boxes
        handles.edit4.Enable = 'on';
        handles.edit5.Enable = 'off';
        handles.edit6.Enable = 'off';
        handles.edit7.Enable = 'off';
        handles.edit8.Enable = 'off';
        handles.edit4.Visible = 'on';
        handles.edit5.Visible = 'off';
        handles.edit6.Visible = 'off';
        handles.edit7.Visible = 'off';
        handles.edit8.Visible = 'off';
        handles.text12.Visible = 'on';
        handles.text12.String = 'Track ID';
        handles.text13.Visible = 'off';
        handles.text14.Visible = 'off';
        handles.text15.Visible = 'off';
        handles.text16.Visible = 'off';
        handles.text17.Visible = 'off';
        
        if resetChecks
            trackName = fieldnames(procTracks);
            
            handles.edit4.String = '1';
            plotSettings.edit1 = 1;
            plotSettings.edit1Min = 1;
            plotSettings.edit1Max = size(procTracks,2);
            handles.edit5.String = '1';
            plotSettings.edit2 = 1;
            plotSettings.edit2Min = 1;
            plotSettings.edit2Max = size(procTracks(1).(trackName{1}),1);
            handles.edit6.String = num2str(size(procTracks(1).(trackName{1}),1));
            plotSettings.edit3 = size(procTracks(1).(trackName{1}),1);
            plotSettings.edit3Min = 1;
            plotSettings.edit3Max = size(procTracks(1).(trackName{1}),1) - plotSettings.edit2 + 1;
            handles.checkbox5.Value = 0;
            plotSettings.check4 = 0;
        end
end

%Reset population selection boxes if needed
if resetChecks
    plotSettings.showAll = 1;
    plotSettings.show1 = 0;
    plotSettings.show2 = 0;
    plotSettings.show3 = 0;
    
    handles.checkbox1.Value = 1;
    handles.checkbox13.Value = 0;
    handles.checkbox14.Value = 0;
    handles.checkbox15.Value = 0;
end

%Setup cell population selection
if isfield(procTracks,'population')
    
    
    %Check if each population is marked
    pop1Flag = false;
    pop2Flag = false;
    pop3Flag = false;
    for i = 1:size(procTracks,2)
        if procTracks(i).population == 1
            pop1Flag = true;
            break
        end
    end
    for i = 1:size(procTracks,2)
        if procTracks(i).population == 2
            pop2Flag = true;
            break
        end
    end
    for i = 1:size(procTracks,2)
        if procTracks(i).population == 3
            pop3Flag = true;
            break
        end
    end
    
    %Setup checkboxes accordingly    
    if pop1Flag
        handles.checkbox13.Enable = 'on';
        handles.checkbox13.Visible = 'on';
        handles.edit1.Enable = 'on';
        handles.edit1.Visible = 'on';
        handles.text8.Visible = 'on';
        handles.pushbutton2.Enable = 'on';
        handles.pushbutton2.Visible = 'on';
    else
        handles.checkbox13.Enable = 'off';
        handles.checkbox13.Visible = 'off';
        handles.edit1.Enable = 'off';
        handles.edit1.Visible = 'off';
        handles.text8.Visible = 'off';
        handles.pushbutton2.Enable = 'off';
        handles.pushbutton2.Visible = 'off';
    end
    if pop2Flag
        handles.checkbox14.Enable = 'on';
        handles.checkbox14.Visible = 'on';
        handles.edit2.Enable = 'on';
        handles.edit2.Visible = 'on';
        handles.text9.Visible = 'on';
        handles.pushbutton3.Enable = 'on';
        handles.pushbutton3.Visible = 'on';
    else
        handles.checkbox14.Enable = 'off';
        handles.checkbox14.Visible = 'off';
        handles.edit2.Enable = 'off';
        handles.edit2.Visible = 'off';
        handles.text9.Visible = 'off';
        handles.pushbutton3.Enable = 'off';
        handles.pushbutton3.Visible = 'off';
    end
    if pop3Flag
        handles.checkbox15.Enable = 'on';
        handles.checkbox15.Visible = 'on';
        handles.edit3.Enable = 'on';
        handles.edit3.Visible = 'on';
        handles.text10.Visible = 'on';
        handles.pushbutton4.Enable = 'on';
        handles.pushbutton4.Visible = 'on';
    else
        handles.checkbox15.Enable = 'off';
        handles.checkbox15.Visible = 'off';
        handles.edit3.Enable = 'off';
        handles.edit3.Visible = 'off';
        handles.text10.Visible = 'off';
        handles.pushbutton4.Enable = 'off';
        handles.pushbutton4.Visible = 'off';
    end
else %Always plot all the data - don't allow the user to change this
    handles.uibuttongroup2.Visible = 'off';
    handles.checkbox1.Enable = 'off';
    handles.checkbox1.Visible = 'off';
    handles.checkbox13.Enable = 'off';
    handles.checkbox13.Visible = 'off';
    handles.checkbox14.Enable = 'off';
    handles.checkbox14.Visible = 'off';
    handles.checkbox15.Enable = 'off';
    handles.checkbox15.Visible = 'off';
    
    handles.edit1.Enable = 'off';
    handles.edit1.Visible = 'off';
    handles.text8.Visible = 'off';
    handles.pushbutton2.Enable = 'off';
    handles.pushbutton2.Visible = 'off';
    handles.edit2.Enable = 'off';
    handles.edit2.Visible = 'off';
    handles.text9.Visible = 'off';
    handles.pushbutton3.Enable = 'off';
    handles.pushbutton3.Visible = 'off';
    handles.edit3.Enable = 'off';
    handles.edit3.Visible = 'off';
    handles.text10.Visible = 'off';
    handles.pushbutton4.Enable = 'off';
    handles.pushbutton4.Visible = 'off';
end