function varargout = GUI_Bike(varargin)
% GUI_BIKE MATLAB code for GUI_Bike.fig
%      GUI_BIKE, by itself, creates a new GUI_BIKE or raises the existing
%      singleton*.
%
%      H = GUI_BIKE returns the handle to a new GUI_BIKE or the handle to
%      the existing singleton*.
%
%      GUI_BIKE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_BIKE.M with the given input arguments.
%
%      GUI_BIKE('Property','Value',...) creates a new GUI_BIKE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_Bike_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_Bike_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_Bike

% Last Modified by GUIDE v2.5 15-Dec-2015 15:59:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_Bike_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_Bike_OutputFcn, ...
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


% --- Executes just before GUI_Bike is made visible.
function GUI_Bike_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_Bike (see VARARGIN)

% Choose default command line output for GUI_Bike
handles.output = hObject;

   global udp_obj

   %% Stop variables
   handles.udpConnected = 0;
   
   %%Disable buttons
   set(handles.initCalibration,'Enable','off');
   set(handles.initIntervention,'Enable','off');
   set(handles.initCycling,'Enable','off');
   set(handles.endProtocol,'Enable','off');
   set(handles.endCycling,'Enable','off');
   set(handles.endTrial,'Enable','off');
   handles.length = 6;
   
   %% Close all ports
   out = instrfindall();
   if(~isempty(out)) fclose(out); clear out; end;

% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = GUI_Bike_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in udpConnect.
function udpConnect_Callback(hObject, eventdata, handles)
% hObject    handle to udpConnect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
   global udp_obj
   
   %% Check button State
   if(handles.udpConnected == 0)
      %%% UDP Write & Read port Config %%%
      fcn_UDPPortConfig(handles);
      set(hObject,'BackgroundColor', [(9/255) (249/255) (17/255)]);
      %% enable buttons
      set(handles.initCalibration,'Enable','on');
      set(handles.initIntervention,'Enable','on');
      set(handles.initCycling,'Enable','on');
      set(handles.endProtocol,'Enable','on');
      set(handles.endCycling,'Enable','on');
      set(handles.endTrial,'Enable','on');
      handles.udpConnected = 1;
   else
      fclose(udp_obj);
      clear udp_obj
      handles.udpConnected = 0;
      set(hObject,'BackgroundColor', [0.941 0.941 0.941]);
      %% Disable buttons
      set(handles.initCalibration,'Enable','off');
      set(handles.initIntervention,'Enable','off');
      set(handles.initCycling,'Enable','off');
      set(handles.endProtocol,'Enable','off');
      set(handles.endCycling,'Enable','off');
      set(handles.endTrial,'Enable','off');
      fprintf('... UDP port disconnected... [ok]\n');
   end
   
   guidata(hObject, handles);


function text2_Callback(hObject, eventdata, handles)
% hObject    handle to text1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of text1 as text
%        str2double(get(hObject,'String')) returns contents of text1 as a double


% --- Executes during object creation, after setting all properties.
function text1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function UDPsend_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function UDPsend_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in initCalibration.
function initCalibration_Callback(hObject, eventdata, handles)
% hObject    handle to initCalibration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
   global udp_obj
   
   if(handles.udpConnected == 1)
      payload = uint8([10 0 0 0 0 0]);
      fcn_SendUDPMsg(payload);
      clear payload; 
   end
   

% --- Executes on button press in initIntervention.
function initIntervention_Callback(hObject, eventdata, handles)
% hObject    handle to initIntervention (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
   global udp_obj
   
   if(handles.udpConnected == 1)
      payload = uint8([20 0 0 0 0 0]);
      fcn_SendUDPMsg(payload);
      clear payload; 
   end

% --- Executes on button press in initCycling.
function initCycling_Callback(hObject, eventdata, handles)
% hObject    handle to initCycling (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
   global udp_obj
   
   if(handles.udpConnected == 1)
      payload = uint8([40 0 0 0 0 0]);
      fcn_SendUDPMsg(payload);
      clear payload; 
   end

% --- Executes on button press in endProtocol.
function endProtocol_Callback(hObject, eventdata, handles)
% hObject    handle to endProtocol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
   global udp_obj
   
   if(handles.udpConnected == 1)
      payload = uint8([30 0 0 0 0 0]);
      fcn_SendUDPMsg(payload);
      clear payload; 
   end

% --- Executes on button press in endCycling.
function endCycling_Callback(hObject, eventdata, handles)
% hObject    handle to endCycling (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
   global udp_obj
   
   if(handles.udpConnected == 1)
      payload = uint8([50 0 0 0 0 0]);
      fcn_SendUDPMsg(payload);
      clear payload; 
   end

% --- Executes on button press in endTrial.
function endTrial_Callback(hObject, eventdata, handles)
% hObject    handle to endTrial (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
   global udp_obj
   
   if(handles.udpConnected == 1)
      payload = uint8([60 0 0 0 0 0]);
      fcn_SendUDPMsg(payload);
      clear payload; 
   end



function UDPreceive_Callback(hObject, eventdata, handles)
% hObject    handle to UDPreceive (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of UDPreceive as text
%        str2double(get(hObject,'String')) returns contents of UDPreceive as a double


% --- Executes during object creation, after setting all properties.
function UDPreceive_CreateFcn(hObject, eventdata, handles)
% hObject    handle to UDPreceive (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
