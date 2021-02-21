function varargout = diffusionTracker(varargin)
% DIFFUSIONTRACKER MATLAB code for diffusionTracker.fig
%      DIFFUSIONTRACKER, by itself, creates a new DIFFUSIONTRACKER or raises the existing
%      singleton*.
%
%      H = DIFFUSIONTRACKER returns the handle to a new DIFFUSIONTRACKER or the handle to
%      the existing singleton*.
%
%      DIFFUSIONTRACKER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DIFFUSIONTRACKER.M with the given input arguments.
%
%      DIFFUSIONTRACKER('Property','Value',...) creates a new DIFFUSIONTRACKER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before diffusionTracker_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to diffusionTracker_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help diffusionTracker

% Last Modified by GUIDE v2.5 21-Jan-2020 14:55:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @diffusionTracker_OpeningFcn, ...
                   'gui_OutputFcn',  @diffusionTracker_OutputFcn, ...
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


% --- Executes just before diffusionTracker is made visible.
function diffusionTracker_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to diffusionTracker (see VARARGIN)

% Choose default command line output for diffusionTracker
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes diffusionTracker wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global root
global trackSettings
global trackableData        
global rawToMappings
global rawFromMappings
global trackTimes
global rawTracks
global debugSet

root = varargin{1}.rootdir;
debugSet = varargin{1}.debugSet;

load([root,filesep,'CellFeatures.mat']);

%Initialize checkboxes based on what features have been extracted
if isfield(trackableData,'Centroid')
    handles.PosCheck.Value = 1.0;
    trackSettings.Velocity = 0;
    trackSettings.Centroid = 1;
else
    trackSettings.Centroid = 0;
    trackSettings.Velocity = 0;
end

if isfield(trackableData,'Length')
    handles.LenCheck.Enable = 'on';
    trackSettings.Length = 0;
else
    trackSettings.Length = 0;
end

if isfield(trackableData,'Area')
    handles.AreaCheck.Enable = 'on';
    trackSettings.Area = 0;
else
    trackSettings.Area = 0;
end

if isfield(trackableData,'Width')
    handles.WidCheck.Enable = 'on';
    trackSettings.Width = 0;
else
    trackSettings.Width = 0;
end

if isfield(trackableData,'Orientation')
    handles.OriCheck.Enable = 'on';
    trackSettings.Orientation = 0;
else
    trackSettings.Orientation = 0;
end

if featSettings.noChannels > 0
    handles.pushbutton7.Enable = 'on';
    trackSettings.noChannels = featSettings.noChannels;
    trackSettings.availableMeans = featSettings.MeanInc;
    trackSettings.availableStds = featSettings.StdInc;
else
    trackSettings.noChannels = 0;
    trackSettings.availableMeans = [];
    trackSettings.availableStds = [];
end
trackSettings.MeanInc = [];
trackSettings.StdInc = [];

if isfield(trackableData,'SpareFeat1')
    handles.SF1Check.Enable = 'on';
    trackSettings.SpareFeat1 = 0;
else
    trackSettings.SpareFeat1 = 0;
end

if isfield(trackableData,'SpareFeat2')
    handles.SF2Check.Enable = 'on';
    trackSettings.SpareFeat2 = 0;
else
    trackSettings.SpareFeat2 = 0;
end

if isfield(trackableData,'SpareFeat3')
    handles.SF3Check.Enable = 'on';
    trackSettings.SpareFeat3 = 0;
else
    trackSettings.SpareFeat3 = 0;
end
    
if isfield(trackableData,'SpareFeat4')
    handles.SF4Check.Enable = 'on';
    trackSettings.SpareFeat4 = 0;
else
    trackSettings.SpareFeat4 = 0;
end

%Set up the sliders
trackSettings.incProp = 0.5;
trackSettings.tgtDensity = 1e-3;
trackSettings.gapWidth = 2;
trackSettings.maxFrame = maxT;
trackSettings.minFrame = 1;
trackSettings.minTrackLen = 2;
trackSettings.frameA = 2;
trackSettings.statsUse = 'Centroid';
trackSettings.pseudoTracks = false; %Variable set to true in extractFeatureEngine.m if the 'tracks' have come from a single frame.

handles.PropSlide.Value = trackSettings.incProp;
handles.AdaptSlide.Value = log10(trackSettings.tgtDensity);
handles.GapSlide.Value = trackSettings.gapWidth;
handles.slider4.Value = trackSettings.maxFrame;
handles.FrameASlide.Value = trackSettings.frameA;
handles.TrackLenSlide.Value = trackSettings.minTrackLen;

handles.PropEdit.String = num2str(trackSettings.incProp);
handles.AdaptEdit.String = num2str(trackSettings.tgtDensity);
handles.GapEdit.String = num2str(trackSettings.gapWidth);
handles.FrameLoEdit.String = num2str(trackSettings.minFrame);
handles.FrameAEdit.String = num2str(trackSettings.frameA);
handles.TrackLenEdit.String = num2str(trackSettings.minTrackLen);
handles.FrameHiEdit.String = num2str(trackSettings.maxFrame);

