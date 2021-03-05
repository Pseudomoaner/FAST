function varargout = plotTracks(varargin)
% PLOTTRACKS MATLAB code for plotTracks.fig
%      PLOTTRACKS, by itself, creates a new PLOTTRACKS or raises the existing
%      singleton*.
%
%      H = PLOTTRACKS returns the handle to a new PLOTTRACKS or the handle to
%      the existing singleton*.
%
%      PLOTTRACKS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLOTTRACKS.M with the given input arguments.
%
%      PLOTTRACKS('Property','Value',...) creates a new PLOTTRACKS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before plotTracks_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to plotTracks_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help plotTracks

% Last Modified by GUIDE v2.5 16-Apr-2019 16:32:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @plotTracks_OpeningFcn, ...
                   'gui_OutputFcn',  @plotTracks_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before plotTracks is made visible.
function plotTracks_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to plotTracks (see VARARGIN)

% Choose default command line output for plotTracks
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes plotTracks wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global root
global plotSettings
global procTracks

root = varargin{1}.rootdir;

load([root,filesep,'Tracks.mat'])
plotSettings.pixSize = trackSettings.pixSize;
plotSettings.maxX = trackSettings.maxX;
plotSettings.maxY = trackSettings.maxY;
plotSettings.maxF = trackSettings.maxFrame;
plotSettings.dt = trackSettings.dt;
plotSettings.frameOffset = trackSettings.minFrame - 1;
plotSettings.pseudoTracks = trackSettings.pseudoTracks;

%Setup data popup menus
[plotTypePopups,dataPopups] = setupPlotPopupStrings(procTracks,plotSettings,root);

handles.popupmenu1.String = plotTypePopups;
handles.popupmenu2.String = dataPopups;
handles.popupmenu3.String = dataPopups;

plotSettings.plotType = handles.popupmenu1.String{handles.popupmenu1.Value};
plotSettings.data1 = switchVarName(root,handles.popupmenu2.String{handles.popupmenu2.Value},'hName','ptName');
plotSettings.data2 = switchVarName(root,handles.popupmenu3.String{handles.popupmenu3.Value},'hName','ptName');
plotSettings.ColourMap = handles.popupmenu7.String{handles.popupmenu7.Value};

%Setup option boxes visibilities, titles etc.
[handles,plotSettings] = setupPlotGUIvisibilities(handles,plotSettings,procTracks,true);

%Default legend to be off
plotSettings.legendSwitch = 0;

%Setup the axis properties
handles.axes1.LineWidth = 2;
handles.axes1.Box = 'on';

%Default population tags, plot colours
plotSettings.popTags = {'All','Population 1','Population 2','Population 3'};
plotSettings.plotColours = {[0.33,0.33,0.33],[1,0,0],[0,1,0],[0,0,1]};

handles.pushbutton1.BackgroundColor = plotSettings.plotColours{1};
handles.pushbutton1.ForegroundColor = [1,1,1] - plotSettings.plotColours{1};
handles.pushbutton2.BackgroundColor = plotSettings.plotColours{2};
handles.pushbutton2.ForegroundColor = [1,1,1] - plotSettings.plotColours{2};
handles.pushbutton3.BackgroundColor = plotSettings.plotColours{3};
handles.pushbutton3.ForegroundColor = [1,1,1] - plotSettings.plotColours{3};
handles.pushbutton4.BackgroundColor = plotSettings.plotColours{4};
handles.pushbutton4.ForegroundColor = [1,1,1] - plotSettings.plotColours{4};

% --- Outputs from this function are returned to the command line.
function varargout = plotTracks_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
global plotSettings
global procTracks
global plotExport
global root

plotSettings.plotType = handles.popupmenu1.String{handles.popupmenu1.Value};
[handles,plotSettings] = setupPlotGUIvisibilities(handles,plotSettings,procTracks,true);

[plotExport,handles.axes1] = runPlotting(procTracks,plotSettings,root,handles.axes1,handles.figure1);
guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2
global plotSettings
global procTracks
global plotExport
global root

plotSettings.data1 = switchVarName(root,handles.popupmenu2.String{handles.popupmenu2.Value},'hName','ptName');

if strcmp(plotSettings.plotType,'2D histogram')
    %Get the range of the selected field
    xField = plotSettings.data1;
    
    xDat = [];
    
    for i = 1:size(procTracks,2)
        xDat = [xDat;procTracks(i).(xField)];
    end
    
    minX = min(xDat);
    maxX = max(xDat);
    
    plotSettings.edit2 = (maxX-minX)/20;
    plotSettings.edit2Min = (maxX-minX)/1000;
    plotSettings.edit2Max = maxX-minX;
    
    handles.edit5.String = string(plotSettings.edit2);
