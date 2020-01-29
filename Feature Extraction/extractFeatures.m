function varargout = extractFeatures(varargin)
% EXTRACTFEATURES MATLAB code for extractFeatures.fig
%      EXTRACTFEATURES, by itself, creates a new EXTRACTFEATURES or raises the existing
%      singleton*.
%
%      H = EXTRACTFEATURES returns the handle to a new EXTRACTFEATURES or the handle to
%      the existing singleton*.
%
%      EXTRACTFEATURES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EXTRACTFEATURES.M with the given input arguments.
%
%      EXTRACTFEATURES('Property','Value',...) creates a new EXTRACTFEATURES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before extractFeatures_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to extractFeatures_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help extractFeatures

% Last Modified by GUIDE v2.5 07-Jan-2020 14:18:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @extractFeatures_OpeningFcn, ...
                   'gui_OutputFcn',  @extractFeatures_OutputFcn, ...
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


% --- Executes just before extractFeatures is made visible.
function extractFeatures_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to extractFeatures (see VARARGIN)

% Choose default command line output for extractFeatures
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes extractFeatures wait for user response (see UIRESUME)
% uiwait(handles.figure1);

global root
global featSettings
global debugSet

featSettings.Orient = 0;
featSettings.Length = 0;
featSettings.Area = 0;
featSettings.Width = 0;
featSettings.Centroid = 1;
featSettings.dt = 1;
featSettings.morphologyAlg = 1;

root = varargin{1}.rootdir;
debugSet = varargin{1}.debugSet;

try
    load([root,filesep,'SegmentationSettings.mat'],'segmentParams')

    featSettings.noChannels = segmentParams.noChannels;
    featSettings.MeanInc = [];
    featSettings.StdInc = [];
catch %Most likely failed because you didn't use the segmentation GUI
    featSettings.noChannels = 1;
    featSettings.MeanInc = [];
    featSettings.StdInc = [];
end

% --- Outputs from this function are returned to the command line.
function varargout = extractFeatures_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in LenCheck.
function LenCheck_Callback(hObject, eventdata, handles)
% hObject    handle to LenCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of LenCheck
global featSettings
featSettings.Length = get(hObject,'Value');


% --- Executes on button press in AreaCheck.
function AreaCheck_Callback(hObject, eventdata, handles)
% hObject    handle to AreaCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of AreaCheck
global featSettings
featSettings.Area = get(hObject,'Value');


% --- Executes on button press in WidCheck.
function WidCheck_Callback(hObject, eventdata, handles)
% hObject    handle to WidCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of WidCheck
global featSettings
featSettings.Width = get(hObject,'Value');

% --- Executes on button press in CentCheck.
function CentCheck_Callback(hObject, eventdata, handles)
% hObject    handle to CentCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CentCheck
global featSettings
featSettings.Centroid = get(hObject,'Value');


% --- Executes on button press in OrientCheck.
function OrientCheck_Callback(hObject, eventdata, handles)
% hObject    handle to OrientCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of OrientCheck
global featSettings
featSettings.Orient = get(hObject,'Value');

% --- Executes on button press in GoPush - 'Run 'em all!'
function GoPush_Callback(hObject, eventdata, handles)
% hObject    handle to GoPush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global root
global debugSet
global featSettings

extractFeatureEngine(root,debugSet,featSettings);

% --- Executes on button press in ChannelPush - 'Channel selection'
function ChannelPush_Callback(hObject, eventdata, handles)
% hObject    handle to ChannelPush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global featSettings

meansOn = zeros(featSettings.noChannels,1);
stdsOn = zeros(featSettings.noChannels,1);
meansOn(featSettings.MeanInc) = true;
stdsOn(featSettings.StdInc) = true;

chanSettings = ChannelPicker(true(1,featSettings.noChannels),true(1,featSettings.noChannels),meansOn,stdsOn);

featSettings.MeanInc = find(chanSettings.chanMeans);
featSettings.StdInc = find(chanSettings.chanStds);

% --- Executes on button press in ElipseRadio.
function ElipseRadio_Callback(hObject, eventdata, handles)
% hObject    handle to ElipseRadio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ElipseRadio
global featSettings

if get(hObject,'Value')
    handles.PerimRadio.Value = false;
    featSettings.morphologyAlg = 1;
else
    handles.PerimRadio.Value = true;
    featSettings.morphologyAlg = 2;
end

% --- Executes on button press in PerimRadio.
function PerimRadio_Callback(hObject, eventdata, handles)
% hObject    handle to PerimRadio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of PerimRadio
global featSettings

if get(hObject,'Value')
    handles.ElipseRadio.Value = false;
    featSettings.morphologyAlg = 2;
else
    handles.ElipseRadio.Value = true;
    featSettings.morphologyAlg = 1;
end