handles.text16.String = ['(max = ', num2str(maxT),')'];

handles.slider4.Max = maxT;
handles.GapSlide.Max = max(handles.GapSlide.Max,handles.slider4.Max - 1);
handles.FrameASlide.Max = min(trackSettings.maxFrame-1,maxT-1);
handles.TrackLenSlide.Max = maxT;

handles.AllFeatRadio.Value = 0;
handles.CentOnlyRadio.Value = 1;

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
[strArrX,strArrY] = getPopupStrings(trackSettings);
handles.YPopup.String = strArrX;
handles.XPopup.String = strArrY;

trackSettings.xString = handles.XPopup.String{handles.XPopup.Value};
trackSettings.yString = handles.YPopup.String{handles.YPopup.Value};

trackSettings.calculated = 0; %This setting will change to 1 once the initial statistics have been calculated
trackSettings.testTracked = 0; %This setting will change to 1 once test tracking has been completed
trackSettings.tracked = 0;

trackSettings.dt = featSettings.dt;
trackSettings.pixSize = featSettings.pixSize;
trackSettings.maxX = featSettings.maxX;
trackSettings.maxY = featSettings.maxY;
trackSettings.maxF = maxT;

%If you have already done tracking, makes sense that you should be able to
%have access to the track validation functionality
if exist(fullfile(root,'Pre-division_Tracks.mat'),'file') %If you've run division detection already, you need to use the tracks from before division detection was applied. This will overwrite division detected data
    load(fullfile(root,'Pre-division_Tracks.mat'),'trackableData','rawTracks','trackTimes','rawToMappings','rawFromMappings','trackSettings')
    handles.ValidateButt.Enable = 'on';
    trackSettings.tracked = 1;
    
    %Make sure to immediately go back to the pre-division detection file
    %structure, to avoid issues if the module is terminated early
    copyfile([root,filesep,'Pre-division_Tracks.mat'],[root,filesep,'Tracks.mat'])
    delete([root,filesep,'Pre-division_Tracks.mat'])
elseif exist([root,filesep,'Tracks.mat'],'file')
    vars = whos('-file',[root,filesep,'Tracks.mat']);
    if sum(ismember({vars.name},'rawToMappings')) > 0 %Ensures this code only triggers if you are using a Tracks.mat file format from FAST v0.8 or later
        load([root,filesep,'Tracks.mat'],'rawTracks','trackTimes','rawToMappings','rawFromMappings','trackSettings')
        handles.ValidateButt.Enable = 'on';
        trackSettings.tracked = 1;
    end
end

%Update GUI elements to take on previous values if tracking previously
%terminated.
if exist(fullfile(root,'Pre-division_Tracks.mat'),'file') || exist([root,filesep,'Tracks.mat'],'file')
    handles.PosCheck.Value = trackSettings.Centroid;
    handles.VelCheck.Value = trackSettings.Velocity;
    handles.LenCheck.Value = trackSettings.Length;
    handles.AreaCheck.Value = trackSettings.Area;
    handles.WidCheck.Value = trackSettings.Width;
    handles.OriCheck.Value = trackSettings.Orientation;
    handles.SF1Check.Value = trackSettings.SpareFeat1;
    handles.SF2Check.Value = trackSettings.SpareFeat2;
    handles.SF3Check.Value = trackSettings.SpareFeat3;
    handles.SF4Check.Value = trackSettings.SpareFeat4;
    
    switch trackSettings.statsUse
        case 'Centroid'
            handles.CentOnlyRadio = 1;
            handles.AllFeatRadio = 0;
        case 'All'
            handles.AllFeatRadio = 1;
            handles.CentOnlyRadio = 0;
    end
    
    handles.PropSlide.Value = trackSettings.incProp;
    handles.AdaptSlide.Value = log10(trackSettings.tgtDensity);
    handles.GapSlide.Value = trackSettings.gapWidth;
    handles.FrameASlide.Value = trackSettings.frameA;
    handles.TrackLenSlide.Value = trackSettings.minTrackLen;
    
    handles.PropEdit.String = num2str(trackSettings.incProp);
    handles.AdaptEdit.String = num2str(trackSettings.tgtDensity);
    handles.GapEdit.String = num2str(trackSettings.gapWidth);
    handles.FrameLoEdit.String = num2str(trackSettings.minFrame);
    handles.FrameAEdit.String = num2str(trackSettings.frameA);
    handles.TrackLenEdit.String = num2str(trackSettings.minTrackLen);
    handles.FrameHiEdit.String = num2str(trackSettings.maxFrame);
end

% --- Outputs from this function are returned to the command line.
function varargout = diffusionTracker_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in YPopup.
function YPopup_Callback(hObject, eventdata, handles)
% hObject    handle to YPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns YPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from YPopup
global trackSettings
global calcTrackSettings
global testDiffs
global linkStats

if trackSettings.calculated == 1
    trackSettings.yString = handles.YPopup.String{handles.YPopup.Value};
    calcTrackSettings.yString = handles.YPopup.String{handles.YPopup.Value};
end