end

[plotExport,handles.axes1] = runPlotting(procTracks,plotSettings,root,handles.axes1,handles.figure1); 
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3
global plotSettings
global procTracks
global plotExport
global root

plotSettings.data2 = switchVarName(root,handles.popupmenu3.String{handles.popupmenu3.Value},'hName','ptName');

if strcmp(plotSettings.plotType,'2D histogram')
    %Get the range of the selected field
    yField = plotSettings.data2;
    
    yDat = [];
    
    for i = 1:size(procTracks,2)
        yDat = [yDat;procTracks(i).(yField)];
    end
    
    minY = min(yDat);
    maxY = max(yDat);
    
    plotSettings.edit3 = (maxY-minY)/20;
    plotSettings.edit3Min = (maxY-minY)/1000;
    plotSettings.edit3Max = maxY-minY;
    
    handles.edit6.String = string(plotSettings.edit3);
end

[plotExport,handles.axes1] = runPlotting(procTracks,plotSettings,root,handles.axes1,handles.figure1); 
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% The settings checkboxes

% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2
global plotSettings
global procTracks
global plotExport
global root

plotSettings.check1 = get(hObject,'Value');
[plotExport,handles.axes1] = runPlotting(procTracks,plotSettings,root,handles.axes1,handles.figure1); 
guidata(hObject,handles)

% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3
global plotSettings
global procTracks
global plotExport
global root

plotSettings.check2 = get(hObject,'Value');
[plotExport,handles.axes1] = runPlotting(procTracks,plotSettings,root,handles.axes1,handles.figure1); 
guidata(hObject,handles)

% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4
global plotSettings
global procTracks
global plotExport
global root

plotSettings.check3 = get(hObject,'Value');
[plotExport,handles.axes1] = runPlotting(procTracks,plotSettings,root,handles.axes1,handles.figure1); 
guidata(hObject,handles)

% --- Executes on button press in checkbox5.
function checkbox5_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox5
global plotSettings
global procTracks
global plotExport
global root

plotSettings.check4 = get(hObject,'Value');
[plotExport,handles.axes1] = runPlotting(procTracks,plotSettings,root,handles.axes1,handles.figure1); 
guidata(hObject,handles)

% --- Executes on button press in checkbox6.
function checkbox6_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox6
global plotSettings
global procTracks
global plotExport
global root

plotSettings.check5 = get(hObject,'Value');
[plotExport,handles.axes1] = runPlotting(procTracks,plotSettings,root,handles.axes1,handles.figure1); 
guidata(hObject,handles)

% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1
global plotSettings
global procTracks
global plotExport
global root

plotSettings.showAll = get(hObject,'Value');

%Allow selection of only a single population if plot type requires it
if strcmp(plotSettings.plotType,'2D histogram')
    plotSettings.show1 = false;
    plotSettings.show2 = false;
    plotSettings.show3 = false;
    
    handles.checkbox13.Value = 0;
    handles.checkbox14.Value = 0;
    handles.checkbox15.Value = 0;
end

[plotExport,handles.axes1] = runPlotting(procTracks,plotSettings,root,handles.axes1,handles.figure1); 
guidata(hObject,handles)

% --- Executes on button press in checkbox13.
function checkbox13_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox13
global plotSettings
global procTracks
global plotExport
global root

plotSettings.show1 = get(hObject,'Value');

%Allow selection of only a single population if plot type requires it
if strcmp(plotSettings.plotType,'2D histogram')
    plotSettings.showAll = false;
    plotSettings.show2 = false;
    plotSettings.show3 = false;
    
    handles.checkbox1.Value = 0;
    handles.checkbox14.Value = 0;
    handles.checkbox15.Value = 0;
end

[plotExport,handles.axes1] = runPlotting(procTracks,plotSettings,root,handles.axes1,handles.figure1); 
guidata(hObject,handles)

% --- Executes on button press in checkbox14.
function checkbox14_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox14
global plotSettings
global procTracks
global plotExport
global root

plotSettings.show2 = get(hObject,'Value');

%Allow selection of only a single population if plot type requires it
if strcmp(plotSettings.plotType,'2D histogram')
    plotSettings.showAll = false;
    plotSettings.show1 = false;
    plotSettings.show3 = false;
    
    handles.checkbox1.Value = 0;
    handles.checkbox13.Value = 0;
    handles.checkbox15.Value = 0;
