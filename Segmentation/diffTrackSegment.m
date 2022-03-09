function varargout = diffTrackSegment(varargin)
% DIFFTRACKSEGMENT MATLAB code for diffTrackSegment.fig
%      DIFFTRACKSEGMENT, by itself, creates a new DIFFTRACKSEGMENT or raises the existing
%      singleton*.
%
%      H = DIFFTRACKSEGMENT returns the handle to a new DIFFTRACKSEGMENT or the handle to
%      the existing singleton*.
%
%      DIFFTRACKSEGMENT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DIFFTRACKSEGMENT.M with the given input arguments.
%
%      DIFFTRACKSEGMENT('Property','Value',...) creates a new DIFFTRACKSEGMENT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before diffTrackSegment_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to diffTrackSegment_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help diffTrackSegment

% Last Modified by GUIDE v2.5 26-Oct-2021 12:19:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @diffTrackSegment_OpeningFcn, ...
                   'gui_OutputFcn',  @diffTrackSegment_OutputFcn, ...
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


% --- Executes just before diffTrackSegment is made visible.
function diffTrackSegment_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to diffTrackSegment (see VARARGIN)

% Choose default command line output for diffTrackSegment
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes diffTrackSegment wait for user response (see UIRESUME)
% uiwait(handles.figure1);

global root
global img
global segmentParams
global frameCount
global debugSet

%Load previous segmentation settings if available, otherwise set default settings
if exist(fullfile(root,'SegmentationSettings.mat'))
    load(fullfile(root,'SegmentationSettings.mat'))
    
    %Set display parameters to defaults
    segmentParams.overlay = 'Texture';
    segmentParams.t = 0;

    %Deals with compatability issues for datasets analysed with previous
    %versions of FAST
    if ~isfield(segmentParams,'remHalos')
        segmentParams.remHalos = 0;
    end
    if ~isfield(segmentParams,'waterRecur')
        segmentParams.waterRecur = 0;
    end
else
    segmentParams.Neighbourhood = 9;
    segmentParams.TextureThresh = 2;
    segmentParams.waterThresh = 1.75;
    segmentParams.ridgeThresh = 0.2;
    segmentParams.ridgeScale = 15;
    segmentParams.Ahigh = 2500;
    segmentParams.Alow = 100;
    segmentParams.RidgeAMin = 100;
    segmentParams.invert = false;
    segmentParams.overlay = 'Texture';
    segmentParams.segmentChan = 1;
    segmentParams.ridgeErosion = 0;
    segmentParams.t = 0;
    segmentParams.remHalos = false;
    segmentParams.waterRecur = false;
end

root = varargin{1}.rootdir;
debugSet = varargin{1}.debugSet;

img = double(imread([root,filesep,'Channel_',num2str(segmentParams.segmentChan),filesep,sprintf('Frame_%04d.tif',segmentParams.t)]));
%img = (img - min(img(:)))/(max(img(:)) - min(img(:))); %This bit used to
%scale the images between 0 and 1, but I don't think we want to do this
%with the new texture analysis stage.

frameCont = dir([root,filesep,'Channel_',num2str(segmentParams.segmentChan),filesep]);
frameCount = 0;
for i = 1:size(frameCont,1)
    if numel(regexp(frameCont(i).name,'Frame_\d{4}.tif')) == 1
        frameCount = frameCount + 1;
    end
end

%Setup channel selection popup window
chanPopupStr = {};
noChan = 1;
while exist([root,filesep,'Channel_',num2str(noChan)],'dir')
    chanPopupStr = [chanPopupStr;'Channel ',num2str(noChan)];
    noChan = noChan + 1;
end
segmentParams.noChannels = noChan-1;
handles.popupmenu2.String = chanPopupStr;

%Setup sliders and edit boxes
handles.NHslider.Value = segmentParams.Neighbourhood;
handles.TTslider.Value = segmentParams.TextureThresh;
handles.RSslider.Value = segmentParams.ridgeScale;
handles.RTslider.Value = segmentParams.ridgeThresh;
handles.WTslider.Value = segmentParams.waterThresh;
handles.HAslider.Value = sqrt(segmentParams.Ahigh);
handles.LAslider.Value = sqrt(segmentParams.Alow);
handles.timeSlider.Value = segmentParams.t;
handles.RAslider.Value = sqrt(segmentParams.RidgeAMin);
handles.haloRemCheck.Value = segmentParams.remHalos;
handles.waterRecCheck.Value = segmentParams.waterRecur;