if trackSettings.testTracked == 1
    tmpTrackSettings = calcTrackSettings;
    tmptrackSettings.tgtDensity = trackSettings.tgtDensity;
    plotNormalizedStepSizes(tmpTrackSettings,testDiffs,linkStats,handles.axes2)
end

% --- Executes during object creation, after setting all properties.
function YPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to YPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in XPopup.
function XPopup_Callback(hObject, eventdata, handles)
% hObject    handle to XPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns XPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from XPopup
global trackSettings
global calcTrackSettings
global testDiffs
global linkStats

if trackSettings.calculated == 1
    trackSettings.xString = handles.XPopup.String{handles.XPopup.Value};
    calcTrackSettings.xString = handles.XPopup.String{handles.XPopup.Value};
end

if trackSettings.testTracked == 1
    tmpTrackSettings = calcTrackSettings;
    tmptrackSettings.tgtDensity = trackSettings.tgtDensity;
    plotNormalizedStepSizes(tmpTrackSettings,testDiffs,linkStats,handles.axes2)
end

% --- Executes during object creation, after setting all properties.
function XPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to XPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in CalculateButt - the 'Calculate!' button
function CalculateButt_Callback(hObject, eventdata, handles)
% hObject    handle to CalculateButt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global trackSettings
global calcTrackSettings
global trackableData
global linkStats
global featMats
global featureStruct
global possIdx
global debugSet
global unnormStepSizes

[linkStats,featMats,featureStruct,possIdx] = gatherLinkStats(trackableData,trackSettings,debugSet);

%Set up the strings for the drop down menus
[strArrX,strArrY] = getPopupStrings(trackSettings);
handles.YPopup.String = strArrX;
handles.XPopup.String = strArrY;
handles.YPopup.Value = 1;
handles.XPopup.Value = 1;

trackSettings.xString = handles.XPopup.String{handles.XPopup.Value};
trackSettings.yString = handles.YPopup.String{handles.YPopup.Value};

%Indicate that statistics have been calculated
trackSettings.calculated = 1;
trackSettings.tracked = 0;
trackSettings.testTracked = 0;
handles.TrackButt.Enable = 'on';
handles.TestTrackButt.Enable = 'on';
handles.ToggleButt.Enable = 'on';
handles.ValidateButt.Enable = 'off';

%Update the range of possible test-track frames available according to what data has been arranged in the feature matrices
handles.FrameASlide.Max = trackSettings.maxFrame-1;
if handles.FrameASlide.Value > handles.FrameASlide.Max
    handles.FrameASlide.Value = handles.FrameASlide.Max;
    handles.FrameAEdit.String = num2str(handles.FrameASlide.Max);
end

%Do the plotting for the GUI - axes 1 and 5
handles.axes5.Visible = 'on';
unnormStepSizes = plotUnnormalizedStepSizes(featMats,trackSettings.incProp,trackSettings.statsUse,linkStats.trackability,[],handles.axes1,handles.axes5);

%Clear the axes for the other figures (no longer accurate with new calculated statistics)
cla(handles.axes2)
cla(handles.axes3)
cla(handles.axes4)

calcTrackSettings = trackSettings; %Track settings used the last time the 'Calculate!' button was pushed - prevents tracking and test-tracking becoming confused based on updates to checkboxes.


% --- Executes on button press in TrackButt - the 'Track!' button.
function TrackButt_Callback(hObject, eventdata, handles)
% hObject    handle to TrackButt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global trackSettings
global featMats
global linkStats
global trackableData
global rawTracks
global trackTimes
global root
global rawFromMappings
global rawToMappings
global debugSet

debugprogressbar([0;0;0],debugSet);

featureStruct = prepareTrackStruct(trackSettings);
featureNames = fieldnames(featureStruct);

%Begin by building a cell array with a unique index for each possible cell
possIdx = cell(trackSettings.maxFrame - trackSettings.minFrame + 1, 1);
for i = trackSettings.minFrame:trackSettings.maxFrame
    possIdx{i - trackSettings.minFrame + 1} = 1:size(trackableData.(featureNames{1}){i},1);
end

%Build feature matrices
[featMats.lin,featMats.circ] = buildFeatureMatricesRedux(trackableData,featureStruct,possIdx,trackSettings.minFrame,trackSettings.maxFrame);

[Tracks,Initials] = doDirectLinkingRedux(featMats.lin,featMats.circ,featMats.lin,featMats.circ,linkStats,trackSettings.gapWidth,false,debugSet);

trackDataNames = fieldnames(trackableData);
rawTracks = struct();
for i = 1:size(trackDataNames,1)
    if i == 1
        [rawTracks.(trackDataNames{i}),trackTimes,rawToMappings,rawFromMappings] = extractDataTrack(Tracks,Initials,trackableData.(trackDataNames{i})(trackSettings.minFrame:trackSettings.maxFrame),true);
    else
        rawTracks.(trackDataNames{i}) = extractDataTrack(Tracks,Initials,trackableData.(trackDataNames{i})(trackSettings.minFrame:trackSettings.maxFrame),false);
    end
    debugprogressbar([0.6;i/size(trackDataNames,1);0],debugSet);
end