end

[plotExport,handles.axes1] = runPlotting(procTracks,plotSettings,root,handles.axes1,handles.figure1); 
guidata(hObject,handles)

% --- Executes on button press in checkbox15.
function checkbox15_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox15
global plotSettings
global procTracks
global plotExport
global root

plotSettings.show3 = get(hObject,'Value');

%Allow selection of only a single population if plot type requires it
if strcmp(plotSettings.plotType,'2D histogram')
    plotSettings.showAll = false;
    plotSettings.show1 = false;
    plotSettings.show2 = false;
    
    handles.checkbox1.Value = 0;
    handles.checkbox13.Value = 0;
    handles.checkbox14.Value = 0;
end

[plotExport,handles.axes1] = runPlotting(procTracks,plotSettings,root,handles.axes1,handles.figure1); 
guidata(hObject,handles)

%% The edit settings fields

function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double
global plotSettings
global procTracks
global plotExport
global root

txtVal = str2num(get(hObject,'String'));

if txtVal < plotSettings.edit1Min
    txtVal = plotSettings.edit1Min;
elseif txtVal > plotSettings.edit1Max
    txtVal = plotSettings.edit1Max;
end

if strcmp(plotSettings.plotType,'Cartouche')
    plotSettings.edit3Max = size(procTracks(txtVal).x,1) - plotSettings.edit2 + 1;
    plotSettings.edit2Max = plotSettings.edit3Max;
    
    plotSettings.edit3 = plotSettings.edit3Max;
    handles.edit6.String = num2str(plotSettings.edit3);
    plotSettings.edit2 = 1;
    handles.edit5.String = num2str(plotSettings.edit2);
end

plotSettings.edit1 = txtVal;
handles.edit4.String = num2str(txtVal);

[plotExport,handles.axes1] = runPlotting(procTracks,plotSettings,root,handles.axes1,handles.figure1); 
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double

% --- Executes during object creation, after setting all properties.
global plotSettings
global procTracks
global plotExport
global root

txtVal = str2num(get(hObject,'String'));

if txtVal < plotSettings.edit2Min
    txtVal = plotSettings.edit2Min;
elseif txtVal > plotSettings.edit2Max
    txtVal = plotSettings.edit2Max;
end

if strcmp(plotSettings.plotType,'Cartouche')
    plotSettings.edit3Max = plotSettings.edit2Max - txtVal + 1;
    
    if plotSettings.edit3Max < plotSettings.edit3
        plotSettings.edit3 = plotSettings.edit3Max;
        handles.edit6.String = num2str(plotSettings.edit3);
    end
end

plotSettings.edit2 = txtVal;
handles.edit5.String = num2str(txtVal);

[plotExport,handles.axes1] = runPlotting(procTracks,plotSettings,root,handles.axes1,handles.figure1); 
guidata(hObject,handles)

function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double
global plotSettings
global procTracks
global plotExport
global root

txtVal = str2num(get(hObject,'String'));

if txtVal < plotSettings.edit3Min
    txtVal = plotSettings.edit3Min;
elseif txtVal > plotSettings.edit3Max
    txtVal = plotSettings.edit3Max;
end

plotSettings.edit3 = txtVal;
handles.edit6.String = num2str(txtVal);

[plotExport,handles.axes1] = runPlotting(procTracks,plotSettings,root,handles.axes1,handles.figure1); 
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double
global plotSettings
global procTracks
global plotExport
global root

txtVal = str2num(get(hObject,'String'));

if txtVal < plotSettings.edit4Min
    txtVal = plotSettings.edit4Min;
elseif txtVal > plotSettings.edit4Max
    txtVal = plotSettings.edit4Max;
end

plotSettings.edit4 = txtVal;
handles.edit7.String = num2str(txtVal);

[plotExport,handles.axes1] = runPlotting(procTracks,plotSettings,root,handles.axes1,handles.figure1); 
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double
global plotSettings
global procTracks
global plotExport
global root

txtVal = str2num(get(hObject,'String'));

if txtVal < plotSettings.edit5Min
    txtVal = plotSettings.edit5Min;
elseif txtVal > plotSettings.edit5Max
    txtVal = plotSettings.edit5Max;
end

plotSettings.edit5 = txtVal;
handles.edit8.String = num2str(txtVal);

[plotExport,handles.axes1] = runPlotting(procTracks,plotSettings,root,handles.axes1,handles.figure1); 
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% The colourmap dropdown menu

% --- Executes on selection change in popupmenu7.
function popupmenu7_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu7 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu7
global plotSettings
global procTracks
global plotExport
global root