%Sliders will activate as appropriate overlay is selected. Start off with texture overlay selected.
handles.NHslider.Enable = 'on';
handles.text19.FontWeight = 'bold';
handles.TTslider.Enable = 'on';
handles.text6.FontWeight = 'bold';
handles.RSslider.Enable = 'off';
handles.text5.FontWeight = 'normal';
handles.RTslider.Enable = 'off';
handles.text4.FontWeight = 'normal';
handles.RAslider.Enable = 'off';
handles.text17.FontWeight = 'normal';
handles.WTslider.Enable = 'off';
handles.text3.FontWeight = 'normal';
handles.HAslider.Enable = 'off';
handles.text7.FontWeight = 'normal';
handles.LAslider.Enable = 'off';
handles.text9.FontWeight = 'normal';

handles.NHedit.String = num2str(segmentParams.Neighbourhood);
handles.TTedit.String = num2str(segmentParams.TextureThresh);
handles.RSedit.String = num2str(segmentParams.ridgeScale);
handles.RTedit.String = num2str(segmentParams.ridgeThresh);
handles.WTedit.String = num2str(segmentParams.waterThresh);
handles.HAedit.String = num2str(segmentParams.Ahigh);
handles.LAedit.String = num2str(segmentParams.Alow);
handles.text16.String = num2str(segmentParams.t);
handles.RAedit.String = num2str(segmentParams.RidgeAMin);

handles.timeSlider.Max = frameCount-1;

segmentImage(handles.axes1,true)


% --- Outputs from this function are returned to the command line.
function varargout = diffTrackSegment_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on slider movement.
function NHslider_Callback(hObject, eventdata, handles)
% hObject    handle to NHslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global segmentParams

currValue = 2*(round((get(hObject,'Value')-1)/2))+1;
segmentParams.Neighbourhood = currValue;
handles.NHedit.String = num2str(segmentParams.Neighbourhood);
segmentImage(handles.axes1,false)

% --- Executes during object creation, after setting all properties.
function NHslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NHslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function TTslider_Callback(hObject, eventdata, handles)
% hObject    handle to TTslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global segmentParams
segmentParams.TextureThresh = get(hObject,'Value');
handles.TTedit.String = num2str(segmentParams.TextureThresh);
segmentImage(handles.axes1,false)

% --- Executes during object creation, after setting all properties.
function TTslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TTslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function RSslider_Callback(hObject, eventdata, handles)
% hObject    handle to RSslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global segmentParams
segmentParams.ridgeScale = get(hObject,'Value');
handles.RSedit.String = num2str(segmentParams.ridgeScale);
segmentImage(handles.axes1,false)

% --- Executes during object creation, after setting all properties.
function RSslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RSslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function RTslider_Callback(hObject, eventdata, handles)
% hObject    handle to RTslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global segmentParams
segmentParams.ridgeThresh = get(hObject,'Value');
handles.RTedit.String = num2str(segmentParams.ridgeThresh);
segmentImage(handles.axes1,false)

% --- Executes during object creation, after setting all properties.
function RTslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RTslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function WTslider_Callback(hObject, eventdata, handles)
% hObject    handle to WTslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global segmentParams
segmentParams.waterThresh = get(hObject,'Value');
handles.WTedit.String = num2str(segmentParams.waterThresh);
segmentImage(handles.axes1,false)

% --- Executes during object creation, after setting all properties.
function WTslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WTslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function HAslider_Callback(hObject, eventdata, handles)
% hObject    handle to HAslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global segmentParams
segmentParams.Ahigh = get(hObject,'Value').^2;
handles.HAedit.String = num2str(segmentParams.Ahigh);
segmentImage(handles.axes1,false)