%This bit of code adds on the time cut off from the start of the imaging sequence by the user during frame selection. Might not be what the end user wants, but they can always take this number off again if they want.
%Does make later bits of code (e.g. loading the image files for underlays) simpler.
for i = 1:size(trackTimes,2)
    trackTimes{i} = trackTimes{i} + trackSettings.minFrame - 1;
end

[procTracks,fromMappings,toMappings] = processTracks(rawTracks,rawFromMappings,rawToMappings,trackSettings,trackTimes,debugSet);
plotTrackLengthDistribution(rawTracks.(trackDataNames{1}),handles.axes3,trackSettings.minTrackLen)

trackSettings.tracked = 1;
handles.ValidateButt.Enable = 'on';

save([root,filesep,'Tracks.mat'],'procTracks','rawFromMappings','rawToMappings','rawTracks','trackTimes','toMappings','fromMappings','trackSettings','trackableData','linkStats','-v7.3')

debugprogressbar([1;1;1],debugSet);

% --- Executes on button press in TestTrackButt - the 'Test track!' button
function TestTrackButt_Callback(hObject, eventdata, handles)
% hObject    handle to TestTrackButt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global root
global featMats
global linkStats
global trackSettings
global calcTrackSettings
global trackableData
global testDiffs
global debugSet

%Check the required segmentation directory and the segmentation parameter structre exist first
if ~exist([root,filesep,'SegmentationSettings.mat'],'file') || ~exist([root,filesep,'Segmentations'],'dir')
    errordlg('Track testing not supported without specified segmentation channel and segmentation images! For track validation, please use options in the overlays GUI.')
    return
elseif ~isfield(trackableData,'Centroid')
    errordlg('Track testing not supported without information about object centroids! For track validation, please use options in the overlays GUI.')
    return
end

debugprogressbar([0;0;0],debugSet);

linSmallMats = featMats.lin(trackSettings.frameA-calcTrackSettings.minFrame+1:trackSettings.frameA-calcTrackSettings.minFrame+2);
circSmallMats = featMats.circ(trackSettings.frameA-calcTrackSettings.minFrame+1:trackSettings.frameA-calcTrackSettings.minFrame+2);
smallTrackableData.Centroid = trackableData.Centroid(trackSettings.frameA:trackSettings.frameA+1);

tmpLinkStats = linkStats;
tmpLinkStats.linMs = tmpLinkStats.linMs(trackSettings.frameA-calcTrackSettings.minFrame+1,:);
tmpLinkStats.circMs = tmpLinkStats.circMs(trackSettings.frameA-calcTrackSettings.minFrame+1,:);
tmpLinkStats.covDfs = tmpLinkStats.covDfs(trackSettings.frameA-calcTrackSettings.minFrame+1,:,:);
tmpLinkStats.covFs = tmpLinkStats.covFs(trackSettings.frameA-calcTrackSettings.minFrame+1,:,:);
tmpLinkStats.trackability = tmpLinkStats.trackability(trackSettings.frameA-calcTrackSettings.minFrame+1,:);
tmpLinkStats.incRads = tmpLinkStats.incRads(trackSettings.frameA-calcTrackSettings.minFrame+1,:);
[Tracks,Initials,~,~,~,~,acceptDiffs,rejectDiffs] = doDirectLinkingRedux(linSmallMats,circSmallMats,linSmallMats,circSmallMats,tmpLinkStats,trackSettings.gapWidth,true,debugSet);

testDiffs.accept = acceptDiffs;
testDiffs.reject = rejectDiffs;

[testTracks.Centroid,trackTimes,rawToMappings,rawFromMappings] = extractDataTrack(Tracks,Initials,smallTrackableData.Centroid,true);

calcTrackSettings.tgtDensity = trackSettings.tgtDensity;
calcTrackSettings.frameA = trackSettings.frameA;
calcTrackSettings.minTrackLen = 1;
plotNormalizedStepSizes(calcTrackSettings,testDiffs,linkStats,handles.axes2)

testData = processTracks(testTracks,rawFromMappings,rawToMappings,calcTrackSettings,trackTimes,debugSet);

%Check which channel was used for segmentations
load([root,filesep,'SegmentationSettings.mat'])

BFPaths{1} = [root,filesep,'Channel_',num2str(segmentParams.segmentChan),filesep,sprintf('Frame_%04d.tif',trackSettings.frameA-1)];
BFPaths{2} = [root,filesep,'Channel_',num2str(segmentParams.segmentChan),filesep,sprintf('Frame_%04d.tif',trackSettings.frameA)];
SegPaths{1} = [root,filesep,'Segmentations',filesep,sprintf('Frame_%04d.tif',trackSettings.frameA-1)];
SegPaths{2} = [root,filesep,'Segmentations',filesep,sprintf('Frame_%04d.tif',trackSettings.frameA)];
OutPaths{1} = [root,filesep,'TestTrack_0001.tif'];
OutPaths{2} = [root,filesep,'TestTrack_0002.tif'];

plotTrackedCellSegmentedOverlay(testData,BFPaths,SegPaths,OutPaths,trackSettings.pixSize);

