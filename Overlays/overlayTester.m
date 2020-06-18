function varargout = overlayTester(varargin)
% OVERLAYTESTER MATLAB code for overlayTester.fig
%      OVERLAYTESTER, by itself, creates a new OVERLAYTESTER or raises the existing
%      singleton*.
%
%      H = OVERLAYTESTER returns the handle to a new OVERLAYTESTER or the handle to
%      the existing singleton*.
%
%      OVERLAYTESTER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in OVERLAYTESTER.M with the given input arguments.
%
%      OVERLAYTESTER('Property','Value',...) creates a new OVERLAYTESTER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before overlayTester_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to overlayTester_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help overlayTester

% Last Modified by GUIDE v2.5 18-Nov-2019 12:13:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @overlayTester_OpeningFcn, ...
                   'gui_OutputFcn',  @overlayTester_OutputFcn, ...
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


% --- Executes just before overlayTester is made visible.
function overlayTester_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to overlayTester (see VARARGIN)

% Choose default command line output for overlayTester
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes overlayTester wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global root
global overlaySettings
global procTracks
global colourmap
global debugSet

root = varargin{1}.rootdir;
debugSet = varargin{1}.debugSet;

load([root,filesep,'Tracks.mat'],'trackSettings','procTracks','toMappings','fromMappings')
overlaySettings.pixSize = trackSettings.pixSize;
overlaySettings.maxX = trackSettings.maxX;
overlaySettings.maxY = trackSettings.maxY;
overlaySettings.frameOffset = trackSettings.minFrame - 1;
overlaySettings.pseudoTracks = trackSettings.pseudoTracks;

%Create a global colourmap object, so cells in the same track will be consistantly coloured between frames.
colourmap = struct();
colourmap.ID = rand(size(procTracks,2),3);
colourmap.Raw = repmat([1,0.7,0],size(procTracks,2),1);
if isfield(procTracks,'M')
    lineageMap = zeros(size(procTracks,2),3);
    for i = 1:size(procTracks,2)
        if isempty(procTracks(i).M)
            lineage = getLineageIndices(procTracks,i,0);
        end
        lineageMap(lineage,:) = repmat(rand(1,3),size(lineage,1),1);
    end
    colourmap.Lineage = lineageMap;
end

%The colourmap variable allows different colourmaps to be selected if the 'data' information choice is taken
overlaySettings.cmapName = 'jet';

%Only permit event plotting if the appropriate field has been defined previously
if isfield(procTracks,'event') && isfield(procTracks,'x') && isfield(procTracks,'y') && isfield(procTracks,'majorLen')
    handles.checkbox2.Enable = 'on';
else
    handles.checkbox2.Enable = 'off';
end
overlaySettings.eventShow = 0;
overlaySettings.IDshow = handles.checkbox1.Value;

%Setup slider
overlaySettings.showFrame = 1;
handles.slider1.Value = overlaySettings.showFrame;
handles.slider1.Max = size(toMappings,1);
handles.slider1.Min = 1;

%Setup data popup menus
[infoPopups,dataPopups,overlayPopups,underlayPopups] = setupOverlayPopupStrings(procTracks,overlaySettings,root);

handles.UnderlayPopup.String = underlayPopups;
handles.OverlayPopup.String = overlayPopups;
handles.InfoPopup.String = infoPopups;
handles.DataPopup.String = dataPopups;

%Get default settings @ setup
overlaySettings.underlay = handles.UnderlayPopup.String{handles.UnderlayPopup.Value};
overlaySettings.type = handles.OverlayPopup.String{handles.OverlayPopup.Value};
overlaySettings.info = handles.InfoPopup.String{handles.InfoPopup.Value};

oriName = handles.DataPopup.String{handles.DataPopup.Value};
overlaySettings.data = switchVarName(root,oriName,'hName','ptName');

plotOverlay(procTracks,root,overlaySettings,colourmap,handles.axes1,true,debugSet)


% --- Outputs from this function are returned to the command line.
function varargout = overlayTester_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in OverlayPopup - the 'Overlay type' menu
function OverlayPopup_Callback(hObject, eventdata, handles)
% hObject    handle to OverlayPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns OverlayPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from OverlayPopup
global overlaySettings
global procTracks
global root
global colourmap
global debugSet

overlaySettings.type = handles.OverlayPopup.String{handles.OverlayPopup.Value};

if strcmp(overlaySettings.type,'None')
    handles.InfoPopup.Enable = 'off';
    handles.DataPopup.Enable = 'off';
    handles.CmapPopup.Enable = 'off';
    
    handles.InfoPopup.Value = 1;
    overlaySettings.info = handles.InfoPopup.String{handles.InfoPopup.Value};
else
    handles.InfoPopup.Enable = 'on';
    
    %Need to do a little twiddling here to allow selection of lineage tree
    %plotting only if the 'Tracks' option is selected and lineage
    %information is available.
    if strcmp(overlaySettings.type,'Tracks') && sum(ismember(handles.InfoPopup.String,'Lineage'))==1
        if ~strcmp(handles.InfoPopup.String{end},'Lineage trees')
            handles.InfoPopup.String = [handles.InfoPopup.String;'Lineage trees'];
        end
    elseif ~strcmp(overlaySettings.type,'Tracks') %Switching from a case where you do need lineage trees, to one where you don't
        if strcmp(overlaySettings.info,'Lineage trees')
            overlaySettings.info = handles.InfoPopup.String{1};
        end
        if strcmp(handles.InfoPopup.String{end},'Lineage trees')
            handles.InfoPopup.Value = 1;
            handles.InfoPopup.String(end) = [];
        end
    end
