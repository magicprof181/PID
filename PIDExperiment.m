function varargout = PIDExperiment(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PIDExperiment_OpeningFcn, ...
                   'gui_OutputFcn',  @PIDExperiment_OutputFcn, ...
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

function PIDExperiment_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for PIDExperiment
handles.output = hObject;
handles.tfdata.num=1;
handles.tfdata.den=[1 6 5 0];
handles.tfdata.t='0:0.01:50';
% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = PIDExperiment_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
varargout{1} = handles.output;



function num_Callback(hObject, eventdata, handles)
num=str2num(get(handles.num,'string'));
handles.tfdata.num=num;
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function num_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function den_Callback(hObject, eventdata, handles)
den=str2num(get(handles.den,'string'));
handles.tfdata.den=den;
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function den_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in gettf.
function gettf_Callback(hObject, eventdata, handles)
System=CreatePlant(handles.tfdata.num,handles.tfdata.den);
handles.tfdata.plant=System;
guidata(hObject,handles);
sys=evalc('System');
set(handles.tf,'string',sys);


% --- Executes on button press in plotnyquist.
function plotnyquist_Callback(hObject, eventdata, handles)
axes(handles.nyquistaxis);
nyquist(handles.tfdata.plant);


% --- Executes on button press in findkc.
function findkc_Callback(hObject, eventdata, handles)
[Kcr,Pm,Wc,Wm]=margin(handles.tfdata.plant);
Pcr=2*pi/Wc;
set(handles.kc,'string',num2str(Kcr));
set(handles.pu,'string',num2str(Pcr));
handles.tfdata.kc=Kcr;
handles.tfdata.pu=Pcr;
guidata(hObject,handles);


% --- Executes on button press in plotziegler.
function plotziegler_Callback(hObject, eventdata, handles)

%PID-Controller
Kppid=handles.tfdata.kc*0.6;
Tipid=handles.tfdata.pu*0.5;
Tdpid=handles.tfdata.pu*0.125;

%Closed Loop transfer function
Wcpid=ZieglerNicholasPID(Kppid,Tipid,Tdpid);
% WcStep = ZieglerNicholasPID(1,Inf,0);

% sysstep = CLS(handles.tfdata.plant,0);
sysStep = tf([1],[1 6 5 0]);

syspid=CLS(handles.tfdata.plant,Wcpid);

zntable=[Kppid Tipid Tdpid ];
set(handles.table,'data',zntable);

%plotting
axes(handles.responseaxis);
t=str2num(handles.tfdata.t);
step(sysStep,syspid,t),
legend('Step Response','PID');


function t_Callback(hObject, eventdata, handles)
t=num2str(get(handles.t,'string'));
handles.tfdata.t=t;
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function t_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over tf.
function tf_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to tf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