% --- Executes during object creation, after setting all properties.
function HAslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HAslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on slider movement.
function timeSlider_Callback(hObject, eventdata, handles)
% hObject    handle to timeSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global segmentParams
global img 
global root

segmentParams.t = round(get(hObject,'Value'));
handles.text16.String = num2str(segmentParams.t);

img = double(imread([root,filesep,'Channel_',num2str(segmentParams.segmentChan),filesep,sprintf('Frame_%04d.tif',segmentParams.t)]));
%img = (img - min(img(:)))/(max(img(:)) - min(img(:)));%This bit used to
%scale the images between 0 and 1, but I don't think we want to do this
%with the new texture analysis stage.

segmentImage(handles.axes1,false)

% --- Executes during object creation, after setting all properties.
function timeSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timeSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function LAslider_Callback(hObject, eventdata, handles)
% hObject    handle to LAslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global segmentParams

segmentParams.Alow = get(hObject,'Value').^2;
handles.LAedit.String = num2str(segmentParams.Alow);
segmentImage(handles.axes1,false)

% --- Executes during object creation, after setting all properties.
function LAslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LAslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on slider movement.
function RAslider_Callback(hObject, eventdata, handles)
% hObject    handle to RAslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global segmentParams

segmentParams.RidgeAMin = round(get(hObject,'Value').^2);
handles.RAedit.String = num2str(segmentParams.RidgeAMin);
segmentImage(handles.axes1,false)

% --- Executes during object creation, after setting all properties.
function RAslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RAslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global root
global segmentParams
global frameCount
global debugSet
segmentAndSave(root,debugSet,frameCount,segmentParams);

% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
global segmentParams

segmentParams.overlay = hObject.String{get(hObject,'Value')};

switch(segmentParams.overlay)
    case 'Texture'
        handles.NHslider.Enable = 'on';
        handles.text19.FontWeight = 'bold';
        handles.TTslider.Enable = 'on';
        handles.text6.FontWeight = 'bold';
        handles.RSslider.Enable = 'off';
        handles.text5.FontWeight = 'normal';
        handles.RTslider.Enable = 'off';
        handles.text4.FontWeight = 'normal';
        handles.RAslider.Enable = 'off';
        handles.text17.FontWeight = 'normal';
        handles.WTslider.Enable = 'off';
        handles.text3.FontWeight = 'normal';
        handles.HAslider.Enable = 'off';
        handles.text7.FontWeight = 'normal';
        handles.LAslider.Enable = 'off';
        handles.text9.FontWeight = 'normal';
    case 'Ridges'        
        handles.NHslider.Enable = 'off';
        handles.text19.FontWeight = 'normal';
        handles.TTslider.Enable = 'off';
        handles.text6.FontWeight = 'normal';
        handles.RSslider.Enable = 'on';
        handles.text5.FontWeight = 'bold';
        handles.RTslider.Enable = 'on';
        handles.text4.FontWeight = 'bold';
        handles.RAslider.Enable = 'on';
        handles.text17.FontWeight = 'bold';
        handles.WTslider.Enable = 'off';
        handles.text3.FontWeight = 'normal';
        handles.HAslider.Enable = 'off';
        handles.text7.FontWeight = 'normal';
        handles.LAslider.Enable = 'off';
        handles.text9.FontWeight = 'normal';
    case 'Watershed'
        handles.NHslider.Enable = 'off';
        handles.text19.FontWeight = 'normal';
        handles.TTslider.Enable = 'off';
        handles.text6.FontWeight = 'normal';
        handles.RSslider.Enable = 'off';
        handles.text5.FontWeight = 'normal';
        handles.RTslider.Enable = 'off';
        handles.text4.FontWeight = 'normal';
        handles.RAslider.Enable = 'off';
        handles.text17.FontWeight = 'normal';
        handles.WTslider.Enable = 'on';
        handles.text3.FontWeight = 'bold';
        handles.HAslider.Enable = 'off';
        handles.text7.FontWeight = 'normal';
        handles.LAslider.Enable = 'off';
        handles.text9.FontWeight = 'normal';
    case 'Segmentation'
        
        handles.NHslider.Enable = 'off';
        handles.text19.FontWeight = 'normal';
        handles.TTslider.Enable = 'off';
        handles.text6.FontWeight = 'normal';
        handles.RSslider.Enable = 'off';
        handles.text5.FontWeight = 'normal';
        handles.RTslider.Enable = 'off';
        handles.text4.FontWeight = 'normal';
        handles.RAslider.Enable = 'off';
        handles.text17.FontWeight = 'normal';
        handles.WTslider.Enable = 'off';
        handles.text3.FontWeight = 'normal';
        handles.HAslider.Enable = 'on';
        handles.text7.FontWeight = 'bold';
        handles.LAslider.Enable = 'on';
        handles.text9.FontWeight = 'bold';
    case 'None'
        handles.NHslider.Enable = 'off';
        handles.text19.FontWeight = 'normal';
        handles.TTslider.Enable = 'off';
        handles.text6.FontWeight = 'normal';
        handles.RSslider.Enable = 'off';
        handles.text5.FontWeight = 'normal';
        handles.RTslider.Enable = 'off';
        handles.text4.FontWeight = 'normal';
        handles.RAslider.Enable = 'off';
        handles.text17.FontWeight = 'normal';
        handles.WTslider.Enable = 'off';
        handles.text3.FontWeight = 'normal';
        handles.HAslider.Enable = 'off';
        handles.text7.FontWeight = 'normal';
        handles.LAslider.Enable = 'off';
        handles.text9.FontWeight = 'normal';
