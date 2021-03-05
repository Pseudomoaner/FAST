function varargout = divisionTracker(varargin)
% DIVISIONTRACKER MATLAB code for divisionTracker.fig
%      DIVISIONTRACKER, by itself, creates a new DIVISIONTRACKER or raises the existing
%      singleton*.
%
%      H = DIVISIONTRACKER returns the handle to a new DIVISIONTRACKER or the handle to
%      the existing singleton*.
%
%      DIVISIONTRACKER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DIVISIONTRACKER.M with the given input arguments.
%
%      DIVISIONTRACKER('Property','Value',...) creates a new DIVISIONTRACKER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before divisionTracker_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to divisionTracker_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help divisionTracker

% Last Modified by GUIDE v2.5 15-Nov-2019 18:00:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @divisionTracker_OpeningFcn, ...
                   'gui_OutputFcn',  @divisionTracker_OutputFcn, ...
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


% --- Executes just before divisionTracker is made visible.
function divisionTracker_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to divisionTracker (see VARARGIN)

% Choose default command line output for divisionTracker
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes divisionTracker wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global root
global divisionSettings
global trackableData
global trackSettings
global procTracks
global debugSet
global toMappings
global fromMappings

root = varargin{1}.rootdir;
debugSet = varargin{1}.debugSet;

%If you've running division-detection before, the Tracks.mat file will have
%been updated since originally being output by the tracking module. This
%bit of code reads that original version if needed.
if exist([root,filesep,'Pre-division_Tracks.mat'],'file')
    load([root,filesep,'Pre-division_Tracks.mat'],'trackableData','trackSettings','procTracks','toMappings','fromMappings');
else
    load([root,filesep,'Tracks.mat'],'trackableData','trackSettings','procTracks','toMappings','fromMappings');
end

trackableData = struct();

[handles,divisionSettings] = setupDivisionCheckboxes(handles,procTracks,trackSettings);

%Set up the sliders
divisionSettings.incProp = trackSettings.incProp;
divisionSettings.incRad = 0.1;
divisionSettings.gapWidth = trackSettings.gapWidth;
divisionSettings.statsUse = 'Centroid';
divisionSettings.minInc = 2;

handles.InclusionSlide.Value = divisionSettings.incProp;
handles.ThreshSlide.Value = divisionSettings.incRad;
handles.minSlide.Value = divisionSettings.minInc;

handles.InclusionEdit.String = num2str(divisionSettings.incProp);
handles.ThreshEdit.String = num2str(divisionSettings.incRad);
handles.minEdit.String = num2str(divisionSettings.minInc);

handles.radiobutton1.Value = 0;
handles.radiobutton2.Value = 1;

%Set up the axes
handles.axes1.Box = 'on';
handles.axes1.LineWidth = 1.5;
handles.axes2.Box = 'on';
handles.axes2.LineWidth = 1.5;
handles.axes3.Box = 'on';
handles.axes3.LineWidth = 1.5;
handles.axes4.XTick = [];
handles.axes4.YTick = [];
handles.axes4.Box = 'on';
handles.axes4.LineWidth = 1.5;
handles.axes5.Visible = 'off';

%Set up the strings for the drop down menus
[strArrX,strArrY] = getDivPopupStrings(divisionSettings);
handles.popupmenu1.String = strArrX;
handles.popupmenu2.String = strArrY;

divisionSettings.xString = handles.popupmenu2.String{handles.popupmenu2.Value};
divisionSettings.yString = handles.popupmenu1.String{handles.popupmenu1.Value};

divisionSettings.calculated = 0; %This setting will change to 1 once the initial statistics have been calculated
divisionSettings.detected = 0; %This setting will change to 1 once division detection has been completed

divisionSettings.dt = trackSettings.dt;
divisionSettings.pixSize = trackSettings.pixSize;
divisionSettings.maxFrame = trackSettings.maxFrame;

% --- Outputs from this function are returned to the command line.
function varargout = divisionTracker_OutputFcn(hObject, eventdata, handles) 
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
global divisionSettings
global calcdivisionSettings
global featDiffs
global linkStats

if divisionSettings.calculated == 1
    divisionSettings.yString = handles.popupmenu1.String{handles.popupmenu1.Value};
    calcdivisionSettings.yString = handles.popupmenu1.String{handles.popupmenu1.Value};
end