end

plotOverlay(procTracks,root,overlaySettings,colourmap,handles.axes1,true,debugSet)


% --- Executes during object creation, after setting all properties.
function OverlayPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OverlayPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in InfoPopup - The 'Information
% overlaid' menu
function InfoPopup_Callback(hObject, eventdata, handles)
% hObject    handle to InfoPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns InfoPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from InfoPopup

global overlaySettings
global procTracks
global root
global colourmap
global debugSet

overlaySettings.info = handles.InfoPopup.String{handles.InfoPopup.Value};

if strcmp(overlaySettings.info,'Data')
    handles.DataPopup.Enable = 'on';
    handles.CmapPopup.Enable = 'on';
else
    handles.DataPopup.Enable = 'off';
    handles.CmapPopup.Enable = 'off';
end

%Special case - can need the colourmap popup to be active if 'Tracks' and
%'Lineage trees' are both selected.
if strcmp(overlaySettings.info,'Lineage trees')
    handles.CmapPopup.Enable = 'on';
end

plotOverlay(procTracks,root,overlaySettings,colourmap,handles.axes1,true,debugSet)

% --- Executes during object creation, after setting all properties.
function InfoPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to InfoPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in DataPopup - the 'Data selection'
% menu.
function DataPopup_Callback(hObject, eventdata, handles)
% hObject    handle to DataPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns DataPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from DataPopup
global overlaySettings
global procTracks
global root
global colourmap
global debugSet

overlaySettings.data = switchVarName(root,handles.DataPopup.String{handles.DataPopup.Value},'hName','ptName');

plotOverlay(procTracks,root,overlaySettings,colourmap,handles.axes1,true,debugSet)

% --- Executes during object creation, after setting all properties.
function DataPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DataPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in UnderlayPopup - the 'Data colourmap'
% menu
function UnderlayPopup_Callback(hObject, eventdata, handles)
% hObject    handle to UnderlayPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns UnderlayPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from UnderlayPopup

global overlaySettings
global procTracks
global root
global colourmap
global debugSet

overlaySettings.underlay = handles.UnderlayPopup.String{handles.UnderlayPopup.Value};

plotOverlay(procTracks,root,overlaySettings,colourmap,handles.axes1,true,debugSet)

% --- Executes during object creation, after setting all properties.
function UnderlayPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to UnderlayPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in CmapPopup.
function CmapPopup_Callback(hObject, eventdata, handles)
% hObject    handle to CmapPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns CmapPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from CmapPopup
global overlaySettings
global procTracks
global root
global colourmap
global debugSet

overlaySettings.cmapName = handles.CmapPopup.String{handles.CmapPopup.Value};

plotOverlay(procTracks,root,overlaySettings,colourmap,handles.axes1,true,debugSet)

% --- Executes during object creation, after setting all properties.
function CmapPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CmapPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1

global overlaySettings
global root
global procTracks
global colourmap
global debugSet

overlaySettings.IDshow = get(hObject,'Value');

plotOverlay(procTracks,root,overlaySettings,colourmap,handles.axes1,true,debugSet)

% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2

global overlaySettings
global root
global procTracks
global colourmap
global debugSet

overlaySettings.eventShow = get(hObject,'Value');
if overlaySettings.eventShow == 1 && ~isfield(procTracks,'event')
    warningdlg('No ''event'' field detected in the track data structure. Please mark events in tracks prior to event plotting.')
    handles.checkbox2.Value = 0;
    overlaySettings.eventShow = 0;
end

plotOverlay(procTracks,root,overlaySettings,colourmap,handles.axes1,true,debugSet)

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global overlaySettings
global procTracks
global root
global colourmap
global debugSet

overlayDirect = [root,filesep,'Overlays'];
if ~exist(overlayDirect,'dir')
    mkdir(overlayDirect)
end

debugprogressbar(0,debugSet)

for i = handles.slider1.Min:handles.slider1.Max
    currFile = [overlayDirect,filesep,sprintf('Frame_%04d.tif',i-1)];
    overlaySettings.showFrame = i-1;
    plotOverlay(procTracks,root,overlaySettings,colourmap,handles.axes1,false,debugSet)
    pause(0.1)
    export_fig(handles.axes1,currFile,'-tif','-m1')
    img = imread(currFile);
    if i == 1 %If first timepoint
        imLims = size(img);
    else
        img = img(1:imLims(1),1:imLims(2),:);
        imwrite(img,currFile);
    end
    debugprogressbar(i/(handles.slider1.Max-handles.slider1.Min),debugSet)
end

debugprogressbar(1,debugSet)


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global overlaySettings
global procTracks
global root
global colourmap
global debugSet

overlaySettings.showFrame = round(get(hObject,'Value'))-1;
handles.edit1.String = num2str(overlaySettings.showFrame+1);

plotOverlay(procTracks,root,overlaySettings,colourmap,handles.axes1,true,debugSet)

% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
global overlaySettings
global procTracks
global root
global colourmap
global debugSet

txtValue = round(str2double(get(hObject,'String')));

if txtValue > handles.slider1.Max 
    txtValue = handles.slider1.Max;
elseif txtValue < handles.slider1.Min
    txtValue = handles.slider1.Min;
end

overlaySettings.showFrame = txtValue-1; %Indexing from 0...
handles.edit1.String = num2str(txtValue);
handles.slider1.Value = txtValue;

plotOverlay(procTracks,root,overlaySettings,colourmap,handles.axes1,true,debugSet)

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
