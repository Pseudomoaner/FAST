function varargout = CorrectTracks(varargin)
% CORRECTTRACKS MATLAB code for CorrectTracks.fig
%      CORRECTTRACKS, by itself, creates a new CORRECTTRACKS or raises the existing
%      singleton*.
%
%      H = CORRECTTRACKS returns the handle to a new CORRECTTRACKS or the handle to
%      the existing singleton*.
%
%      CORRECTTRACKS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CORRECTTRACKS.M with the given input arguments.
%
%      CORRECTTRACKS('Property','Value',...) creates a new CORRECTTRACKS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CorrectTracks_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CorrectTracks_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CorrectTracks

% Last Modified by GUIDE v2.5 05-Jun-2019 10:34:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CorrectTracks_OpeningFcn, ...
                   'gui_OutputFcn',  @CorrectTracks_OutputFcn, ...
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


% --- Executes just before CorrectTracks is made visible.
function CorrectTracks_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CorrectTracks (see VARARGIN)
global GUIsets
global trackTimes
global rawFromMappings
global rawToMappings
global rawTracks
global segDat
global cScheme
global imgHand

GUIsets.mode = 'Fuse';
GUIsets.IDswitch = 1;
GUIsets.frame = 1;
GUIsets.forLook = 2; %Number of frames forwards in time you should be able to look during the 'Fuse' option.

%Unpack data passed from previous GUI window
trackTimes = varargin{1}.trackTimes;
rawFromMappings = varargin{1}.rawFromMappings;
rawToMappings = varargin{1}.rawToMappings;
rawTracks = varargin{1}.rawTracks;
GUIsets.maxF = varargin{1}.maxF;
GUIsets.minF = varargin{1}.minF;
GUIsets.root = varargin{1}.root;
GUIsets.pxSize = varargin{1}.pxSize;
GUIsets.underlayDir = varargin{1}.underlayDir;

%Initialise the data input variables
GUIsets.srcT = [];
GUIsets.tgtT = [];
GUIsets.cutT = [];
GUIsets.srcID = [];
GUIsets.tgtID = [];
GUIsets.cutID = [];
GUIsets.srcTrack = [];
GUIsets.tgtTrack = [];
GUIsets.cutTrack = [];
GUIsets.srcPoint = [];
GUIsets.tgtPoint = [];
GUIsets.cutPoint = [];

handles.FuseButt.BackgroundColor = [0.7,1,0.7];
handles.CutButt.BackgroundColor = [1,0.7,0.7];

%Get the segmentation frame storage
actualLook = min(GUIsets.maxF - GUIsets.frame + 1,GUIsets.forLook);
segDat.frames = cell(actualLook,1);
segDat.stats = cell(actualLook,1);
for i = 1:actualLook
    segPath = [GUIsets.root,filesep,'Segmentations',filesep,sprintf('Frame_%04d.tif',GUIsets.frame+i-2)];
    seg = imread(segPath);
    segDat.frames{i} = bwlabeln(seg,8);
    segDat.stats{i} = regionprops(segDat.frames{i},'Centroid','PixelIdxList');
end

%Assign random colours to each track
cmap = colormap('cool');
cmap = round(cmap*254);
inds = randi(size(cmap,1),size(trackTimes,2),1);
cScheme = cmap(inds,:);

imgHand = displayEditableTracks(GUIsets,rawTracks,trackTimes,rawFromMappings,rawToMappings,segDat,cScheme,handles.axes1);
set(imgHand,'ButtonDownFcn',@selectCell);

% Choose default command line output for CorrectTracks
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes CorrectTracks wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = CorrectTracks_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in GoButt.
function GoButt_Callback(hObject, eventdata, handles)
% hObject    handle to GoButt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GUIsets
global rawTracks
global trackTimes
global segDat
global cScheme
global imgHand
global rawToMappings
global rawFromMappings