if divisionSettings.detected == 1
    plotNormalizedDivStepSizes(divisionSettings,featDiffs,linkStats,handles.axes2)
end

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
global divisionSettings
global calcdivisionSettings
global featDiffs
global linkStats

if divisionSettings.calculated == 1
    divisionSettings.xString = handles.popupmenu2.String{handles.popupmenu2.Value};
    calcdivisionSettings.xString = handles.popupmenu2.String{handles.popupmenu2.Value};
end

if divisionSettings.detected == 1
    plotNormalizedDivStepSizes(divisionSettings,featDiffs,linkStats,handles.axes2)
end

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

% --- Executes on button press in pushbutton3 - the 'Calculate' button
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global divisionSettings
global calcdivisionSettings
global linkStats
global pred1Mat
global pred2Mat
global featureStruct
global tgtMat
global procTracks

[linkStats,tgtMat,pred1Mat,pred2Mat,featureStruct] = gatherDivisionStats(procTracks,divisionSettings);

%Set up the strings for the drop down menus
[strArrX,strArrY] = getDivPopupStrings(divisionSettings);
handles.popupmenu1.String = strArrX;
handles.popupmenu2.String = strArrY;
handles.popupmenu1.Value = 1;
handles.popupmenu2.Value = 1;

divisionSettings.xString = handles.popupmenu2.String{handles.popupmenu2.Value};
divisionSettings.yString = handles.popupmenu1.String{handles.popupmenu1.Value};

%Indicate that statistics have been calculated
divisionSettings.calculated = 1;
divisionSettings.detected = 0;
handles.pushbutton4.Enable = 'on';

%Set a default value for the inclusion radius (and the maximum value, for the slider)
%Note - don't need to make adaptive, as not time dependent rescaling. So
%just use a simple threshold (rather than mucking around with hyperspheres)
handles.ThreshSlide.Value = 3;
handles.ThreshSlide.Max = 10;
handles.ThreshEdit.String = '3';
divisionSettings.incRad = 3;

%Do the plotting for the GUI - axes 1
plotUnnormalizedDivStepSizes(tgtMat,pred1Mat,pred2Mat,divisionSettings.statsUse,divisionSettings.incProp,linkStats.trackability,handles.axes1)

%Clear the axes for the other figures (no longer accurate with new calculated statistics)
cla(handles.axes2)
cla(handles.axes3)
cla(handles.axes4)

calcdivisionSettings = divisionSettings; %Track settings used the last time the 'Calculate!' button was pushed - prevents tracking and test-tracking becoming confused based on updates to checkboxes.


% --- Executes on button press in pushbutton4 - the 'Find divisions!' button.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global divisionSettings
global tgtMat
global pred1Mat
global pred2Mat
global featDiffs
global linkStats
global procTracks
global root
global Ms
global linSizes

[linkArray1,linkArray2,acceptDiffs,rejectDiffs] = doDivisionLinkingRedux(tgtMat,pred1Mat,pred2Mat,linkStats,divisionSettings.incRad,true);

featDiffs.accept = acceptDiffs;
featDiffs.reject = rejectDiffs;

try
    procTracks = addDivisionLinks(procTracks,linkArray1,linkArray2);
catch ME
    if (strcmp(ME.identifier,'MATLAB:lang:StackOverflow'))
        errordlg('Detection threshold is too lenient to prevent a loop from emerging in the lineage tree. Please reduce the detection threshold.','Parameter error')
        return
    else
        rethrow(ME)
    end
end

divisionSettings.showDiv = [];
for i = 1:size(procTracks,2)
    if ~isempty(procTracks(i).D1) || ~isempty(procTracks(i).D2)
        divisionSettings.showDiv = i;
        break
    end
end

if isempty(divisionSettings.showDiv)
    warndlg('No divisions detected! Not a problem perhaps, but one has to question why you ran division detection in the first place...')
else
    %Check the required directories (the brightfield and segmentation channels) exist first
    if ~exist([root,filesep,'SegmentationSettings.mat'],'file') || ~exist([root,filesep,'Segmentations'],'dir')
        errordlg('Division testing not supported without both a chosen segmentation channel and segmentation images! For track validation, please use options in the overlays GUI.')
        return
    elseif ~isfield(procTracks,'x')
        errordlg('Division testing not supported without information about object centroids! For track validation, please use options in the overlays GUI.')
        return
    else
        load([root,filesep,'SegmentationSettings.mat'])
        divisionSettings = displayCellDivision(root,procTracks,divisionSettings,segmentParams.segmentChan,handles.axes4);
        
        handles.pushbutton5.Enable = 'on';
        handles.pushbutton6.Enable = 'on';
    end