end

segmentImage(handles.axes1,false)


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

% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1
global segmentParams

if get(hObject,'Value') == 1
    segmentParams.invert = false;
    segmentImage(handles.axes1,false)
end
   
% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2
global segmentParams
global img
global root

segmentParams.segmentChan = get(hObject,'Value');

img = double(imread([root,filesep,'Channel_',num2str(segmentParams.segmentChan),filesep,sprintf('Frame_%04d.tif',segmentParams.t)]));
%img = (img - min(img(:)))/(max(img(:)) - min(img(:)));%This bit used to
%scale the images between 0 and 1, but I don't think we want to do this
%with the new texture analysis stage.

segmentImage(handles.axes1,false)

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


% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2

global segmentParams

if get(hObject,'Value') == 1
    segmentParams.invert = true;
    segmentImage(handles.axes1,false)
end

function WTedit_Callback(hObject, eventdata, handles)
% hObject    handle to WTedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of WTedit as text
%        str2double(get(hObject,'String')) returns contents of WTedit as a double
global segmentParams
txtValue = str2double(get(hObject,'String'));

if txtValue < 0 
    txtValue = 0;
end

segmentParams.waterThresh = txtValue;
handles.WTedit.String = num2str(txtValue);

if txtValue > handles.WTslider.Max
    txtValue = handles.WTslider.Max;
end

handles.WTslider.Value = txtValue;

segmentImage(handles.axes1,false)

% --- Executes during object creation, after setting all properties.
function WTedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WTedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function HAedit_Callback(hObject, eventdata, handles)
% hObject    handle to HAedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of HAedit as text
%        str2double(get(hObject,'String')) returns contents of HAedit as a double
global segmentParams
txtValue = str2double(get(hObject,'String'));

if txtValue < 0 
    txtValue = 0;
end

segmentParams.Ahigh = txtValue;
handles.HAedit.String = num2str(txtValue);

if txtValue > handles.HAslider.Max^2
    txtValue = handles.HAslider.Max^2;
end

handles.HAslider.Value = sqrt(txtValue);

segmentImage(handles.axes1,false)

% --- Executes during object creation, after setting all properties.
function HAedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HAedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function LAedit_Callback(hObject, eventdata, handles)
% hObject    handle to LAedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LAedit as text
%        str2double(get(hObject,'String')) returns contents of LAedit as a double
global segmentParams
txtValue = str2double(get(hObject,'String'));

if txtValue < 0 
    txtValue = 0;
end

segmentParams.Alow = txtValue;
handles.LAedit.String = num2str(txtValue);

if txtValue > handles.LAslider.Max^2
    txtValue = handles.LAslider.Max^2;
end