if trackSettings.testTracked
    lims = axis(handles.axes4);
    imshow(imread(OutPaths{1}),'Parent',handles.axes4)
    axis(handles.axes4,lims)
else
    imshow(imread(OutPaths{1}),'Parent',handles.axes4)
end

trackSettings.ABstate = 1;
trackSettings.testTracked = 1;

debugprogressbar([1;1;1],debugSet);

% --- Executes on button press in ToggleButt - the 'Toggle A/B' button
function ToggleButt_Callback(hObject, eventdata, handles)
% hObject    handle to ToggleButt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global root
global trackSettings

if isfield(trackSettings,'ABstate')
    lims = axis(handles.axes4);
    if trackSettings.ABstate == 1
        imshow(imread([root,filesep,'TestTrack_0002.tif']),'Parent',handles.axes4)
        trackSettings.ABstate = 2;
    elseif trackSettings.ABstate == 2
        imshow(imread([root,filesep,'TestTrack_0001.tif']),'Parent',handles.axes4)
        trackSettings.ABstate = 1;
    end
    axis(handles.axes4,lims)
else
    errordlg('Run Test track first!')
end

% --- Executes on button press in pushbutton7 - the 'Channel selection'
% button
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global trackSettings

meanVec = zeros(trackSettings.noChannels,1);
stdVec = zeros(trackSettings.noChannels,1);
meanVec(trackSettings.availableMeans) = true;
stdVec(trackSettings.availableStds) = true;

meansOn = zeros(trackSettings.noChannels,1);
stdsOn = zeros(trackSettings.noChannels,1);
meansOn(trackSettings.MeanInc) = true;
stdsOn(trackSettings.StdInc) = true;

chanSettings = ChannelPicker(meanVec,stdVec,meansOn,stdsOn);

trackSettings.MeanInc = find(chanSettings.chanMeans);
trackSettings.StdInc = find(chanSettings.chanStds);

% --- Executes on button press in ValidateButt - the 'Validate' button
function ValidateButt_Callback(hObject, eventdata, handles)
% hObject    handle to ValidateButt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global trackSettings
global rawTracks
global trackTimes
global root
global rawFromMappings
global rawToMappings
global trackableData
global linkStats
global debugSet

if ~exist([root,filesep,'SegmentationSettings.mat'],'file') || ~exist([root,filesep,'Segmentations'],'dir')
    errordlg('Track correction not supported without specified segmentation channel and segmentation images! For validation, please use options in the overlays GUI.')
    return
end

nextHand = struct;
nextHand.trackTimes = trackTimes;
nextHand.rawFromMappings = rawFromMappings;
nextHand.rawToMappings = rawToMappings;
nextHand.rawTracks = rawTracks;
nextHand.maxF = trackSettings.maxFrame;
nextHand.minF = trackSettings.minFrame;
nextHand.pxSize = trackSettings.pixSize;
nextHand.root = root;

load([root,filesep,'SegmentationSettings.mat'])

nextHand.underlayDir = [root,filesep,'Channel_',num2str(segmentParams.segmentChan)];

clearvars -global GUIsets cScheme imgHand segDat

corrHand = CorrectTracks(nextHand); %Use of global variables with the same name in the CorrectTracks.m function ensures that data is shared between GUI windows
corrHand.DeleteFcn = {@terminateCorrection,handles,trackSettings,root,debugSet};

if ~debugSet
    corrHand.WindowStyle = 'modal';
end

% --- Executes on button press in LenCheck.
function LenCheck_Callback(hObject, eventdata, handles)
% hObject    handle to LenCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of LenCheck
global trackSettings

trackSettings.Length = get(hObject,'Value');


% --- Executes on button press in AreaCheck.
function AreaCheck_Callback(hObject, eventdata, handles)
% hObject    handle to AreaCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of AreaCheck
global trackSettings

trackSettings.Area = get(hObject,'Value');

% --- Executes on button press in WidCheck.
function WidCheck_Callback(hObject, eventdata, handles)
% hObject    handle to WidCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of WidCheck
global trackSettings

trackSettings.Width = get(hObject,'Value');

% --- Executes on button press in OriCheck.
function OriCheck_Callback(hObject, eventdata, handles)
% hObject    handle to OriCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of OriCheck
global trackSettings

trackSettings.Orientation = get(hObject,'Value');

% --- Executes on button press in VelCheck.
function VelCheck_Callback(hObject, eventdata, handles)
% hObject    handle to VelCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of VelCheck
global trackSettings

trackSettings.Velocity = get(hObject,'Value');

% --- Executes on button press in PosCheck.
function PosCheck_Callback(hObject, eventdata, handles)
% hObject    handle to PosCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of PosCheck
global trackSettings

trackSettings.Centroid = get(hObject,'Value');

% --- Executes on button press in SF1Check.
function SF1Check_Callback(hObject, eventdata, handles)
% hObject    handle to SF1Check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SF1Check
global trackSettings

trackSettings.SpareFeat1 = get(hObject,'Value');

% --- Executes on button press in SF2Check.
function SF2Check_Callback(hObject, eventdata, handles)
% hObject    handle to SF2Check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SF2Check
global trackSettings