switch GUIsets.mode
    case 'Cut'
        if ~isempty(GUIsets.cutT) %Need to make sure an object has actually been selected before you run the track cutting
            %Split rawTracks
            trackDataNames = fieldnames(rawTracks);
            for i = 1:size(trackDataNames,1)
                rawTracks.(trackDataNames{i}){size(rawTracks.(trackDataNames{i}),2)+1} = rawTracks.(trackDataNames{i}){GUIsets.cutTrack}(GUIsets.cutPoint+1:end,:);
                rawTracks.(trackDataNames{i}){GUIsets.cutTrack}(GUIsets.cutPoint+1:end,:) = [];
            end
            
            newLen = size(rawTracks.(trackDataNames{i}){end},1); %Length of the new track
            newTrack = size(rawTracks.(trackDataNames{i}),2); %ID of the new track
            
            %Split trackTimes
            trackTimes{newTrack} = trackTimes{GUIsets.cutTrack}(GUIsets.cutPoint+1:end);
            trackTimes{GUIsets.cutTrack}(GUIsets.cutPoint+1:end) = [];
            
            %Update rawToMappings
            for i = trackTimes{newTrack}
                oldInd = rawToMappings{i - GUIsets.minF + 1}(:,1) == GUIsets.cutTrack;
                rawToMappings{i - GUIsets.minF + 1}(oldInd,1) = newTrack;
                rawToMappings{i - GUIsets.minF + 1}(oldInd,2) = i - trackTimes{newTrack}(1) + 1;
            end
            
            %Split rawFromMappings
            rawFromMappings{newTrack} = rawFromMappings{GUIsets.cutTrack}(GUIsets.cutPoint+1:end,:);
            rawFromMappings{GUIsets.cutTrack}(GUIsets.cutPoint+1:end,:) = [];
            
            %Add colour value for new track. Pick random colour from total
            %set of tracks to save regenerating the entire colourmap.
            cScheme = [cScheme;cScheme(randi(size(cScheme,1),1),:)];
            
            %Clear the user-selected values now that the cutting is
            %complete
            GUIsets.cutT = [];
            GUIsets.cutTrack = [];
            GUIsets.cutID = [];
            GUIsets.cutPoint = [];
        end
    case 'Fuse'
        if ~isempty(GUIsets.srcT) && ~isempty(GUIsets.tgtT)
            oldSrcLen = size(trackTimes{GUIsets.srcTrack},2);
            
            %Fuse rawTracks
            trackDataNames = fieldnames(rawTracks);
            for i = 1:size(trackDataNames,1)
                rawTracks.(trackDataNames{i}){GUIsets.srcTrack} = [rawTracks.(trackDataNames{i}){GUIsets.srcTrack};rawTracks.(trackDataNames{i}){GUIsets.tgtTrack}];
                rawTracks.(trackDataNames{i})(GUIsets.tgtTrack) = [];
            end
            
            %Fuse trackTimes
            trackTimes{GUIsets.srcTrack} = [trackTimes{GUIsets.srcTrack},trackTimes{GUIsets.tgtTrack}];
            trackTimes(GUIsets.tgtTrack) = [];
            
            %Rejig rawToMappings
            for i = 1:size(rawToMappings,1)
                oldInd = rawToMappings{i}(:,1) == GUIsets.tgtTrack;
                rawToMappings{i}(oldInd,1) = GUIsets.srcTrack;
                rawToMappings{i}(oldInd,2) = rawToMappings{i}(oldInd,2) + oldSrcLen;
                
                bigInds = rawToMappings{i}(:,1) > GUIsets.tgtTrack;
                rawToMappings{i}(bigInds,1) = rawToMappings{i}(bigInds,1) - 1;
            end
            
            %Fuse rawFromMappings
            rawFromMappings{GUIsets.srcTrack} = [rawFromMappings{GUIsets.srcTrack};rawFromMappings{GUIsets.tgtTrack}];
            rawFromMappings(GUIsets.tgtTrack) = [];
            
            %Clear colour value for track
            cScheme(GUIsets.tgtTrack,:) = [];
            
            %Clear the user-selected values now that the cutting is
            %complete
            GUIsets.srcT = [];
            GUIsets.srcTrack = [];
            GUIsets.srcID = [];
            GUIsets.srcPoint = [];
            GUIsets.tgtT = [];
            GUIsets.tgtTrack = [];
            GUIsets.tgtID = [];
            GUIsets.tgtPoint = [];
        end