handles.LAslider.Value = sqrt(txtValue);

segmentImage(handles.axes1,false)


% --- Executes during object creation, after setting all properties.
function LAedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LAedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function RTedit_Callback(hObject, eventdata, handles)
% hObject    handle to RTedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RTedit as text
%        str2double(get(hObject,'String')) returns contents of RTedit as a double
global segmentParams
txtValue = str2double(get(hObject,'String'));

if txtValue < 0 
    txtValue = 0;
end

segmentParams.ridgeThresh = txtValue;
handles.RTedit.String = num2str(txtValue);

if txtValue > handles.RTslider.Max
    txtValue = handles.RTslider.Max;
end

handles.RTslider.Value = txtValue;

segmentImage(handles.axes1,false)

% --- Executes during object creation, after setting all properties.
function RTedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RTedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function RSedit_Callback(hObject, eventdata, handles)
% hObject    handle to RSedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RSedit as text
%        str2double(get(hObject,'String')) returns contents of RSedit as a double
global segmentParams
txtValue = str2double(get(hObject,'String'));

if txtValue < 0 
    txtValue = 0;
end

segmentParams.ridgeScale = txtValue;
handles.RSedit.String = num2str(txtValue);

if txtValue > handles.RSslider.Max
    txtValue = handles.RSslider.Max;
end

handles.RSslider.Value = txtValue;

segmentImage(handles.axes1,false)

% --- Executes during object creation, after setting all properties.
function RSedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RSedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function NHedit_Callback(hObject, eventdata, handles)
% hObject    handle to NHedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NHedit as text
%        str2double(get(hObject,'String')) returns contents of NHedit as a double
global segmentParams
txtValue = str2double(get(hObject,'String'));

if txtValue < 3
    txtValue = 3;
else
    txtValue = 2*(round((txtValue-1)/2))+1;
end

segmentParams.Neighbourhood = txtValue;
handles.NHedit.String = num2str(txtValue);
handles.NHslider.Value = txtValue;

segmentImage(handles.axes1,false)

% --- Executes during object creation, after setting all properties.
function NHedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NHedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function TTedit_Callback(hObject, eventdata, handles)
% hObject    handle to TTedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TTedit as text
%        str2double(get(hObject,'String')) returns contents of TTedit as a double
global segmentParams
txtValue = str2double(get(hObject,'String'));

if txtValue < 0
    txtValue = 0;
end

segmentParams.TextureThresh = txtValue;
handles.TTedit.String = num2str(txtValue);
handles.TTslider.Value = txtValue;

segmentImage(handles.axes1,false)

% --- Executes during object creation, after setting all properties.
function TTedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TTedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function RAedit_Callback(hObject, eventdata, handles)
% hObject    handle to RAedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RAedit as text
%        str2double(get(hObject,'String')) returns contents of RAedit as a double
global segmentParams
txtValue = str2double(get(hObject,'String'));

if txtValue < 0 
    txtValue = 0;
else
    txtValue = round(txtValue);
end

segmentParams.RidgeAMin = txtValue;
handles.RAedit.String = num2str(txtValue);

if txtValue > handles.RAslider.Max^2
    txtValue = handles.RAslider.Max^2;
end

handles.RAslider.Value = sqrt(txtValue);

segmentImage(handles.axes1,false)

% --- Executes during object creation, after setting all properties.
function RAedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RAedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in haloRemCheck.
function haloRemCheck_Callback(hObject, eventdata, handles)
% hObject    handle to haloRemCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of haloRemCheck
global segmentParams

segmentParams.remHalos = get(hObject,'Value');

segmentImage(handles.axes1,false)


% --- Executes on button press in recWaterCheck.
function recWaterCheck_Callback(hObject, eventdata, handles)
% hObject    handle to recWaterCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of recWaterCheck
global segmentParams

segmentParams.waterRecur = get(hObject,'Value');

segmentImage(handles.axes1,false)


function [] = segmentImage(axHand,init)
global img
global segmentParams

%Set parameters
MedFiltSize = 5;

%Apply a median filter
filtImg = medfilt2(img(:,:),[MedFiltSize,MedFiltSize]);
tempImg = filtImg;
imgMax = max(tempImg(:));