trackSettings.SpareFeat2 = get(hObject,'Value');

% --- Executes on button press in SF3Check.
function SF3Check_Callback(hObject, eventdata, handles)
% hObject    handle to SF3Check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SF3Check
global trackSettings

trackSettings.SpareFeat3 = get(hObject,'Value');

% --- Executes on button press in SF4Check.
function SF4Check_Callback(hObject, eventdata, handles)
% hObject    handle to SF4Check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SF4Check
global trackSettings

trackSettings.SpareFeat4 = get(hObject,'Value');

% --- Executes on slider movement - Inclusion proportion
function PropSlide_Callback(hObject, eventdata, handles)
% hObject    handle to PropSlide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global trackSettings
global featMats
global linkStats
global unnormStepSizes

trackSettings.incProp = get(hObject,'Value');
handles.PropEdit.String = num2str(trackSettings.incProp);

if trackSettings.calculated == 1
    %Do the plotting for the GUI
    plotUnnormalizedStepSizes(featMats,trackSettings.incProp,trackSettings.statsUse,linkStats.trackability,unnormStepSizes,handles.axes1,handles.axes5);
end

% --- Executes during object creation, after setting all properties.
function PropSlide_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PropSlide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function PropEdit_Callback(hObject, eventdata, handles)
% hObject    handle to PropEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PropEdit as text
%        str2double(get(hObject,'String')) returns contents of PropEdit as a double
global trackSettings
global featMats
global linkStats
global unnormStepSizes

txtValue = str2double(get(hObject,'String'));

if txtValue > 1
    txtValue = 1;
elseif txtValue < 0 
    txtValue = 0;
end

trackSettings.incProp = txtValue;
handles.PropEdit.String = num2str(txtValue);
handles.PropSlide.Value = txtValue;

if trackSettings.calculated == 1
    %Do the plotting for the GUI
    plotUnnormalizedStepSizes(featMats,trackSettings.incProp,trackSettings.statsUse,linkStats.trackability,unnormStepSizes,handles.axes1,handles.axes5);
end

% --- Executes during object creation, after setting all properties.
function PropEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PropEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement - Density selection
function AdaptSlide_Callback(hObject, eventdata, handles)
% hObject    handle to AdaptSlide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global trackSettings
global testDiffs
global linkStats

trackSettings.tgtDensity = 10^(get(hObject,'Value'));
handles.AdaptEdit.String = num2str(trackSettings.tgtDensity);

%Recalculate link thresholds based on selected value
linkStats.incRads = zeros(size(linkStats.covDfs,1),1);
noFeats = size(linkStats.covDfs,2);

constFac = ((12/pi)^(1/2))*(trackSettings.tgtDensity ^ (1/noFeats));
for i = 1:size(linkStats.covDfs,1)
    detFac = (det(squeeze(linkStats.covFs(i,:,:)))/det(squeeze(linkStats.covDfs(i,:,:)))) ^ (1/(2*noFeats));
    gamFac = (gamma(1+noFeats/2))/(linkStats.noObj(i)-1) ^ (1/noFeats);
    linkStats.incRads(i) = constFac*detFac*gamFac;
end

if trackSettings.testTracked == 1
    plotNormalizedStepSizes(trackSettings,testDiffs,linkStats,handles.axes2)
end

% --- Executes during object creation, after setting all properties.
function AdaptSlide_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AdaptSlide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function AdaptEdit_Callback(hObject, eventdata, handles)
% hObject    handle to AdaptEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AdaptEdit as text
%        str2double(get(hObject,'String')) returns contents of AdaptEdit as a double
global trackSettings
global testDiffs
global linkStats

txtValue = log10(str2double(get(hObject,'String')));

trackSettings.tgtDensity = 10^txtValue;
handles.AdaptEdit.String = num2str(10^txtValue);

if txtValue > handles.AdaptSlide.Max
    txtValue = handles.AdaptSlide.Max;
end

handles.AdaptSlide.Value = txtValue;

%Recalculate link thresholds based on selected value
if trackSettings.calculated == 1
    linkStats.incRads = zeros(size(linkStats.covDfs,1),1);
    noFeats = size(linkStats.covDfs,2);
    
    constFac = ((12/pi)^(1/2))*(trackSettings.tgtDensity ^ (1/noFeats));
    for i = 1:size(linkStats.covDfs,1)
        detFac = (det(squeeze(linkStats.covFs(i,:,:)))/det(squeeze(linkStats.covDfs(i,:,:)))) ^ (1/(2*noFeats));
        gamFac = (gamma(1+noFeats/2))/(linkStats.noObj(i)-1) ^ (1/noFeats);
        linkStats.incRads(i) = constFac*detFac*gamFac;
    end
end

if trackSettings.testTracked == 1
    plotNormalizedStepSizes(trackSettings,testDiffs,linkStats,handles.axes2)
end

% --- Executes during object creation, after setting all properties.
function AdaptEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AdaptEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement - Gap width
function GapSlide_Callback(hObject, eventdata, handles)
% hObject    handle to GapSlide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global trackSettings
trackSettings.gapWidth = round(get(hObject,'Value'));
handles.GapEdit.String = num2str(trackSettings.gapWidth);

