function varargout = GUI_visual(varargin)
% GUI_VISUAL MATLAB code for GUI_visual.fig
%      GUI_VISUAL, by itself, creates a new GUI_VISUAL or raises the existing
%      singleton*.
%
%      H = GUI_VISUAL returns the handle to a new GUI_VISUAL or the handle to
%      the existing singleton*.
%
%      GUI_VISUAL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_VISUAL.M with the given input arguments.
%
%      GUI_VISUAL('Property','Value',...) creates a new GUI_VISUAL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_visual_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_visual_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_visual

% Last Modified by GUIDE v2.5 29-Apr-2013 08:56:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_visual_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_visual_OutputFcn, ...
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


% --- Executes just before GUI_visual is made visible.
function GUI_visual_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output          = hObject;
guidata(hObject, handles);

% UIWAIT makes GUI_visual wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_visual_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;


% --- Executes on selection change in subject.
function subject_Callback(hObject, eventdata, handles)
contents        = cellstr(get(hObject,'String'));
handles.cfg     = eeg_etParams_CEM('sujid',contents{get(hObject,'Value')}); 
handles.cfg.raw         = get(handles.rawdata,'Value');
handles.cfg.eyedata     = get(handles.eyemov,'Value');
handles.cfg.remove_eye  = get(handles.remeye,'Value');
handles.cfg.remove_m    = get(handles.remmuscle,'Value');

% handles.cfg     = eeg_etParams_CEM('expfolder','/home/jpo/trabajo/CEM/','sujid',contents{get(hObject,'Value')});
tec             = load(handles.cfg.masterfile);
handles.exp     = tec.exp;
set(handles.files,'string',handles.exp.tasks_done.filename)
guidata(hObject, handles);


function subject_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in files.
function files_Callback(hObject, eventdata, handles)
contents        = cellstr(get(hObject,'String')); 
handles.task    = get(hObject,'Value'); 
handles.cfg     = eeg_etParams_CEM(handles.cfg,...
                                   'task_id',handles.exp.tasks_done.task_id{handles.task},...
                                   'filename',handles.exp.tasks_done.filename{handles.task},...
                                   'event',[handles.exp.tasks_done.filename{handles.task} '.vmrk']);
cleanfiles      = dir([handles.cfg.analysisfolder 'cleaning/' handles.cfg.sujid]);
indxfiles       = strmatch(handles.cfg.filename,{cleanfiles.name});
set(handles.clean_list,'string',{cleanfiles(indxfiles).name})
guidata(hObject, handles);
clean_list_Callback(handles.clean_list, [], handles)

function files_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in rawdata.
function rawdata_Callback(hObject, eventdata, handles)
handles.cfg.raw = get(hObject,'Value');
set(handles.components,'Value',~handles.cfg.raw)
guidata(hObject, handles);

% --- Executes on button press in components.
function components_Callback(hObject, eventdata, handles)
handles.cfg.raw = ~get(hObject,'Value');
set(handles.rawdata,'Value',handles.cfg.raw)
guidata(hObject, handles);


% --- Executes on button press in eyemov.
function eyemov_Callback(hObject, eventdata, handles)
handles.cfg.eyedata = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on button press in remeye.
function remeye_Callback(hObject, eventdata, handles)
handles.cfg.remove_eye  = get(hObject,'Value');
guidata(hObject, handles);

% --- Executes on button press in remmuscle.
function remmuscle_Callback(hObject, eventdata, handles)
handles.cfg.remove_m  = get(hObject,'Value');
guidata(hObject, handles);

% --- Executes on selection change in clean_list.
function clean_list_Callback(hObject, eventdata, handles)
contents                    = cellstr(get(hObject,'String')) ;
[startIndex, endIndex]      = regexp(contents{get(hObject,'Value')},handles.cfg.filename);
handles.cfg.clean_name      = strtok(contents{get(hObject,'Value')}(endIndex+1:end),'.');
guidata(hObject, handles);
    
function clean_list_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
visual_clean(handles.cfg)
