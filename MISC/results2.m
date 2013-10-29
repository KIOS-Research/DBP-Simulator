function varargout = results2(varargin)
% RESULTS2 MATLAB code for results2.fig
%      RESULTS2, by itself, creates a new RESULTS2 or raises the existing
%      singleton*.
%
%      H = RESULTS2 returns the handle to a new RESULTS2 or the handle to
%      the existing singleton*.
%
%      RESULTS2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RESULTS2.M with the given input arguments.
%
%      RESULTS2('Property','Value',...) creates a new RESULTS2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before results2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to results2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help results2

% Last Modified by GUIDE v2.5 25-Oct-2013 16:23:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @results2_OpeningFcn, ...
                   'gui_OutputFcn',  @results2_OutputFcn, ...
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


% --- Executes just before results2 is made visible.
function results2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to results2 (see VARARGIN)

% Choose default command line output for results2
    handles.output = hObject;

    handles.results=varargin{1}.AverageDemands;
    handles.B=varargin{1}.B;

    str=varargin{2};
    str2=varargin{3};
    set(handles.figure1,'Name',str)
    set(handles.uitable1,'ColumnName',{'Nodes | (ID)',str2});
    for i=1:handles.B.NodeCount
        u(i,1)=handles.B.NodeNameID(i);
        u(i,2)={handles.results(i)};
    end
    set(handles.uitable1,'data',u);

    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes results2 wait for user response (see UIRESUME)
    % uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = results2_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
