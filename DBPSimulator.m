function varargout = DBPSimulator(varargin)
% DBPSIMULATOR MATLAB code for DBPSimulator.fig
%      DBPSIMULATOR, by itself, creates a new DBPSIMULATOR or raises the existing
%      singleton*.
%
%      H = DBPSIMULATOR returns the handle to a new DBPSIMULATOR or the handle to
%      the existing singleton*.
%
%      DBPSIMULATOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DBPSIMULATOR.M with the given input arguments.
%
%      DBPSIMULATOR('Property','Value',...) creates a new DBPSIMULATOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DBPSimulator_OpeningFcn gets callehandles.B.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DBPSimulator_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DBPSimulator

% Last Modified by GUIDE v2.5 25-Oct-2013 13:52:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DBPSimulator_OpeningFcn, ...
                   'gui_OutputFcn',  @DBPSimulator_OutputFcn, ...
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


% --- Executes just before DBPSimulator is made visible.
function DBPSimulator_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DBPSimulator (see VARARGIN)

% Choose default command line output for DBPSimulator
handles.output = hObject;

handles.ZoomIO=1;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DBPSimulator wait for user response (see UIRESUME)
% uiwait(handles.figure1);

box on;axis on;
set(handles.axes1,'Color','w')
set(handles.axes1,'XTick',[])
set(handles.axes1,'YTick',[])

set(handles.simulateTime,'String',72);
set(handles.qualitystep,'String',360);
set(handles.Kb,'String',.4);
set(handles.Kw,'String',.3);

opening(hObject, eventdata, handles)

% --- Outputs from this function are returned to the command line.
function varargout = DBPSimulator_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function opening(hObject, eventdata, handles)
    set(handles.SaveNetwork,'visible','off');
    set(handles.Zoom,'visible','off');
    set(handles.NodesID,'visible','off');
    set(handles.LinksID,'visible','off');
    set(handles.FontsizeENplotText,'visible','off');
    set(handles.FontsizeENplot,'visible','off');
    set(handles.wtitle,'visible','off');
    
%     set(handles.uitoolbar1,'visible','off');
    