%Display image
cla
if init
    imshow(filtImg,[],'parent',axHand);
    lims = axis(axHand);
else
    lims = axis(axHand);
    imshow(filtImg,[],'parent',axHand);
end
hold on

if strcmp(segmentParams.overlay,'None')
    axis(axHand,lims);
    return
end

if segmentParams.invert 
    tempImg = imgMax-tempImg;
end

%Apply texture analysis
stdImg = stdfilt(tempImg,ones(segmentParams.Neighbourhood));
kernel = ones(segmentParams.Neighbourhood) / segmentParams.Neighbourhood^2; % Mean kernel
meanImg = conv2(tempImg, kernel, 'same'); % Convolve keeping size of I
seImg = stdImg./(meanImg.^0.5); %Logic here is that dividing by meanImg gives COV. However, the COV itself scales as one over the square root of the image intensity (shot noise), so multiply by that number to get just the contribution from the cells.
Texture = seImg > segmentParams.TextureThresh;

%Get rid of 'rims' around non-segmented patches
seStre = strel('disk',(segmentParams.Neighbourhood-1)/2);
Texture = imerode(Texture,seStre);

if strcmp(segmentParams.overlay,'Texture')
    colorOver = cat(3,Texture,zeros(size(Texture)),zeros(size(Texture)));
    overHand = imshow(colorOver,'parent',axHand);
    hold off
    alpha = Texture * 0.5;
    set(overHand,'AlphaData',alpha)
    axis(axHand,lims);
    return
end

%Do ridge-detection segmentation
Ridges = bwRidgeCenterMod(tempImg,segmentParams.ridgeScale,segmentParams.ridgeThresh);
se = strel('disk',segmentParams.ridgeErosion);
Ridges = imerode(Ridges,se);
Ridges = imdilate(Ridges,se);

%Adjust the Ridges image to remove any tiny, disconnected bits of
%ridges that might have sneaked in
Ridges = bwareaopen(Ridges,segmentParams.RidgeAMin);

if strcmp(segmentParams.overlay,'Ridges')
    colorOver = cat(3,Ridges,zeros(size(Ridges)),zeros(size(Ridges)));
    overHand = imshow(colorOver,'parent',axHand);
    hold off
    alpha = Ridges * 0.5;
    set(overHand,'AlphaData',alpha)
    axis(axHand,lims);
    return
end

tempSeg = and(Texture, ~Ridges);

%Apply a watershed transform to the image:
dists = -bwdist(~tempSeg);
distA = imhmin(dists,segmentParams.waterThresh);
distW = watershed(distA);

if strcmp(segmentParams.overlay,'Watershed')
    waterSE = strel('disk',1);
    binEdges = imdilate(bwmorph(tempSeg,'remove'),waterSE);
    newEdges = imdilate(and(distW == 0, tempSeg),waterSE);
    colorOver = cat(3,or(newEdges,binEdges),binEdges,zeros(size(distW)));
    overHand = imshow(colorOver,'parent',axHand);
    alpha = ~and(~newEdges,~binEdges);
    set(overHand,'AlphaData',alpha)
    axis(axHand,lims);
    return
end

tempSeg(distW == 0) = 0;

%Clear boundary touching objects and assign a unique ID number to each segmented out cell
tempSeg = imclearborder(tempSeg,4);
% tempSeg = imfill(tempSeg,'holes'); %Also fill in any holes that might
% appear in the cells as a result of ridge detection. Removed in latest
% version, since it ends up clearing out any patches of cells surrounded by
% halos in phase-contrast images.

%If requested, find the intensities of each object in this original
%segmentation and apply a Gaussian-mixture model to split the high- from
%low- intensity objects. Then delete any that are in the opposite peak from
%what you are hoping to segment (e.g. if foreground colour is black, delete
%any objects in the bright peak).
if segmentParams.remHalos
    segment = bwlabel(tempSeg,4);
    
    if max(segment(:)) > 1 %Must be more than one object in segmentation, otherwise fitgmdist will complain
        objInts = zeros(max(segment(:)),1);
        for i = 1:max(segment(:))
            objInts(i) = mean(tempImg(segment(:) == i));
        end
        try
            gmFit = fitgmdist(objInts,2);
            thresh = mean(gmFit.mu);
        catch %An error indicates that there is only one example of one of the populations in your sample; in that case (usually at very low cell numbers), should be safe to use the mean of all intensities as your threshold.
            thresh = mean(objInts);
        end

        remInds = find(objInts < thresh);
        
        for i = 1:size(remInds,1)
            tempSeg(segment == remInds(i)) = 0;
        end
    end