% --- Executes during object creation, after setting all properties.
function GapSlide_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GapSlide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function GapEdit_Callback(hObject, eventdata, handles)
% hObject    handle to GapEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GapEdit as text
%        str2double(get(hObject,'String')) returns contents of GapEdit as a double
global trackSettings
txtValue = round(str2double(get(hObject,'String')));

if txtValue < 0 
    txtValue = 0;
end

trackSettings.gapWidth = txtValue;
handles.GapEdit.String = num2str(txtValue);

if txtValue > handles.GapSlide.Max
    txtValue = handles.GapSlide.Max;
end

handles.GapSlide.Value = txtValue;

% --- Executes during object creation, after setting all properties.
function GapEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GapEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function FrameLoEdit_Callback(hObject, eventdata, handles)
% hObject    handle to FrameLoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FrameLoEdit as text
%        str2double(get(hObject,'String')) returns contents of FrameLoEdit as a double
global trackSettings
txtValue = round(str2double(get(hObject,'String')));

if txtValue < 1
    txtValue = 1;
end

if txtValue > trackSettings.maxFrame-1
    txtValue = trackSettings.maxFrame-1;
end

trackSettings.minFrame = txtValue;
handles.FrameLoEdit.String = num2str(txtValue);

handles.FrameASlide.Min = trackSettings.minFrame;
handles.TrackLenSlide.Max = trackSettings.maxFrame-trackSettings.minFrame+1;
handles.GapSlide.Max = trackSettings.maxFrame-trackSettings.minFrame;
handles.GapSlide.Min = 1;

if handles.FrameASlide.Value < handles.FrameASlide.Min
    handles.FrameASlide.Value = handles.FrameASlide.Min;
    handles.FrameAEdit.String = num2str(handles.FrameASlide.Value);
    trackSettings.frameA = handles.FrameASlide.Min;
end
if handles.TrackLenSlide.Value > handles.TrackLenSlide.Max
    handles.TrackLenSlide.Value = handles.TrackLenSlide.Max;
    handles.TrackLenEdit.String = num2str(handles.TrackLenSlide.Value);
    trackSettings.gapWidth = handles.TrackLenSlide.Max;
end
if handles.GapSlide.Value > handles.GapSlide.Max
    handles.GapSlide.Value = handles.GapSlide.Max;
    handles.GapEdit.String = num2str(handles.GapSlide.Value);
    trackSettings.gapWidth = handles.GapSlide.Max;
elseif handles.GapSlide.Value < handles.GapSlide.Min
    handles.GapSlide.Value = handles.GapSlide.Min;
    handles.GapEdit.String = num2str(handles.GapSlide.Value);
    trackSettings.gapWidth = handles.GapSlide.Max;
end

% --- Executes during object creation, after setting all properties.
function FrameLoEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FrameLoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement - frameA (for test tracking)
function FrameASlide_Callback(hObject, eventdata, handles)
% hObject    handle to FrameASlide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global trackSettings
trackSettings.frameA = round(get(hObject,'Value'));
handles.FrameAEdit.String = num2str(trackSettings.frameA);


% --- Executes during object creation, after setting all properties.
function FrameASlide_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FrameASlide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function FrameAEdit_Callback(hObject, eventdata, handles)
% hObject    handle to FrameAEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FrameAEdit as text
%        str2double(get(hObject,'String')) returns contents of FrameAEdit as a double
global trackSettings
txtValue = round(str2double(get(hObject,'String')));

if txtValue > handles.FrameASlide.Max 
    txtValue = handles.FrameASlide.Max;
elseif txtValue < handles.FrameASlide.Min
    txtValue = handles.FrameASlide.Min;
end

trackSettings.frameA = txtValue;
handles.FrameAEdit.String = num2str(txtValue);
handles.FrameASlide.Value = txtValue;

% --- Executes during object creation, after setting all properties.
function FrameAEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FrameAEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on slider movement.
function TrackLenSlide_Callback(hObject, eventdata, handles)
% hObject    handle to TrackLenSlide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global trackSettings
global trackableData
global rawTracks
global trackTimes
global root
global rawFromMappings
global rawToMappings
global debugSet

trackSettings.minTrackLen = round(get(hObject,'Value'));
handles.TrackLenEdit.String = num2str(trackSettings.minTrackLen);

if trackSettings.tracked
    debugprogressbar([0;0;0],debugSet)
    
    trackDataNames = fieldnames(trackableData);
    plotTrackLengthDistribution(rawTracks.(trackDataNames{1}),handles.axes3,trackSettings.minTrackLen)
    pause(0.1)
    
    %Do the track data processing in the background (once the track lengths have been plotted)
    [procTracks,fromMappings,toMappings] = processTracks(rawTracks,rawFromMappings,rawToMappings,trackSettings,trackTimes,debugSet);
    save([root,filesep,'Tracks.mat'],'procTracks','fromMappings','toMappings','-v7.3','-append')

    debugprogressbar([1;1;1],debugSet)
end