% --- Executes on button press in handles.B.LoadInpFile.
function LoadInpFile_Callback(hObject, eventdata, handles)
% hObject    handle to handles.B.LoadInpFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
   [InputFile,PathFile] = uigetfile('NETWORKS\*.inp');

    PathFile = strcat(PathFile,InputFile);
    if InputFile~=0
        if libisloaded('epanet2')
           unloadlibrary('epanet2');
        end
        col = get(handles.LoadInpFile,'backg');  % Get the background color of the figure.
        set(handles.LoadInpFile,'str','LOADING...','backg','w');
        pause(.1);
        
        % Load Input File
        B=epanet(InputFile); %clc;
        handles.B = B;
        if B.errcode~=0 
            s = sprintf('Could not open network ''%s'', please insert the correct filename(*.inp).\n',InputFile); 
            set(handles.LoadText,'String',s);
            set(handles.LoadInpFile,'str','Load Input File','backg',col);
            return
        end

        if exist([pwd,'\RESULTS\','hNodesID.f'])==2
            delete([pwd,'\RESULTS\','hNodesID.f'],'hNodesID','-mat');
        end
        if exist([pwd,'\RESULTS\','hLinksID.f'])==2
            delete([pwd,'\RESULTS\','hLinksID.f'],'hLinksID','-mat');
        end
        
        msg=['>>Load Input File "',InputFile,'" Successful.']; 
        Getmsg=['>>Current version of EPANET:',num2str(B.version)];
        msg=[msg;{Getmsg}];
        save([pwd,'\RESULTS\','ComWinhandles.B.messsages'],'msg','-mat');
        set(handles.LoadText,'Value',length(msg)); 
        set(handles.LoadText,'String',msg);
        
        set(handles.LoadInpFile,'str','Load Input File','backg',col)  % Now reset the button features.
        
        axes(handles.axes1)
        B.plot;    
        box on;axis on;
        set(handles.axes1,'Color','w')
        set(handles.axes1,'XTick',[])
        set(handles.axes1,'YTick',[])
        
        % graphs
        set(handles.SaveNetwork,'visible','on');
        set(handles.Zoom,'visible','on');
        set(handles.NodesID,'visible','on');
        set(handles.LinksID,'visible','on');      
        set(handles.NodesID,'value',0);
        set(handles.LinksID,'value',0);
        
        set(handles.FontsizeENplotText,'visible','on');
        set(handles.FontsizeENplot,'visible','on');    
        set(handles.wtitle,'visible','off');

        handles.pstInit=get(handles.axes1,'position');
        % Update handles structure
        guidata(hObject, handles);
    end
    


% --- Executes on selection change in LoadText.
function LoadText_Callback(hObject, eventdata, handles)
% hObject    handle to LoadText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns LoadText contents as cell array
%        contents{get(hObject,'Value')} returns selected item from LoadText


% --- Executes during object creation, after setting all properties.
function LoadText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LoadText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Zoom.
function Zoom_Callback(hObject, eventdata, handles)
% hObject    handle to Zoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    if handles.ZoomIO==1
        zoom on;
        handles.ZoomIO=0;
        set(handles.Zoom,'String','Reset');
    elseif handles.ZoomIO==0
        zoom off;
        set(handles.Zoom,'String','Zoom');
        handles.ZoomIO=1;
    end
    

    % Update handles structure
    guidata(hObject, handles);


% --- Executes on button press in LinksIhandles.B.
function LinksID_Callback(hObject, eventdata, handles)
% hObject    handle to LinksID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of LinksID
    if exist([pwd,'\RESULTS\','hNodesID.f'])==2
        load([pwd,'\RESULTS\','hNodesID.f'],'hNodesID','-mat');
        delete(hNodesID(:)); hNodesID=[];
        save([pwd,'\RESULTS\','hNodesID.f'],'hNodesID','-mat');    
    end
    if exist([pwd,'\RESULTS\','hLinksID.f'])==2
        load([pwd,'\RESULTS\','hLinksID.f'],'hLinksID','-mat');
        delete(hLinksID(:)); hLinksID=[];
        save([pwd,'\RESULTS\','hLinksID.f'],'hLinksID','-mat');
    end
    
    FontSize = str2num(get(handles.FontsizeENplot,'String'));
    if  ~length(FontSize) || FontSize<0 || FontSize>20
        load([pwd,'\RESULTS\','ComWind.messsages'],'msg','-mat');
        msg=[msg;{'>>Give Font Size(max 20).'}];
        set(handles.LoadText,'String',msg);
        set(handles.LoadText,'Value',length(msg));
        save([pwd,'\RESULTS\','ComWind.messsages'],'msg','-mat');
        return
    end
    
    value=get(handles.LinksID,'Value');
    if value==1
        set(handles.NodesID,'Value',0);
        for i=1:handles.B.LinkCount
            x1=handles.B.NodeCoordinates{1}(handles.B.NodesConnectingLinksIndex(i,1));
            y1=handles.B.NodeCoordinates{2}(handles.B.NodesConnectingLinksIndex(i,1));
            x2=handles.B.NodeCoordinates{1}(handles.B.NodesConnectingLinksIndex(i,2));
            y2=handles.B.NodeCoordinates{2}(handles.B.NodesConnectingLinksIndex(i,2));
            hLinksID(i)=text((x1+x2)/2,(y1+y2)/2,handles.B.LinkNameID(i),'FontSize',FontSize);
        end
        save([pwd,'\RESULTS\','hLinksID.f'],'hLinksID','-mat');
    end
    

% --- Executes on button press in NodesIhandles.B.
function NodesID_Callback(hObject, eventdata, handles)
% hObject    handle to NodesID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of NodesID
    
    if exist([pwd,'\RESULTS\','hNodesID.f'])==2
        load([pwd,'\RESULTS\','hNodesID.f'],'hNodesID','-mat');
        delete(hNodesID(:)); hNodesID=[];
        save([pwd,'\RESULTS\','hNodesID.f'],'hNodesID','-mat');    
    end
    if exist([pwd,'\RESULTS\','hLinksID.f'])==2
        load([pwd,'\RESULTS\','hLinksID.f'],'hLinksID','-mat');
        delete(hLinksID(:)); hLinksID=[];
        save([pwd,'\RESULTS\','hLinksID.f'],'hLinksID','-mat');
    end
    
    FontSize = str2num(get(handles.FontsizeENplot,'String'));
    if  ~length(FontSize) || FontSize<0 || FontSize>20
        load([pwd,'\RESULTS\','ComWind.messsages'],'msg','-mat');
        msg=[msg;{'>>Give Font Size(max 20).'}];
        set(handles.LoadText,'String',msg);
        set(handles.LoadText,'Value',length(msg));
        save([pwd,'\RESULTS\','ComWind.messsages'],'msg','-mat');
        return
    end
    
    value=get(handles.NodesID,'Value');
    if value==1 
        set(handles.LinksID,'Value',0);
        for i=1:handles.B.NodeCount
            hNodesID(i)=text(handles.B.NodeCoordinates{1}(i),handles.B.NodeCoordinates{2}(i),char(handles.B.NodeNameID(i)),'FontSize',FontSize);
        end
        save([pwd,'\RESULTS\','hNodesID.f'],'hNodesID','-mat');
    end
    


function FontsizeENplot_Callback(hObject, eventdata, handles)
% hObject    handle to FontsizeENplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FontsizeENplot as text
%        str2double(get(hObject,'String')) returns contents of FontsizeENplot as a double

    if get(handles.NodesID,'Value');
        NodesID_Callback(hObject, eventdata, handles);
    elseif get(handles.LinksID,'Value');
        LinksID_Callback(hObject, eventdata, handles);
    end
    
% --- Executes during object creation, after setting all properties.
function FontsizeENplot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FontsizeENplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SaveNetwork.
function SaveNetwork_Callback(hObject, eventdata, handles)
% hObject    handle to SaveNetwork (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    set(handles.SaveNetwork,'visible','off');
    set(handles.Zoom,'visible','off');
    set(handles.NodesID,'visible','off');
    set(handles.LinksID,'visible','off');
    set(handles.FontsizeENplotText,'visible','off');
    set(handles.FontsizeENplot,'visible','off');

    f=getframe(handles.axes1);
    imwrite(f.cdata,[handles.B.inputfile(1:end-4),'.bmp'],'bmp');
    figure(1);
    imshow([handles.B.inputfile(1:end-4),'.bmp']);

    % save to pdf and bmp
    print(gcf,'-dpdf',handles.B.inputfile(1:end-4),sprintf('-r%d',150));
    
    % graphs
    set(handles.SaveNetwork,'visible','on');
    set(handles.Zoom,'visible','on');
    set(handles.NodesID,'visible','on');
    set(handles.LinksID,'visible','on');
    set(handles.FontsizeENplotText,'visible','on');
    set(handles.FontsizeENplot,'visible','on');   
    close(1);   

% --- Executes on button press in run.
function run_Callback(hObject, eventdata, handles)
% hObject    handle to run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
col = get(handles.run,'backg'); 
set(handles.run,'str','LOADING...','backg','c') 
pause(.1);

    if libisloaded('epanet2')
       unloadlibrary('epanet2');
       loadlibrary('epanet2','epanet2.h')
    else
        handles.B.epanetLoadLibrary;
    end
    handles.B.LoadInpFile([pwd,'\RESULTS\temp.inp'],[pwd,'\RESULTS\temp.txt'], [pwd,'\RESULTS\temp.out']); 

    simulateTime=str2num(get(handles.simulateTime,'String'));
    qualitystep=str2num(get(handles.qualitystep,'String'));
    Kb=str2num(get(handles.Kb,'String'));
    Kw=str2num(get(handles.Kw,'String'));

    handles.B.setTimeSimulationDuration(simulateTime*3600)%4days
    handles.B.setTimeQualityStep(qualitystep)
    handles.B.setTimeStatisticsType('AVERAGE')

    % Simulate all times
    handles.B.solveCompleteHydraulics
    handles.B.solveCompleteQuality

    handles.B.setQualityType('age','hour')
    handles.B.setLinkBulkReactionCoeff(ones(1,handles.B.LinkCount)*Kb);
    handles.B.setLinkWallReactionCoeff(ones(1,handles.B.LinkCount)*Kw);
    handles.Qmean=[];  
    handles.Qmean=[handles.Qmean; handles.B.getNodeActualQuality];

    bd=find(handles.B.NodeBaseDemands);
    h=figure;
    subplot(2,2,1)
    hist(handles.Qmean(:,bd));
    xlabel('Age(hours)');
    ylabel('Nodes with demands');
    title('Average Water Age'); 
%     title('Average Water Age of last 2 days'); 

    handles.B.setTimeStatisticsType('MAXIMUM')

    % Simulate all times
    handles.B.solveCompleteHydraulics
    handles.B.solveCompleteQuality
    handles.Qmax=[];  
    handles.Qmax=[handles.Qmax; handles.B.getNodeActualQuality];
            
    
    figure(h)
    subplot(2,2,2)
    hist(handles.Qmax(:,bd))
    xlabel('Age(hours)');
    ylabel('Nodes with demands');
    title('Maximum of Water Age'); 
%     title('Maximum of Water Age of last 2 days'); 

    % Update handles structure
    guidata(hObject, handles);

    if libisloaded('epanet2')
       unloadlibrary('epanet2');
       loadlibrary('epanet2','epanet2.h')
    end   
    handles.B.LoadInpFile([pwd,'\RESULTS\temp.inp'],[pwd,'\RESULTS\temp.txt'], [pwd,'\RESULTS\temp.out']); 

    handles.B.setTimeSimulationDuration(simulateTime*3600)%4days
    handles.B.setTimeHydraulicStep(3600)

    % handles.B.setQualityType('age','mg/L')
    handles.B.setLinkBulkReactionCoeff(ones(1,handles.B.LinkCount)*Kb);
    handles.B.setLinkWallReactionCoeff(ones(1,handles.B.LinkCount)*Kw);

    s=handles.B.getComputedHydraulicTimeSeries;

    bd=find(handles.B.NodeBaseDemands);

    figure(h)
    subplot(2,2,3);
    plot(handles.Qmean(:,bd),sum(s.Demand(:,bd)),'x');
    xlabel('Average age(hours)');
    ylabel('Daily volume total(m^3)');
    % title('Average Water Age of last 2 days'); 

    figure(h)
    subplot(2,2,4);
    plot(handles.Qmax(:,bd),sum(s.Demand(:,bd)),'x');
    xlabel('Maximum age(hours)');
    ylabel('Daily volume total(m^3)');
    % title('Average Water Age of last 2 days'); 

    % Update handles structure
    guidata(hObject, handles);

    load([pwd,'\RESULTS\','ComWinhandles.B.messsages'],'msg','-mat');
    msg=[msg;{'>> Run Selected'}];
    save([pwd,'\RESULTS\','ComWinhandles.B.messsages'],'msg','-mat');
    set(handles.LoadText,'Value',length(msg)); 
    set(handles.LoadText,'String',msg);

set(handles.run,'str','Run','backg',col);

function simulateTime_Callback(hObject, eventdata, handles)
% hObject    handle to simulateTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of simulateTime as text
%        str2double(get(hObject,'String')) returns contents of simulateTime as a double


% --- Executes during object creation, after setting all properties.
function simulateTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to simulateTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function qualitystep_Callback(hObject, eventdata, handles)
% hObject    handle to qualitystep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of qualitystep as text
%        str2double(get(hObject,'String')) returns contents of qualitystep as a double


% --- Executes during object creation, after setting all properties.
function qualitystep_CreateFcn(hObject, eventdata, handles)
% hObject    handle to qualitystep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Kb_Callback(hObject, eventdata, handles)
% hObject    handle to Kb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Kb as text
%        str2double(get(hObject,'String')) returns contents of Kb as a double


% --- Executes during object creation, after setting all properties.
function Kb_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Kb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Kw_Callback(hObject, eventdata, handles)
% hObject    handle to Kw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Kw as text
%        str2double(get(hObject,'String')) returns contents of Kw as a double


% --- Executes during object creation, after setting all properties.
function Kw_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Kw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in waterage.
function waterage_Callback(hObject, eventdata, handles)
% hObject    handle to waterage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
col = get(handles.waterage,'backg'); 
set(handles.waterage,'str','LOADING...','backg','c') 
pause(.1);

    if libisloaded('epanet2')
       unloadlibrary('epanet2');
       loadlibrary('epanet2','epanet2.h')
    else
        handles.B.epanetLoadLibrary;
    end
    handles.B.LoadInpFile([pwd,'\RESULTS\temp.inp'],[pwd,'\RESULTS\temp.txt'], [pwd,'\RESULTS\temp.out']); 

    simulateTime=str2num(get(handles.simulateTime,'String'));
    qualitystep=str2num(get(handles.qualitystep,'String'));
    Kb=str2num(get(handles.Kb,'String'));
    Kw=str2num(get(handles.Kw,'String'));

    handles.B.setTimeSimulationDuration(simulateTime*3600)%4days
    handles.B.setTimeQualityStep(qualitystep)
    handles.B.setTimeStatisticsType('AVERAGE')

    % Simulate all times
    handles.B.solveCompleteHydraulics
    handles.B.solveCompleteQuality

    handles.B.setQualityType('age','hour')
    handles.B.setLinkBulkReactionCoeff(ones(1,handles.B.LinkCount)*Kb);
    handles.B.setLinkWallReactionCoeff(ones(1,handles.B.LinkCount)*Kw);

    WaterAge=[];  
    WaterAge=[WaterAge; handles.B.getNodeActualQuality];

    % Colormaps
    handles.B.plot
    % Add colorbar legend
    newmap = jet(5);
    newmap(1,:)=[0 0 1];
    newmap(2,:)=[0 1 1]; 
    newmap(3,:)=[0 1 0];
    newmap(4,:)=[1 .5 0];
    newmap(5,:)=[1 0 0];
    colormap(newmap);
    
    handles.cbar = colorbar('horiz');
    xtick = [1: floor(simulateTime/4) : simulateTime simulateTime];
    set(handles.cbar,'XTick',[1,2,3,4,5]);
    set(handles.cbar,'FontName','Helvetica','XTickLabel',{'     Low','Guarded','Elevated','High','Very-High'})

    for i=1:handles.B.NodeCount
        if WaterAge(:,i)<xtick(2)
            C2='b'; C1='b';MarkerSize=14;
        elseif xtick(2)<WaterAge(:,i) && WaterAge(:,i)<xtick(3)
            C2='c'; C1='c';MarkerSize=15;
        elseif xtick(3)<WaterAge(:,i) && WaterAge(:,i)<xtick(4)
            C2='g'; C1='g';MarkerSize=16;
        elseif xtick(4)<WaterAge(:,i) && WaterAge(:,i)<xtick(5)
            C2=[1 .5 0]; C1=[1 .5 0];MarkerSize=17;
        elseif xtick(5)<WaterAge(:,i)
            C2='r'; C1='r';MarkerSize=18;
        end
        plot(handles.axes1,handles.B.NodeCoordinates{1}(i),handles.B.NodeCoordinates{2}(i),'o','LineWidth',2,'MarkerEdgeColor',C1,...
        'MarkerFaceColor',C2,'MarkerSize',MarkerSize);
    end
    
    delete(legend);
    axis on
    set(handles.axes1,'Color','w')
    set(handles.axes1,'XTick',[])
    set(handles.axes1,'xtick',[])
    set(handles.wtitle,'visible','on');
    set(handles.wtitle,'String','Average Water Age');
    

    set(handles.SaveNetwork,'visible','off');
    set(handles.Zoom,'visible','off');
    set(handles.NodesID,'visible','off');
    set(handles.LinksID,'visible','off');
    set(handles.FontsizeENplotText,'visible','off');
    set(handles.FontsizeENplot,'visible','off');
        
    load([pwd,'\RESULTS\','ComWinhandles.B.messsages'],'msg','-mat');
    msg=[msg;{'>> Average Water Age'}];
    save([pwd,'\RESULTS\','ComWinhandles.B.messsages'],'msg','-mat');
    set(handles.LoadText,'Value',length(msg)); 
    set(handles.LoadText,'String',msg);
    
    pst=[50.2000000000001 6.1025641025641 120.2 39.974358974359];
    set(handles.axes1,'position',pst);
    % Update handles structure
    guidata(hObject, handles);
set(handles.waterage,'str','Average Water Age','backg',col);

    % --- Executes on button press in demands.
function demands_Callback(hObject, eventdata, handles)
% hObject    handle to demands (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
col = get(handles.demands,'backg'); 
set(handles.demands,'str','LOADING...','backg','c') 
pause(.1);

    if libisloaded('epanet2')
       unloadlibrary('epanet2');
       loadlibrary('epanet2','epanet2.h')
    else
        handles.B.epanetLoadLibrary;
    end
    handles.B.LoadInpFile([pwd,'\RESULTS\temp.inp'],[pwd,'\RESULTS\temp.txt'], [pwd,'\RESULTS\temp.out']);

    simulateTime=str2num(get(handles.simulateTime,'String'));
    qualitystep=str2num(get(handles.qualitystep,'String'));
    Kb=str2num(get(handles.Kb,'String'));
    Kw=str2num(get(handles.Kw,'String'));

    handles.B.setTimeSimulationDuration(simulateTime*3600)%4days
    handles.B.setTimeQualityStep(qualitystep)
    handles.B.setTimeStatisticsType('AVERAGE')

    handles.B.setLinkBulkReactionCoeff(ones(1,handles.B.LinkCount)*Kb);
    handles.B.setLinkWallReactionCoeff(ones(1,handles.B.LinkCount)*Kw);

    % Simulate all times
    handles.B.solveCompleteHydraulics
    handles.B.solveCompleteQuality

    AverageDemands=[];
    AverageDemands=[AverageDemands; handles.B.getNodeActualDemand];

    % Colormaps
    handles.B.plot
    % Add colorbar legend
    newmap = jet(5);
    newmap(1,:)=[0 0 1];
    newmap(2,:)=[0 1 1]; 
    newmap(3,:)=[0 1 0];
    newmap(4,:)=[1 .5 0];
    newmap(5,:)=[1 0 0];
    colormap(newmap);
    
% % %     AverageDemands = sum(D);
    
    handles.cbar = colorbar('horiz');
    xtick = [1: floor(simulateTime/4) : simulateTime simulateTime];
    set(handles.cbar,'XTick',[1,2,3,4,5]);
    set(handles.cbar,'FontName','Helvetica','XTickLabel',{'     Low','Guarded','Elevated','High','Very-High'})

    for i=1:handles.B.NodeCount
        if AverageDemands(:,i)<xtick(2)
            C2='b'; C1='b';MarkerSize=14;
        elseif xtick(2)<AverageDemands(:,i) && AverageDemands(:,i)<xtick(3)
            C2='c'; C1='c';MarkerSize=15;
        elseif xtick(3)<AverageDemands(:,i) && AverageDemands(:,i)<xtick(4)
            C2='g'; C1='g';MarkerSize=16;
        elseif xtick(4)<AverageDemands(:,i) && AverageDemands(:,i)<xtick(5)
            C2=[1 .5 0]; C1=[1 .5 0];MarkerSize=17;
        elseif xtick(5)<AverageDemands(:,i)
            C2='r'; C1='r';MarkerSize=18;
        end
        plot(handles.axes1,handles.B.NodeCoordinates{1}(i),handles.B.NodeCoordinates{2}(i),'o','LineWidth',2,'MarkerEdgeColor',C1,...
        'MarkerFaceColor',C2,'MarkerSize',MarkerSize);
    end
    
    delete(legend);
    axis on
    set(handles.axes1,'Color','w')
    set(handles.axes1,'XTick',[])
    set(handles.axes1,'xtick',[])
    set(handles.wtitle,'visible','on');
    set(handles.wtitle,'String','Average Demand');
    
    set(handles.SaveNetwork,'visible','off');
    set(handles.Zoom,'visible','off');
    set(handles.NodesID,'visible','off');
    set(handles.LinksID,'visible','off');
    set(handles.FontsizeENplotText,'visible','off');
    set(handles.FontsizeENplot,'visible','off');
    
    load([pwd,'\RESULTS\','ComWinhandles.B.messsages'],'msg','-mat');
    msg=[msg;{'>> Average Demand Selected'}];
    save([pwd,'\RESULTS\','ComWinhandles.B.messsages'],'msg','-mat');
    set(handles.LoadText,'Value',length(msg)); 
    set(handles.LoadText,'String',msg);
    
    pst=[50.2000000000001 6.1025641025641 120.2 39.974358974359];
    set(handles.axes1,'position',pst);
    % Update handles structure
    guidata(hObject, handles);
    
set(handles.demands,'str','Average Demand','backg',col);

% --- Executes on button press in Reset.
function Reset_Callback(hObject, eventdata, handles)
% hObject    handle to Reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    col = get(handles.Reset,'backg'); 
    set(handles.Reset,'str','LOADING...','backg','c') 
    pause(.1);
       
    if libisloaded('epanet2')
       unloadlibrary('epanet2');
       loadlibrary('epanet2','epanet2.h')
    else
        handles.B.epanetLoadLibrary;
    end
    handles.B.LoadInpFile([pwd,'\RESULTS\temp.inp'],[pwd,'\RESULTS\temp.txt'], [pwd,'\RESULTS\temp.out']);   
    % Input Files
    set(handles.axes1,'position',handles.pstInit);

%     handles.B=epanet(handles.B.inputfile); 
    handles.B.plot;
    axis on
    set(handles.axes1,'Color','w')
    set(handles.axes1,'XTick',[])
    set(handles.axes1,'xtick',[])
    set(handles.wtitle,'visible','off');

    set(handles.SaveNetwork,'visible','on');
    set(handles.Zoom,'visible','on');
    set(handles.NodesID,'visible','on');
    set(handles.LinksID,'visible','on');      
    set(handles.NodesID,'value',0);
    set(handles.LinksID,'value',0);

    set(handles.FontsizeENplotText,'visible','on');
    set(handles.FontsizeENplot,'visible','on');    
    set(handles.wtitle,'visible','off');
        
    load([pwd,'\RESULTS\','ComWinhandles.B.messsages'],'msg','-mat');
    msg=[msg;{'>> Reset Selected'}];
    save([pwd,'\RESULTS\','ComWinhandles.B.messsages'],'msg','-mat');
    set(handles.LoadText,'Value',length(msg)); 
    set(handles.LoadText,'String',msg);
    
    % Update handles structure
    guidata(hObject, handles);

    set(handles.Reset,'str','Reset','backg',col);

% --- Executes on button press in nodesdemands.
function nodesdemands_Callback(hObject, eventdata, handles)
% hObject    handle to nodesdemands (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

col = get(handles.nodesdemands,'backg'); 
set(handles.nodesdemands,'str','LOADING...','backg','c') 
pause(.1);

    if libisloaded('epanet2')
       unloadlibrary('epanet2');
       loadlibrary('epanet2','epanet2.h');
    else
        handles.B.epanetLoadLibrary;
    end
    handles.B.LoadInpFile([pwd,'\RESULTS\temp.inp'],[pwd,'\RESULTS\temp.txt'], [pwd,'\RESULTS\temp.out']);

    bd=find(handles.B.NodeBaseDemands);

    handles.B.plot;
    axis on
    set(handles.axes1,'Color','w')
    set(handles.axes1,'XTick',[])
    set(handles.axes1,'xtick',[])
%     for i=1:handles.B.NodeCount
%         if i<handles.B.NodeJunctionsCount+1
%             plot(handles.axes1,handles.B.NodeCoordinates{1}(i),handles.B.NodeCoordinates{2}(i),'o','LineWidth',2,'MarkerEdgeColor','b',...
%             'MarkerFaceColor','b','MarkerSize',3);
%         elseif i>handles.B.NodeJunctionsCount && i<handles.B.NodeReservoirCount+1
%             plot(x,y,'s','LineWidth',3,'MarkerEdgeColor','g',...
%             'MarkerFaceColor','g','MarkerSize',13);
%         elseif i<handles.B.NodeTankCount+1 && i>handles.B.NodeReservoirCount
%                     plot(x,y,'p','LineWidth',3,'MarkerEdgeColor','c',...
%             'MarkerFaceColor','c','MarkerSize',16);
%         
%         end
%     end
    for i=bd
        plot(handles.axes1,handles.B.NodeCoordinates{1}(i),handles.B.NodeCoordinates{2}(i),'o','LineWidth',2,'MarkerEdgeColor','b',...
    'MarkerFaceColor','b','MarkerSize',15);
    end

    set(handles.wtitle,'visible','on');
    set(handles.wtitle,'String','Nodes with Demand');
    
    load([pwd,'\RESULTS\','ComWinhandles.B.messsages'],'msg','-mat');
    msg=[msg;{'>> Nodes with Demand Selected'}];
    save([pwd,'\RESULTS\','ComWinhandles.B.messsages'],'msg','-mat');
    set(handles.LoadText,'Value',length(msg)); 
    set(handles.LoadText,'String',msg);
        
    set(handles.axes1,'position',handles.pstInit);
    
set(handles.nodesdemands,'str','Nodes With Demand','backg',col);


% --- Executes on button press in Map.
function Map_Callback(hObject, eventdata, handles)
% hObject    handle to Map (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

col = get(handles.Map,'backg'); 
set(handles.Map,'str','LOADING...','backg','c') 
pause(.1);
       
hold on;
plot_google_map;
% [xmax,~]=max(handles.B.NodeCoordinates{1});
% [xmin,~]=min(handles.B.NodeCoordinates{1});
% [ymax,~]=max(handles.B.NodeCoordinates{2});
% [ymin,~]=min(handles.B.NodeCoordinates{2});
% 
% if ~isnan(ymax)
%     if ymax==ymin
%         xlim([xmin-((xmax-xmin)*.1),xmax+((xmax-xmin)*.1)]);
%         ylim([ymin-.1,ymax+.1]);
%     elseif xmax==xmin
%         xlim([xmin-.1,xmax+.1]);
%         ylim([ymin-(ymax-ymin)*.1,ymax+(ymax-ymin)*.1]);
%     else
%         xlim([xmin-((xmax-xmin)*.1),xmax+((xmax-xmin)*.1)]);
%         ylim([ymin-(ymax-ymin)*.1,ymax+(ymax-ymin)*.1]);
%     end
% else
%     warning('Undefined coordinates.');
% end

box on;

set(handles.Map,'str','Map','backg',col);
