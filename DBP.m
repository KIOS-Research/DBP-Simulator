function DBP()

    fclose all;close all;
    clc;
    clear all;
    clear class;
    
    % Load File 
    name='net2-cl2'; 
    MSXname='templateThms';
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
    
    %% AGE
    % EPANET
    % Quality type    
    nn=d.getOptionsQualityTolerance;
    d.setQualityType('AGE','hour');
    d.setOptionsQualityTolerance(nn);
    % Initial quality of each node
    v=d.getNodeInitialQuality;
    v(1:end)=0;
    d.setNodeInitialQuality(v)
    % Sources
    values = d.getNodeSourceQuality;
    values(1:end)=0;
    d.setNodeSourceQuality(values)
    % Bulk& Wall Coeff
    d.setLinkBulkReactionCoeff(ones(1,d.LinkCount)*Kb);
    values(d.NodeTankIndex)=Kb;
    if d.NodeTankIndex
        d.setNodeTankBulkReactionCoeff(values) 
    end
    d.setLinkWallReactionCoeff(ones(1,d.LinkCount)*Kw);
    % Simulate all times
    EpanetResultsWaterAge=d.getComputedQualityTimeSeries;
    d.solveCompleteHydraulics;
    d.solveCompleteQuality;
    EpanetAverageWaterAge=mean(EpanetResultsWaterAge.Quality); 
        
    
    %% CHLORINE & CHLOROFORM
    Kb=-0.3;
    Kw=-1;
    species=.1;
    % Chlorine
    initqual=0.5;
    statistic='NONE';
    
    % Chloroform
    DF_CHCL3=57.87;
    initqualDF_CHCL3=29;
  
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
    values(ind(1))=.81;%values(1)=0.8;%
    d.setNodeSourceQuality(values)

    % Bulk& Wall Coeff
    d.setLinkBulkReactionCoeff(ones(1,d.LinkCount)*Kb);
    values(d.NodeTankIndex)=Kb;
    if d.NodeTankIndex
        d.setNodeTankBulkReactionCoeff(values) 
    end
    d.setLinkWallReactionCoeff(ones(1,d.LinkCount)*Kw);

    d.saveInputFile([pwd,'\NETWORKS\',[name,'TemplateThms.inp']]);

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
    indexCL2=d.getMsxSpeciesIndex('CL2');
    indexCHCL3=d.getMsxSpeciesIndex('CHCL3');
    indexAGE=d.getMsxSpeciesIndex('AGE');
    for i=1:d.NodeCount
        for u=1:d.MsxSpeciesCount
            if u==indexCL2
                msxVn{i}(u)=initqual;
            elseif u==indexCHCL3
                msxVn{i}(u)=initqualDF_CHCL3;
            end
        end
    end
    % Select Reservoir/Tank where will placed the CL2
    nodeIndex=d.NodeReservoirIndex;
    if length(nodeIndex)
        msxVn{nodeIndex(1)}(indexCL2)=species; % 1 mg/L in Reservoir
        d.setMsxNodeInitqualValue(msxVn)
    else  
        nodeIndex=d.NodeTankIndex;
        msxVn{nodeIndex(1)}(indexCL2)=species; % 1 mg/L in Tank
        d.setMsxNodeInitqualValue(msxVn)
    end
    
    % Sources
    typeCL2=0;  
    levelCL2=.81;
    patCL2=0;
    typeDF_CHCL3=0;  
    levelDF_CHCL3=29;
    patDF_CHCL3=0;
    d.setMsxSources(1,indexCL2,typeCL2,levelCL2,patCL2) 
    d.setMsxSources(1,indexCHCL3,typeDF_CHCL3,levelDF_CHCL3,patDF_CHCL3) 

    % Patterns
    %     d.MsxAddPattern('PAT1',ones(1,simulateTime));

    % Bulk& Wall Coeff
    IndexReactKb=d.getMsxParametersIndex('Kb');
    IndexReactKw=d.getMsxParametersIndex('Kw');
    IndexReactDF_CHCL3=d.getMsxParametersIndex('DF_CHCL3');
    val=d.getMsxParametersPipesValue{:};
    val(IndexReactKb)=-Kb;
    val(IndexReactKw)=-Kw;
    val(IndexReactDF_CHCL3)=DF_CHCL3;
    for i=1:d.LinkCount
        d.setMsxParametersPipesValue(i,val)
    end
    for i=1:d.LinkCount
        d.setMsxParametersTanksValue(i,val)  
    end
    
    d.MsxSaveFile([pwd,'\NETWORKS\',[name,'TemplateThms.msx']]);% open([name,'TemplateThms.msx'])
    d.MsxUnload
    d.unload



    %% Load New files
%     name='net2-cl2'; 
    d=epanet([name,'TemplateThms.inp']);%d.plot('nodes','yes');
    d.msx([name,'TemplateThms.msx']);
    
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
    for i=1:d.NodeCount
        for u=1:d.MsxSpeciesCount
            if u==indexCL2
                nnCL2(i)=nI{i}(u); 
            elseif u==indexCHCL3
                nnCHCL3(i)=nI{i}(u); 
            elseif u==indexAGE
                nnAGE(i)=nI{i}(u); 
            end
        end
    end
    nS=d.getMsxSourceLevel;
    if d.NodeReservoirCount
        for i=d.NodeReservoirIndex
            for u=1:d.MsxSpeciesCount
                if u==indexCL2
                    nnCL2(i)=nS{i}(u);
                elseif u==indexCHCL3
                    nnCHCL3(i)=nS{i}(u);
                elseif u==indexAGE
                    nnAGE(i)=nS{i}(u); 
                end
            end
        end
    end

    %% Plots 
    for i=1:d.NodeCount
        EpanetAverageCL2(i)=mean(EpanetResults.Quality(:,i));
        MsxResults.CL2{i}=[nnCL2(i); MsxResults.CL2{i}(1:end)];
        MsxResults.CHCL3{i}=[nnCHCL3(i); MsxResults.CHCL3{i}(1:end)];
        MsxResults.AGE{i}=[nnAGE(i); MsxResults.AGE{i}(1:end)];
        MsxResultsAverageCL2(i)=mean(MsxResults.CL2{i}(1:end));
        MsxResultsAverageCHCL3(i)=mean(MsxResults.CHCL3{i}(1:end));
        MsxResultsAverageAGE(i)=mean(MsxResults.AGE{i}(1:end));
    end
    t=[0 (s.Time/3600)']';
    
    % Average plots
    % AGE 
    figure;
    h(:,1)=plot(1:d.NodeCount,EpanetAverageWaterAge,'bx');
    hold on;
    h(:,2)=plot(1:d.NodeCount,(MsxResultsAverageAGE*24),'ro'); 
    legend(h,{'EPANET','MSX'});
    title('Average AGE');
    ylabel('AGE(hours)');
    xlabel('Nodes(index)');
    
    % CL2
    figure;
    hh(:,1)=plot(1:d.NodeCount,EpanetAverageCL2,'bx');
    hold on;
    hh(:,2)=plot(1:d.NodeCount,(MsxResultsAverageCL2),'ro'); 
    legend(hh,{'EPANET','MSX'});
    title('Average Chlorine');
    ylabel('Chlorine(mg/L)');
    xlabel('Nodes(index)');
    % CHCL3
    figure;
    h2=plot(1:d.NodeCount,(MsxResultsAverageCHCL3),'ro'); 
    legend(h2,{'MSX'});
    title('Average Chloroform');
    ylabel('CHCL3(ug/L)');
    xlabel('Nodes(index)');    
    
    % CL2 CHCL3
    figure;
    [haxes,hline1,hline2] = plotyy(1:d.NodeCount,MsxResultsAverageCHCL3,1:d.NodeCount,MsxResultsAverageCL2,'plot','plot');
    axes(haxes(1))
    ylabel('Chloroform')
    axes(haxes(2))
    ylabel('Chlorine')
    set(hline2,'LineStyle','o')
    set(hline1,'LineStyle','x')
    title('Average');

    % Results for node index 2
    nodeIndex=2;
    % Chlorine with EPANET and MSX
    figure;
    h(:,1)=plot(EpanetResults.Time/3600,EpanetResults.Quality(:,nodeIndex),'b');
    hold on;
    h(:,2)=plot(t,(MsxResults.CL2{nodeIndex}),'r'); 
    h(:,3)=plot(t,(MsxResults.CHCL3{nodeIndex}),'g'); 
    legend(h,{'EPANET-CL2','MSX-CL2','MSX-CHCL3'});
    title('Node index 2');
    ylabel('Chlorine(mg/L)');
    xlabel('Time(hrs)');
    
    % Chlorine and Chloroform with MSX
    figure;
    [haxes,hline1,hline2] = plotyy(t,MsxResults.CHCL3{nodeIndex},t,MsxResults.CL2{nodeIndex},'plot','plot');
    axes(haxes(1))
    ylabel('Chloroform')
    axes(haxes(2))
    ylabel('Chlorine')
    set(hline2,'LineStyle','--')
    title('Node index 2');
    
    % AGE with EPANET and MSX
    figure;
    H(:,1)=plot(EpanetResults.Time/3600,EpanetResultsWaterAge.Quality(:,nodeIndex),'b');
    hold on;
    H(:,2)=plot(t,(MsxResults.AGE{nodeIndex}*24),'r'); 
    legend(H,{'EPANET','MSX'});
    title('Node index 2');
    ylabel('AGE(hrs)');
    xlabel('Time(hrs)');
    
    % Delete s files 
    DeleteSfiles;
    rmpath(genpath(pwd));
    
end