plotSettings.ColourMap = handles.popupmenu7.String{handles.popupmenu7.Value};

[plotExport,handles.axes1] = runPlotting(procTracks,plotSettings,root,handles.axes1,handles.figure1); 
guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function popupmenu7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% The three save options

% --------------------------------------------------------------------
function Save_Callback(hObject, eventdata, handles)
% hObject    handle to Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function export_data_Callback(hObject, eventdata, handles)
% hObject    handle to export_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global plotExport
global plotSettings
global root

if isdeployed
    save([root,filesep,'plotDataExport.mat'],'plotExport','plotSettings','-v6')
else
    save([root,filesep,'plotDataExport.mat'],'plotExport','plotSettings','-v7.3')
end

% --------------------------------------------------------------------
function save_fig_Callback(hObject, eventdata, handles)
% hObject    handle to save_fig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global root

Fig2 = figure;
copyobj(handles.axes1, Fig2);
newAx = Fig2.CurrentAxes;
newAx.Units = 'normalized';
newAx.Position = [0.1,0.12,0.85,0.83];
hgsave(Fig2, [root,filesep,'exportedPlot.fig']);

close(Fig2)

% --------------------------------------------------------------------
function save_tif_Callback(hObject, eventdata, handles)
% hObject    handle to save_tif (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global root

export_fig(handles.axes1,[root,filesep,'exportedPlot.tif'],'-tif','-m1')


% --------------------------------------------------------------------
function uitoggletool5_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global plotSettings
global procTracks
global plotExport
global root

if plotSettings.legendSwitch == 1
    plotSettings.legendSwitch = 0;
else
    plotSettings.legendSwitch = 1;
end
[plotExport,handles.axes1] = runPlotting(procTracks,plotSettings,root,handles.axes1,handles.figure1); 
guidata(hObject,handles)

%% The population tag edit boxes 

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
global plotSettings
global procTracks
global plotExport
global root

plotSettings.popTags{2} = get(hObject,'String');
[plotExport,handles.axes1] = runPlotting(procTracks,plotSettings,root,handles.axes1,handles.figure1); 
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double
global plotSettings
global procTracks
global plotExport
global root

plotSettings.popTags{3} = get(hObject,'String');
[plotExport,handles.axes1] = runPlotting(procTracks,plotSettings,root,handles.axes1,handles.figure1); 
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double
global plotSettings
global procTracks
global plotExport
global root

plotSettings.popTags{4} = get(hObject,'String');
[plotExport,handles.axes1] = runPlotting(procTracks,plotSettings,root,handles.axes1,handles.figure1); 
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% The colour selection buttons

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global plotSettings
global procTracks
global plotExport
global root

plotSettings.plotColours{1} = uisetcolor(plotSettings.plotColours{1});
handles.pushbutton1.BackgroundColor = plotSettings.plotColours{1};
handles.pushbutton1.ForegroundColor = [1,1,1] - plotSettings.plotColours{1};

[plotExport,handles.axes1] = runPlotting(procTracks,plotSettings,root,handles.axes1,handles.figure1); 
guidata(hObject,handles)

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global plotSettings
global procTracks
global plotExport
global root

plotSettings.plotColours{2} = uisetcolor(plotSettings.plotColours{2});
handles.pushbutton2.BackgroundColor = plotSettings.plotColours{2};
handles.pushbutton2.ForegroundColor = [1,1,1] - plotSettings.plotColours{2};

[plotExport,handles.axes1] = runPlotting(procTracks,plotSettings,root,handles.axes1,handles.figure1); 
guidata(hObject,handles)

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global plotSettings
global procTracks
global plotExport
global root

plotSettings.plotColours{3} = uisetcolor(plotSettings.plotColours{3});
handles.pushbutton3.BackgroundColor = plotSettings.plotColours{3};
handles.pushbutton3.ForegroundColor = [1,1,1] - plotSettings.plotColours{3};

[plotExport,handles.axes1] = runPlotting(procTracks,plotSettings,root,handles.axes1,handles.figure1); 
guidata(hObject,handles)

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global plotSettings
global procTracks
global plotExport
global root

plotSettings.plotColours{4} = uisetcolor(plotSettings.plotColours{4});
handles.pushbutton4.BackgroundColor = plotSettings.plotColours{4};
handles.pushbutton4.ForegroundColor = [1,1,1] - plotSettings.plotColours{4};

[plotExport,handles.axes1] = runPlotting(procTracks,plotSettings,root,handles.axes1,handles.figure1); 
guidata(hObject,handles)