end

%Measure areas of each object, and mark those that are too
%small
se = strel('disk',0);
erodeImg = imerode(tempSeg,se);
RPs = regionprops(erodeImg,'PixelList','Area');
NoCCs = size(RPs);
keepObjsX = [];
keepObjsY = [];
for i = 1:NoCCs(1)
    if RPs(i).Area > segmentParams.Alow
        keepObjsX = [keepObjsX;RPs(i).PixelList(1,1)];
        keepObjsY = [keepObjsY;RPs(i).PixelList(1,2)];
    end
end
tempSeg = bwselect(tempSeg,keepObjsX,keepObjsY,8);

%If recursive watershed is selected, apply watershed algorithm repeatedly with
%decreasing stringency to large objects. Otherwise, remove large objects directly.
if segmentParams.waterRecur
    loopCnt = 1;
    stepRes = 1.15; %Controls how fine the step size of the recursive refinement of the watershed threshold should be.
    
    allAreas = vertcat(RPs.Area);
    tgtObjs = allAreas > segmentParams.Ahigh; %All objects that are currently too big
   
    newThresh = (segmentParams.waterThresh/(stepRes^loopCnt));
    while sum(tgtObjs) > 0 && newThresh > 0.4
        %Apply more stringent watershed to currently too large objects
        for i = 1:size(RPs,1)
            if tgtObjs(i)
                subObj = bwselect(tempSeg,RPs(i).PixelList(1,1),RPs(i).PixelList(1,2));
                dists = -bwdist(~subObj);
                distA = imhmin(dists,newThresh);
                distW = watershed(distA);
                
                tempSeg(and(distW == 0,subObj)) = 0;
            end
        end
        
        %Recalculate area list with re-segmented objects.
        erodeImg = imerode(tempSeg,se);
        RPs = regionprops(erodeImg,'PixelList','Area');
        allAreas = vertcat(RPs.Area);
        tgtObjs = allAreas > segmentParams.Ahigh; %All objects that are currently too big
        
        loopCnt = loopCnt + 1;
        newThresh = (segmentParams.waterThresh/(stepRes^loopCnt));
    end
end
RPs = regionprops(erodeImg,'PixelList','Area');
NoCCs = size(RPs);
keepObjsX = [];
keepObjsY = [];
for i = 1:NoCCs(1)
    if RPs(i).Area < segmentParams.Ahigh
        keepObjsX = [keepObjsX;RPs(i).PixelList(1,1)];
        keepObjsY = [keepObjsY;RPs(i).PixelList(1,2)];
    end
end
tempSeg = bwselect(tempSeg,keepObjsX,keepObjsY,8);

%Do final labelling of each object
segment = bwlabel(tempSeg);

if strcmp(segmentParams.overlay,'Segmentation')
    if sum(segment(:)) > 0 %If you've found at least one segmentation
        imoverlay(filtImg,segment,[],[],'jet2',0.3,axHand);
        
        %Need to interpolate the colormap to ensure you don't get a few
        %objects getting lumped in with the 'background' (they won't show
        %up otherwise).
        jetCmap = colormap('jet');
        jetCmapFull(:,1) = interp(jetCmap(:,1),5);
        jetCmapFull(:,2) = interp(jetCmap(:,2),5);
        jetCmapFull(:,3) = interp(jetCmap(:,3),5);
        jetCmapFull(jetCmapFull < 0) = 0;
        jetCmapFull(jetCmapFull > 1) = 1;
        jetCmapFull(1,:) = [0,0,0];
        colormap(axHand,jetCmapFull)
    end
    axis(axHand,lims);
    return
end