end

plotNormalizedDivStepSizes(divisionSettings,featDiffs,linkStats,handles.axes2)
[Ms,linSizes] = plotLineageLengthDistribution(procTracks,divisionSettings,handles.axes3);

handles.minSlide.Max = max(linSizes);

divisionSettings.detected = 1;

% --- Executes on button press in pushbutton5 - the 'Next division' button
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global root
global procTracks
global divisionSettings

%Check the required directories (the brightfield and segmentation channels) exist first
if ~exist([root,filesep,'SegmentationSettings.mat'],'file') || ~exist([root,filesep,'Segmentations'],'dir')
    errordlg('Division testing not supported without both brightfield and segmentation images! For division validation, please use options in the overlays GUI.')
    return
elseif ~isfield(procTracks,'x')
    errordlg('Division testing not supported without information about object centroids! For division validation, please use options in the overlays GUI.')
    return
end

for i = divisionSettings.showDiv+1:size(procTracks,2)
    if ~isempty(procTracks(i).D1) || ~isempty(procTracks(i).D2)
        divisionSettings.showDiv = i;
        break
    end
end

if i == size(procTracks,2) %If you've reached the end of the entire list of divisions, go back to start of list.
    for i = 1:size(procTracks,2)
        if ~isempty(procTracks(i).D1) || ~isempty(procTracks(i).D2)
            divisionSettings.showDiv = i;
            break
        end
    end
end

load([root,filesep,'SegmentationSettings.mat'])
divisionSettings = displayCellDivision(root,procTracks,divisionSettings,segmentParams.segmentChan,handles.axes4);

% --- Executes on button press in pushbutton6 - the 'Show Divisions' button
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global root
global divisionSettings

if isfield(divisionSettings,'ABstate')
    lims = axis(handles.axes4);
    if divisionSettings.ABstate == 1
        imshow(imread([root,filesep,'TestDivision_0002.tif']),'Parent',handles.axes4)
        divisionSettings.ABstate = 2;
    elseif divisionSettings.ABstate == 2
        imshow(imread([root,filesep,'TestDivision_0001.tif']),'Parent',handles.axes4)
        divisionSettings.ABstate = 1;
    end
    axis(handles.axes4,lims)
else
    errordlg('Run tracking first!')
end

% --- Executes on button press in pushbutton7.- the 'Channel selection'
% button
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global divisionSettings

meanVec = zeros(divisionSettings.noChannels,1);
stdVec = zeros(divisionSettings.noChannels,1);
meanVec(divisionSettings.availableMeans) = true;
stdVec(divisionSettings.availableStds) = true;

meansOn = zeros(divisionSettings.noChannels,1);
stdsOn = zeros(divisionSettings.noChannels,1);
meansOn(divisionSettings.MeanInc) = true;
stdsOn(divisionSettings.StdInc) = true;

chanSettings = ChannelPicker(meanVec,stdVec,meansOn,stdsOn);

divisionSettings.MeanInc = find(chanSettings.chanMeans);
divisionSettings.StdInc = find(chanSettings.chanStds);

% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1
global divisionSettings

divisionSettings.Length = get(hObject,'Value');


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2
global divisionSettings

divisionSettings.Area = get(hObject,'Value');

% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3
global divisionSettings

divisionSettings.Width = get(hObject,'Value');

% --- Executes on button press in checkbox6.
function checkbox6_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox6
global divisionSettings

divisionSettings.Orientation = get(hObject,'Value');

% --- Executes on button press in checkbox7.
function checkbox7_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox7
global divisionSettings

divisionSettings.Velocity = get(hObject,'Value');

% --- Executes on button press in checkbox9.
function checkbox9_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox9
global divisionSettings

divisionSettings.Centroid = get(hObject,'Value');

% --- Executes on button press in checkbox8.
function checkbox8_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox8
global divisionSettings

divisionSettings.SpareFeat1 = get(hObject,'Value');

% --- Executes on button press in checkbox10.
function checkbox10_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox10
global divisionSettings

divisionSettings.SpareFeat2 = get(hObject,'Value');

% --- Executes on button press in checkbox11.
function checkbox11_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox11
global divisionSettings