end

imgHand = displayEditableTracks(GUIsets,rawTracks,trackTimes,rawFromMappings,rawToMappings,segDat,cScheme,handles.axes1);
set(imgHand,'ButtonDownFcn',@selectCell);

% --- Executes on button press in prevButton.
function prevButton_Callback(hObject, eventdata, handles)
% hObject    handle to prevButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GUIsets
global rawTracks
global trackTimes
global segDat
global cScheme
global imgHand
global rawToMappings
global rawFromMappings

if GUIsets.frame > 1
    GUIsets.frame = GUIsets.frame - 1;
    handles.edit1.String = num2str(GUIsets.frame);
end

%Update the segmentation frame storage
segDat = updateSegmentationStorage(segDat,GUIsets.frame+1,GUIsets);

imgHand = displayEditableTracks(GUIsets,rawTracks,trackTimes,rawFromMappings,rawToMappings,segDat,cScheme,handles.axes1);
set(imgHand,'ButtonDownFcn',@selectCell);

% --- Executes on button press in nextButt.
function nextButt_Callback(hObject, eventdata, handles)
% hObject    handle to nextButt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GUIsets
global rawTracks
global trackTimes
global segDat
global cScheme
global imgHand
global rawToMappings
global rawFromMappings

if GUIsets.frame < GUIsets.maxF
    GUIsets.frame = GUIsets.frame + 1;
    handles.edit1.String = num2str(GUIsets.frame);
end

%Update the segmentation frame storage
segDat = updateSegmentationStorage(segDat,GUIsets.frame-1,GUIsets);

imgHand = displayEditableTracks(GUIsets,rawTracks,trackTimes,rawFromMappings,rawToMappings,segDat,cScheme,handles.axes1);
set(imgHand,'ButtonDownFcn',@selectCell);

% --- Executes on button press in FuseButt.
function FuseButt_Callback(hObject, eventdata, handles)
% hObject    handle to FuseButt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GUIsets
global rawTracks
global trackTimes
global segDat
global cScheme
global imgHand
global rawToMappings
global rawFromMappings

GUIsets.mode = 'Fuse';

GUIsets.srcID = [];
GUIsets.srcT = [];
GUIsets.tgtID = [];
GUIsets.tgtT = [];
GUIsets.IDswitch = 1;

handles.FuseButt.BackgroundColor = [0.7,1,0.7];
handles.CutButt.BackgroundColor = [1,0.7,0.7];

imgHand = displayEditableTracks(GUIsets,rawTracks,trackTimes,rawFromMappings,rawToMappings,segDat,cScheme,handles.axes1);
set(imgHand,'ButtonDownFcn',@selectCell);

% --- Executes on button press in CutButt.
function CutButt_Callback(hObject, eventdata, handles)
% hObject    handle to CutButt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GUIsets
global rawTracks
global trackTimes
global segDat
global cScheme
global imgHand
global rawToMappings
global rawFromMappings

GUIsets.mode = 'Cut';

GUIsets.cutID = [];
GUIsets.cutT = [];

handles.FuseButt.BackgroundColor = [1,0.7,0.7];
handles.CutButt.BackgroundColor = [0.7,1,0.7];

imgHand = displayEditableTracks(GUIsets,rawTracks,trackTimes,rawFromMappings,rawToMappings,segDat,cScheme,handles.axes1);
set(imgHand,'ButtonDownFcn',@selectCell);

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
global GUIsets
global rawTracks
global trackTimes
global segDat
global cScheme
global imgHand
global rawToMappings
global rawFromMappings

oldFrame = GUIsets.frame;

txtValue = round(str2num(get(hObject,'String')));

if txtValue < 1 
    txtValue = 1;
elseif txtValue > GUIsets.maxF
    txtValue = GUIsets.maxF;
end

handles.edit1.String = num2str(txtValue);

GUIsets.frame = txtValue;

%Update the segmentation frame storage
segDat = updateSegmentationStorage(segDat,oldFrame,GUIsets);