% --- Executes during object creation, after setting all properties.
function TrackLenSlide_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TrackLenSlide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function TrackLenEdit_Callback(hObject, eventdata, handles)
% hObject    handle to TrackLenEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TrackLenEdit as text
%        str2double(get(hObject,'String')) returns contents of TrackLenEdit as a double
global trackSettings
global trackableData
global rawTracks
global trackTimes
global root
global rawFromMappings
global rawToMappings
global debugSet

txtValue = round(str2double(get(hObject,'String')));

if txtValue > handles.TrackLenSlide.Max 
    txtValue = handles.TrackLenSlide.Max;
elseif txtValue < handles.TrackLenSlide.Min
    txtValue = handles.TrackLenSlide.Min;
end

trackSettings.minTrackLen = txtValue;
handles.TrackLenEdit.String = num2str(txtValue);
handles.TrackLenSlide.Value = txtValue;

if trackSettings.tracked
    debugprogressbar([0;0;0],debugSet)
    
    trackDataNames = fieldnames(trackableData);
    plotTrackLengthDistribution(rawTracks.(trackDataNames{1}),handles.axes3,trackSettings.minTrackLen)
    pause(0.1)
    
    %Do the track data processing in the background (once the track lengths have been plotted)
    [procTracks,fromMappings,toMappings] = processTracks(rawTracks,rawFromMappings,rawToMappings,trackSettings,trackTimes,debugSet);
    save([root,filesep,'Tracks.mat'],'procTracks','fromMappings','toMappings','-append')

    debugprogressbar([1;1;1],debugSet)
end

% --- Executes during object creation, after setting all properties.
function TrackLenEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TrackLenEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function FrameHiEdit_Callback(hObject, eventdata, handles)
% hObject    handle to FrameHiEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FrameHiEdit as text
%        str2double(get(hObject,'String')) returns contents of FrameHiEdit as a double
global trackSettings
txtValue = round(str2double(get(hObject,'String')));

if txtValue < trackSettings.minFrame+1
    txtValue = trackSettings.minFrame+1;
end

if txtValue > trackSettings.maxF
    txtValue = trackSettings.maxF;
end

trackSettings.maxFrame = txtValue;
handles.FrameHiEdit.String = num2str(txtValue);

handles.FrameASlide.Max = trackSettings.maxFrame-1;
handles.TrackLenSlide.Max = trackSettings.maxFrame-trackSettings.minFrame+1;
handles.GapSlide.Max = trackSettings.maxFrame-trackSettings.minFrame;
handles.GapSlide.Min = 1;

if handles.FrameASlide.Value > handles.FrameASlide.Max
    handles.FrameASlide.Value = handles.FrameASlide.Max;
    handles.FrameAEdit.String = num2str(handles.FrameASlide.Value);
    trackSettings.frameA = handles.FrameASlide.Max;
end
if handles.TrackLenSlide.Value > handles.TrackLenSlide.Max
    handles.TrackLenSlide.Value = handles.TrackLenSlide.Max;
    handles.TrackLenEdit.String = num2str(handles.TrackLenSlide.Value);
    trackSettings.gapWidth = handles.TrackLenSlide.Max;
end
if handles.GapSlide.Value > handles.GapSlide.Max
    handles.GapSlide.Value = handles.GapSlide.Max;
    handles.GapEdit.String = num2str(handles.GapSlide.Value);
    trackSettings.gapWidth = handles.GapSlide.Max;
elseif handles.GapSlide.Value < handles.GapSlide.Min
    handles.GapSlide.Value = handles.GapSlide.Min;
    handles.GapEdit.String = numwstr(handles.GapSlide.Value);
    trackSettings.gapWidth = handles.GapSlide.Min;
end

% --- Executes during object creation, after setting all properties.
function FrameHiEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FrameHiEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in AllFeatRadio.
function AllFeatRadio_Callback(hObject, eventdata, handles)
% hObject    handle to AllFeatRadio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of AllFeatRadio
global trackSettings

if get(hObject,'Value') == 1
    handles.CentOnlyRadio.Value = 0;
    trackSettings.statsUse = 'All';
elseif get(hObject,'Value') == 0
    if trackSettings.Centroid == 1
        handles.CentOnlyRadio.Value = 0;
        trackSettings.statsUse = 'Centroid';
    else
        errordlg('Can only use centroids if included as features!')
        handles.CentOnlyRadio.Value = 1;
        trackSettings.statsUse = 'All';
    end
end

% --- Executes on button press in CentOnlyRadio.
function CentOnlyRadio_Callback(hObject, eventdata, handles)
% hObject    handle to CentOnlyRadio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CentOnlyRadio
global trackSettings

if get(hObject,'Value') == 1
    if trackSettings.Centroid == 1
        handles.AllFeatRadio.Value = 0;
        trackSettings.statsUse = 'Centroid';
    else
        errordlg('Can only use centroids if included as features!')
        handles.AllFeatRadio.Value = 1;
        trackSettings.statsUse = 'All';
    end
elseif get(hObject,'Value') == 0
    handles.AllFeatRadio.Value = 1;
    trackSettings.statsUse = 'All';
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);