divisionSettings.SpareFeat3 = get(hObject,'Value');

% --- Executes on button press in checkbox12.
function checkbox12_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox12
global divisionSettings

divisionSettings.SpareFeat4 = get(hObject,'Value');

% --- Executes on slider movement - Inclusion proportion
function InclusionSlide_Callback(hObject, eventdata, handles)
% hObject    handle to InclusionSlide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global divisionSettings
global tgtMat
global pred1Mat
global pred2Mat
global trackability

divisionSettings.incProp = get(hObject,'Value');
handles.InclusionEdit.String = num2str(divisionSettings.incProp);

if divisionSettings.calculated == 1
    %Do the plotting for the GUI
    plotUnnormalizedDivStepSizes(tgtMat,pred1Mat,pred2Mat,divisionSettings.statsUse,divisionSettings.incProp,trackability,handles.axes1)
end

% --- Executes during object creation, after setting all properties.
function InclusionSlide_CreateFcn(hObject, eventdata, handles)
% hObject    handle to InclusionSlide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function InclusionEdit_Callback(hObject, eventdata, handles)
% hObject    handle to InclusionEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of InclusionEdit as text
%        str2double(get(hObject,'String')) returns contents of InclusionEdit as a double
global divisionSettings
global tgtMat
global pred1Mat
global pred2Mat
global trackability

txtValue = str2double(get(hObject,'String'));

if txtValue > 1
    txtValue = 1;
elseif txtValue < 0 
    txtValue = 0;
end

divisionSettings.incProp = txtValue;
handles.InclusionEdit.String = num2str(txtValue);
handles.InclusionSlide.Value = txtValue;

if divisionSettings.calculated == 1
    %Do the plotting for the GUI
    plotUnnormalizedDivStepSizes(tgtMat,pred1Mat,pred2Mat,divisionSettings.statsUse,divisionSettings.incProp,trackability,handles.axes1)
end

% --- Executes during object creation, after setting all properties.
function InclusionEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to InclusionEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement - incRad
function ThreshSlide_Callback(hObject, eventdata, handles)
% hObject    handle to ThreshSlide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global divisionSettings
global featDiffs
global linkStats

divisionSettings.incRad = get(hObject,'Value');
handles.ThreshEdit.String = num2str(divisionSettings.incRad);

if divisionSettings.detected == 1
    plotNormalizedDivStepSizes(divisionSettings,featDiffs,linkStats,handles.axes2)
end

% --- Executes during object creation, after setting all properties.
function ThreshSlide_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ThreshSlide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function ThreshEdit_Callback(hObject, eventdata, handles)
% hObject    handle to ThreshEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ThreshEdit as text
%        str2double(get(hObject,'String')) returns contents of ThreshEdit as a double
global divisionSettings
global featDiffs
global linkStats

txtValue = str2double(get(hObject,'String'));

if txtValue < 0 
    txtValue = 0;
end

divisionSettings.incRad = txtValue;
handles.ThreshEdit.String = num2str(txtValue);

if txtValue > handles.ThreshSlide.Max
    txtValue = handles.ThreshSlide.Max;
end

handles.ThreshSlide.Value = txtValue;

if divisionSettings.detected == 1
    plotNormalizedDivStepSizes(divisionSettings,featDiffs,linkStats,handles.axes2)
end

% --- Executes during object creation, after setting all properties.
function ThreshEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ThreshEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function minSlide_Callback(hObject, eventdata, handles)
% hObject    handle to minSlide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global divisionSettings
global procTracks

divisionSettings.minInc = round(get(hObject,'Value'));
handles.minEdit.String = num2str(divisionSettings.minInc);

if divisionSettings.detected == 1
    plotLineageLengthDistribution(procTracks,divisionSettings,handles.axes3);
end


% --- Executes during object creation, after setting all properties.
function minSlide_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minSlide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function minEdit_Callback(hObject, eventdata, handles)
% hObject    handle to minEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minEdit as text
%        str2double(get(hObject,'String')) returns contents of minEdit as a double
global divisionSettings
global procTracks

txtValue = str2double(get(hObject,'String'));

if txtValue < 1 
    txtValue = 1;
elseif txtValue > handles.minSlide.Max
    txtValue = handles.minSlide.Max;
end

divisionSettings.minInc = round(txtValue);
handles.minEdit.String = num2str(round(txtValue));
handles.minSlide.Value = txtValue;

