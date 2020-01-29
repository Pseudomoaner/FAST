function varargout = homePanel(varargin)
% HOMEPANEL MATLAB code for homePanel.fig
%      HOMEPANEL, by itself, creates a new HOMEPANEL or raises the existing
%      singleton*.
%
%      H = HOMEPANEL returns the handle to a new HOMEPANEL or the handle to
%      the existing singleton*.
%
%      HOMEPANEL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HOMEPANEL.M with the given input arguments.
%
%      HOMEPANEL('Property','Value',...) creates a new HOMEPANEL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before homePanel_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to homePanel_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help homePanel

% Last Modified by GUIDE v2.5 07-Jan-2020 13:00:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @homePanel_OpeningFcn, ...
                   'gui_OutputFcn',  @homePanel_OutputFcn, ...
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

% --- Executes just before homePanel is made visible.
function homePanel_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to homePanel (see VARARGIN)
global rootdir
global debugSet

debugSet = false; %If set to true, prevents windows from becoming modal. This allows you to stop commands much more easily with Ctrl-C, rather than having to wait for them to finish running.

% Choose default command line output for homePanel
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes homePanel wait for user response (see UIRESUME)
% uiwait(handles.figure1);

homeDirectory = getenv('USERPROFILE');
rootdir = homeDirectory;

handles.RootDisplay.String = rootdir;

%Folder in which this homepanel code is running
codeName = mfilename('fullpath');

%Images are stored in the 'homePanel' directory above the one the code is running in
slashLocs = regexp(codeName,filesep);
codeRoot = codeName(1:slashLocs(end-1));
imgDir = [codeRoot,'Imagery',filesep];

imshow(imread([imgDir,'Segmentation.png']),'Parent',handles.SegImgAx)
imshow(imread([imgDir,'Features.png']),'Parent',handles.FeatImgAx)
imshow(imread([imgDir,'Tracking.png']),'Parent',handles.TrackImgAx)
imshow(imread([imgDir,'Divisions.png']),'Parent',handles.DivImgAx)
imshow(imread([imgDir,'Overlays.png']),'Parent',handles.OverImgAx)
imshow(imread([imgDir,'Plotting.png']),'Parent',handles.PlotImgAx)
imshow(imread([imgDir,'TextLogoLarge.png']),'Parent',handles.LogoImgAx);
axis(handles.LogoImgAx,[5,800,5,335])


% --- Outputs from this function are returned to the command line.
function varargout = homePanel_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in SegPush.
function SegPush_Callback(hObject, eventdata, handles)
global rootdir
global debugSet

nextHand = struct;
nextHand.rootdir = rootdir;
nextHand.debugSet = debugSet;
% hObject    handle to SegPush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
diffHand = diffTrackSegment(nextHand);
if ~debugSet
    diffHand.WindowStyle = 'modal';
end
diffHand.DeleteFcn = {@updateHomePanelButtons,handles,rootdir};


% --- Executes on button press in OverPush.
function OverPush_Callback(hObject, eventdata, handles)
global rootdir
global debugSet

nextHand = struct;
nextHand.rootdir = rootdir;
nextHand.debugSet = debugSet;
% hObject    handle to OverPush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
overHand = overlayTester(nextHand);
if ~debugSet
    overHand.WindowStyle = 'modal';
end
overHand.DeleteFcn = {@updateHomePanelButtons,handles,rootdir};

% --- Executes on button press in FeatPush.
function FeatPush_Callback(hObject, eventdata, handles)
global rootdir
global debugSet

nextHand = struct;
nextHand.rootdir = rootdir;
nextHand.debugSet = debugSet;
% hObject    handle to FeatPush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
extHand = extractFeatures(nextHand);
if ~debugSet
    extHand.WindowStyle = 'modal';
end
extHand.DeleteFcn = {@updateHomePanelButtons,handles,rootdir};


% --- Executes on button press in TrackPush.
function TrackPush_Callback(hObject, eventdata, handles)
global rootdir
global debugSet

nextHand = struct;
nextHand.rootdir = rootdir;
nextHand.debugSet = debugSet;
% hObject    handle to TrackPush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
diffHand = diffusionTracker(nextHand);
if ~debugSet
    diffHand.WindowStyle = 'modal';
end
diffHand.DeleteFcn = {@updateHomePanelButtons,handles,rootdir};

% --- Executes on button press in RootChoicePush.
function RootChoicePush_Callback(hObject, eventdata, handles)
global rootdir
global debugSet
% hObject    handle to RootChoicePush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Ensure chosen folder contains readable data.
error = true;

tmpDir = uigetdir(rootdir);
if tmpDir ~= 0
    rootdir = tmpDir;
end
handles = updateHomePanelButtons([],[],handles,rootdir);

if strcmp(handles.SegPush.Enable,'on') || strcmp(handles.OverPush.Enable,'on') || strcmp(handles.FeatPush.Enable,'on') || strcmp(handles.TrackPush.Enable,'on') || strcmp(handles.DivPush.Enable,'on') || strcmp(handles.PlotPush.Enable,'on')
    handles.RootDisplay.String = rootdir;
else
    %Allow Bioformats import, if data doesn't seem to be in format required for processing.
    cd(rootdir)
    handles.RootDisplay.String = rootdir;
    origFile = uigetfile({'*.*','All Files (*.*)'});
    
    if origFile ~= 0
        importBioformatsData(rootdir,origFile,[],debugSet);
    end
    handles = updateHomePanelButtons([],[],handles,rootdir);
end


% --- Executes on button press in DivPush.
function DivPush_Callback(hObject, eventdata, handles)
% hObject    handle to DivPush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global rootdir
global debugSet

nextHand = struct;
nextHand.rootdir = rootdir;
nextHand.debugSet = debugSet;
% hObject    handle to TrackPush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
diffHand = divisionTracker(nextHand);
if ~debugSet
    diffHand.WindowStyle = 'modal';
end
diffHand.DeleteFcn = {@updateHomePanelButtons,handles,rootdir};


% --- Executes on button press in PlotPush.
function PlotPush_Callback(hObject, eventdata, handles)
% hObject    handle to PlotPush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global rootdir
global debugSet

nextHand = struct;
nextHand.rootdir = rootdir;
nextHand.debugSet = debugSet;

diffHand = plotTracks(nextHand);
if ~debugSet
    diffHand.WindowStyle = 'modal';
end
diffHand.DeleteFcn = {@updateHomePanelButtons,handles,rootdir};