imgHand = displayEditableTracks(GUIsets,rawTracks,trackTimes,rawFromMappings,rawToMappings,segDat,cScheme,handles.axes1);
set(imgHand,'ButtonDownFcn',@selectCell);

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

%Executes upon mouseclick on image
function selectCell(hObject, eventdata)
global GUIsets
global imgHand
global segDat
global rawTracks
global trackTimes
global cScheme
global rawToMappings
global rawFromMappings

axesHandle = get(imgHand,'Parent');
C = get(axesHandle,'CurrentPoint');

rdX = round(C(1,1));
rdY = round(C(1,2));

ID = segDat.frames{1}(rdY,rdX);

if ID ~= 0
    switch GUIsets.mode
        case 'Cut'
            GUIsets.cutID = ID;
            GUIsets.cutT = GUIsets.frame;
            
            GUIsets.cutTrack = rawToMappings{GUIsets.frame - GUIsets.minF + 1}(ID,1);
            GUIsets.cutPoint = rawToMappings{GUIsets.frame - GUIsets.minF + 1}(ID,2);
        case 'Fuse'
            if GUIsets.IDswitch == 1 && rawToMappings{GUIsets.frame - GUIsets.minF + 1}(ID,2) == size(trackTimes{rawToMappings{GUIsets.frame - GUIsets.minF + 1}(ID,1)},2)
                GUIsets.srcID = ID;
                GUIsets.srcT = GUIsets.frame;
                GUIsets.IDswitch = 2;
                
                GUIsets.srcTrack = rawToMappings{GUIsets.frame - GUIsets.minF + 1}(ID,1);
                GUIsets.srcPoint = rawToMappings{GUIsets.frame - GUIsets.minF + 1}(ID,2);
            elseif GUIsets.IDswitch == 2 && GUIsets.frame > GUIsets.srcT && rawToMappings{GUIsets.frame - GUIsets.minF + 1}(ID,2) == 1
                GUIsets.tgtID = ID;
                GUIsets.tgtT = GUIsets.frame;
                GUIsets.IDswitch = 1;
                
                GUIsets.tgtTrack = rawToMappings{GUIsets.frame - GUIsets.minF + 1}(ID,1);
                GUIsets.tgtPoint = rawToMappings{GUIsets.frame - GUIsets.minF + 1}(ID,2);
            end
    end
end

imgHand = displayEditableTracks(GUIsets,rawTracks,trackTimes,rawFromMappings,rawToMappings,segDat,cScheme,axesHandle);
set(imgHand,'ButtonDownFcn',@selectCell);


% --- Executes on button press in RerollButt.
function RerollButt_Callback(hObject, eventdata, handles)
% hObject    handle to RerollButt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GUIsets
global rawTracks
global trackTimes
global segDat
global cScheme
global imgHand
global rawToMappings
global rawFromMappings

%Assign random colours to each track
cmap = colormap('cool');
cmap = round(cmap*254);
inds = randi(size(cmap,1),size(trackTimes,2),1);
cScheme = cmap(inds,:);

imgHand = displayEditableTracks(GUIsets,rawTracks,trackTimes,rawFromMappings,rawToMappings,segDat,cScheme,handles.axes1);
set(imgHand,'ButtonDownFcn',@selectCell);

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GUIsets
global rawTracks
global trackTimes
global rawToMappings
global rawFromMappings
global debugSet

%This part will take care of saving the newly reconfigured tracks.
%Processing these tracks and plotting the results is taken care of on the
%side of the main GUI, through the terminateCorrection.m function callback.

debugprogressbar(0,debugSet)

save([GUIsets.root,filesep,'Tracks.mat'],'rawFromMappings','rawToMappings','rawTracks','trackTimes','-append');
if exist(fullfile(GUIsets.root,'Pre-division_Tracks.mat'),'file')
    save(fullfile(GUIsets.root,'Pre-division_Tracks.mat'),'rawFromMappings','rawToMappings','rawTracks','trackTimes','-append');
end

debugprogressbar(1,debugSet)

% Hint: delete(hObject) closes the figure
delete(hObject);