if divisionSettings.detected == 1
    plotLineageLengthDistribution(procTracks,divisionSettings,handles.axes3);
end


% --- Executes during object creation, after setting all properties.
function minEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1
global divisionSettings

if get(hObject,'Value') == 1
    handles.radiobutton2.Value = 0;
    divisionSettings.statsUse = 'All';
elseif get(hObject,'Value') == 0
    if divisionSettings.Centroid == 1
        handles.radiobutton2.Value = 0;
        divisionSettings.statsUse = 'Centroid';
    else
        errordlg('Can only use centroids if included as features!')
        handles.radiobutton2.Value = 1;
        divisionSettings.statsUse = 'All';
    end
end

% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2
global divisionSettings

if get(hObject,'Value') == 1
    if divisionSettings.Centroid == 1
        handles.radiobutton1.Value = 0;
        divisionSettings.statsUse = 'Centroid';
    else
        errordlg('Can only use centroids if included as features!')
        handles.radiobutton1.Value = 1;
        divisionSettings.statsUse = 'All';
    end
elseif get(hObject,'Value') == 0
    handles.radiobutton1.Value = 1;
    divisionSettings.statsUse = 'All';
end

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Code that takes care of reconfiguring the tracks so that only those that
%are part of a lineage of the user-specified minimum size pass through to
%subsequent stages. Overwrites procTracks, toMappings, fromMappings and
%trackTimes.
global root
global divisionSettings
global toMappings
global fromMappings
global procTracks
global debugSet
global Ms
global linSizes

if divisionSettings.detected == 1
    debugprogressbar(0,debugSet)
    
    %Save a backup copy of the raw tracks if one doesn't already exist
    if ~exist([root,filesep,'Pre-division_Tracks.mat'],'file')
        copyfile([root,filesep,'Tracks.mat'],[root,filesep,'Pre-division_Tracks.mat'])
    end
    
    %Update your tracks to get rid of ones that are part of small lineages
    badMs = Ms(linSizes < divisionSettings.minInc);
    
    %Generate list of tracks that are within small lineages
    badTs = [];
    for i = 1:size(badMs,1)
        [linInds,~] = getLineageIndices(procTracks,badMs(i),1);
        badTs = [badTs;linInds];
    end
    delTs = unique(badTs); %Throws in sorting for free
    
    %Need to update the tracks the mother and daughter IDs point to.
    for i = 1:size(procTracks,2)
        if ~isempty(procTracks(i).M)
            procTracks(i).M = procTracks(i).M - sum(delTs < procTracks(i).M);
        end
        if ~isempty(procTracks(i).D1)
            procTracks(i).D1 = procTracks(i).D1 - sum(delTs < procTracks(i).D1);
        end
        if ~isempty(procTracks(i).D2)
            procTracks(i).D2 = procTracks(i).D2 - sum(delTs < procTracks(i).D2);
        end
    end
    
    %Clear the relevant parts of procTracks and fromMappings
    procTracks(delTs) = [];
    fromMappings(delTs) = [];
    
    %Rejigging toMappings is a bit more tricky, given the deletion of the
    %tracks in the above code causes the position of tracks below them in the
    %data structure to shift.
    for i = delTs'-(0:(size(delTs,1)-1)) %For each short track (weird indexing here accounts for the continual subtraction of one from each track index during each run through the loop)
        %Loop through slices, deleting and reindexing if track is too short
        for j = 1:size(toMappings,1) %For each 'slice'
            currID = toMappings{j}(:,1) == i;
            bigIDs = toMappings{j}(:,1) > i;
            if sum(currID) == 1 %If this track is present at this timepoint
                toMappings{j}(currID,:) = [NaN,NaN];
            end
            toMappings{j}(bigIDs,1) = toMappings{j}(bigIDs,1) - 1;
        end
    end
    
    if isdeployed
        save([root,filesep,'Tracks.mat'],'divisionSettings','toMappings','fromMappings','procTracks','-append','-v6')
    else
        save([root,filesep,'Tracks.mat'],'divisionSettings','toMappings','fromMappings','procTracks','-append','-v7.3')
    end
    
    debugprogressbar(1,debugSet)
end

delete(hObject);

% --- Executes when figure 1 is deleted.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Don't actually use this, but GUIDE throws a hissy fit if I don't include
%this function now.
