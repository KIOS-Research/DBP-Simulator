function Simulate()
    fclose all;close all;
    clc;
    clear all;
    clear class;
    
    % Load File 
    name='net2-cl2'; 
    MSXname='template';
    d=epanet([name,'.inp']);%d.plot('nodes','yes');
    d.msx([MSXname,'.msx']);
    
    % Initialization the parameters 
    simulateTime=55;%hours
    qualitystep=300;%sec % Standard, because the timestep in template msx is 300;
    hydstep=3600;%sec
    patternstep=3600;%sec
    patternstart=0;%sec
    reportstep=3600;%sec
    reportstart=0;%sec
    
    Kb=-0.3;
    Kw=-1;
    species=.1;
    initqual=0.5;
    statistic='NONE';
    
  
    %% EPANET Settings
    % Simulation time
    d.setTimeSimulationDuration(simulateTime*3600); 
    d.setTimeQualityStep(qualitystep);
    d.setTimeHydraulicStep(hydstep);
    d.setTimeStatisticsType(statistic);
    d.setTimePatternStep(patternstep)
    d.setTimePatternStart(patternstart)
    d.setTimeReportingStep(reportstep)
    d.setTimeReportingStart(reportstart)
    
    % Quality type    
    nn=d.getOptionsQualityTolerance;
    d.setQualityType('CHEM','mg/L');
    d.setOptionsQualityTolerance(nn);
    
    % Initial quality of each node
    v=d.getNodeInitialQuality;
    v(1:end)=initqual;
    % Select Reservoir/Tank where will placed the species
    ind=d.NodeReservoirIndex;
    ind(1)=1;%net2, ind(1)
    if length(ind)
        v(ind(1))=species; % 1 mg/L in Reservoir
        d.setNodeInitialQuality(v)
    else  
        ind=d.NodeTankIndex;
        v(ind(1))=species; % 1 mg/L in Tank
        d.setNodeInitialQuality(v)
    end
   
    % Sources
    values = d.getNodeSourceQuality;
    values(1:end)=0;
    values(ind(1))=.8;%values(1)=0.8;%
    d.setNodeSourceQuality(values)

    % Bulk& Wall Coeff
    d.setLinkBulkReactionCoeff(ones(1,d.LinkCount)*Kb);
    values(d.NodeTankIndex)=Kb;
    if d.NodeTankIndex
        d.setNodeTankBulkReactionCoeff(values) 
    end
    d.setLinkWallReactionCoeff(ones(1,d.LinkCount)*Kw);

    d.saveInputFile([pwd,'\NETWORKS\',[name,'Template.inp']]);

    %% MSX Settings

    % Initial quality of each node and link
    msxVl=d.getMsxLinkInitqualValue;
    for i=1:d.LinkCount
        for u=1:d.MsxSpeciesCount
            msxVl{i,u}=0;
        end
    end
    d.setMsxLinkInitqualValue(msxVl);
    msxVn=d.getMsxNodeInitqualValue;
    for i=1:d.NodeCount
        for u=1:d.MsxSpeciesCount
            msxVn{i,u}=initqual;
        end
    end
    % Select Reservoir/Tank where will placed the CL2
    SpeciesNameID=d.getMsxSpeciesNameID;
    specieIndex=strcmpi(SpeciesNameID,'CL2');
    specieIndex=find(specieIndex,1);
    nodeIndex=d.NodeReservoirIndex;
    if length(nodeIndex)
        msxVn{nodeIndex(1)}(specieIndex)=species; % 1 mg/L in Reservoir
        d.setMsxNodeInitqualValue(msxVn)
    else  
        nodeIndex=d.NodeTankIndex;
        msxVn{nodeIndex(1)}(specieIndex)=species; % 1 mg/L in Tank
        d.setMsxNodeInitqualValue(msxVn)
    end
    
    % Sources
    type=0; % CONCE
    level=.8;
    pat=0;
    nodeIndex(1)=1;%net2;nodeIndex(1);
    d.setMsxSources(nodeIndex(1),specieIndex,type,level,pat) %1

    % Patterns
    %     d.MsxAddPattern('PAT1',ones(1,simulateTime));

    % Bulk& Wall Coeff
    reactP=d.getMsxParametersNameID;
    ss=strcmpi('Kb',reactP);
    ss1=strcmpi('Kw',reactP);
    IndexReactKb=find(ss,1);
    IndexReactKw=find(ss1,1);
    val=d.getMsxParametersPipesValue{:};
    val(IndexReactKb)=-Kb;
    val(IndexReactKw)=-Kw;
    for i=1:d.LinkCount
        d.setMsxParametersPipesValue(i,val)
    end
    for i=1:d.LinkCount
        d.setMsxParametersTanksValue(i,val)  
    end
    
    d.MsxSaveFile([pwd,'\NETWORKS\',[name,'Template.msx']]);
    d.MsxUnload
    d.unload



    %% Load New files
%     name='net2-cl2'; 
    d=epanet([name,'Template.inp']);%d.plot('nodes','yes');
    d.msx([name,'Template.msx']);
    
    %% Solve
    % EPANET
    EpanetResults=d.getComputedQualityTimeSeries;

    % MSX
    s=d.getMsxComputedQualityNode;
    SpCnt=d.getMsxSpeciesCount;
    NodCnt=d.getNodeCount;
    MsxResults=struct();
    MsxResultsAverage=struct();
    SpeciesNameID=d.getMsxSpeciesNameID;
    for i=1:NodCnt
        for u=1:SpCnt
            MsxResults.(char(SpeciesNameID(u))){i}=s.Quality{u,i};
            MsxResultsAverage.(char(SpeciesNameID(u)))(i)=mean(s.Quality{u,i});
        end
    end
    
    % HOUR 0
    nI=d.getMsxNodeInitqualValue;
    bug=find(s.Quality{2}==0);
    for i=1:d.NodeCount
        nn(i)=nI{i}%(5)%Ni{i}
    end
    nS=d.getMsxSourceLevel;
    if d.NodeReservoirCount
        for i=d.NodeReservoirIndex
            nn(i)=nS{i}%(5)+nn(i)
        end
    end

    ff=EpanetResults.Quality(1,2)-EpanetResults.Quality(2,2);
    
    for i=1:length(bug)
        MsxResults.CL2{2}(i)=nI{2};
        nI{2}=nI{2}-ff;
        if nI{2}<0
            nI{2}=nI{2}+ff;
        end
    end
    %% Plots 
    t=[0 (s.Time/3600)']';
    figure;
    h(:,1)=plot(EpanetResults.Time/3600,EpanetResults.Quality(:,2),'b');
    hold on;
    MsxResults.CL2{2}=[nn(2); MsxResults.CL2{2}(1:end)];
    h(:,2)=plot(t,(MsxResults.CL2{2}),'r');% EPI 24 BECAUSE RATE UNITS DAY
    legend(h,{'EPANET','MSX'});
    title('Chlorine-NODE 2');
    ylabel('Chlorine(mg/L)');
    xlabel('Time(hrs)');
    
    % Delete s files 
    DeleteSfiles;
    rmpath(genpath(pwd));
end
