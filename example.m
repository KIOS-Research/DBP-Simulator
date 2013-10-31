function [EpanetAverageWaterAge,EpanetAverageChlorine,MsxResults,MsxResultsAverage,EpanetAllChlorine,EpanetAllWaterAge] = example()
    % Clear all
    fclose all;close all;
    clc;
    clear all;
    clear class;
    format long g;
    
    % Load File 
%     name='example';
%     name='Net2_Rossman2000';
    name='Net1_Rossman2000';
%     nam='example';
    d=epanet([name,'.inp']);
    d.msx([name,'.msx'])

    % EPANET - Finding average water age
    % Init
    simulateTime=24;
    qualitystep=3600;
    Kb=-.5;
    Kw=0;

    % quality type
    mm=d.getOptionsQualityTolerance; %0.01
    d.setQualityType('age','hour');
    d.getOptionsQualityTolerance 
    d.setOptionsQualityTolerance(mm);
    
    % init quality
    v=d.getNodeInitialQuality;
    values=v*0;
    d.setNodeInitialQuality(values)

    % sources
    values = d.getNodeSourceQuality;
    values(1:end)=0;
    d.setNodeSourceQuality(values)
    d.getNodeSourceQuality

% % %     % patterns zero all
% % %     vls = d.getNodeDemandPatternIndex;
% % %     vls(1:end)=0;
% % %     d.setNodeDemandPatternIndex(vls)
% % %     d.getNodeDemandPatternIndex

    % simulation time
    d.setTimeSimulationDuration(simulateTime*3600); 
    d.setTimeQualityStep(qualitystep);
    d.getTimeQualityStep
    d.setTimeStatisticsType('AVERAGE');
    d.getTimePatternStep
    d.setTimePatternStep(7200)
    d.getTimePatternStep
    
    % bulk & wall
    d.setLinkBulkReactionCoeff(ones(1,d.LinkCount)*Kb);
    d.getLinkBulkReactionCoeff
    values = d.getNodeTankBulkReactionCoeff;
    values(d.NodeTankIndex)=Kb;
    if d.NodeTankIndex
        d.setNodeTankBulkReactionCoeff(values) 
        d.getLinkBulkReactionCoeff
        d.getNodeTankBulkReactionCoeff
    end
    
    d.setLinkWallReactionCoeff(ones(1,d.LinkCount)*Kw);
    d.getLinkWallReactionCoeff

    % Simulate all times
    d.solveCompleteHydraulics
    d.solveCompleteQuality
    
    EpanetAverageWaterAge= (d.getNodeActualQuality); 
    EpanetAllWaterAge=d.getComputedQualityTimeSeries;

    d.LoadInpFile([pwd,'\RESULTS\','temp','.inp'],[pwd,'\RESULTS\','temp','.txt'],[pwd,'\RESULTS\','temp','.out']);

    % EPANET - Finding average chlorine
    % guality type    
    nn=d.getOptionsQualityTolerance;
    d.setQualityType('CHEM','mg/L');
    d.getQualityType
    d.getOptionsQualityTolerance 
    d.setOptionsQualityTolerance(nn);
    
    % initial quality
    v=d.getNodeInitialQuality;
    values=v*0;
    ind=d.NodeReservoirIndex;
    if length(ind)
        values(ind(1))=1; % 1 mg/L in Reservoir
        d.setNodeInitialQuality(values)
    else 
        ind=d.NodeTankIndex;
        values(ind(1))=1; % 1 mg/L in Reservoir
        d.setNodeInitialQuality(values)
    end
    
    % sources
    values = d.getNodeSourceQuality;
    values(1:end)=0;
    d.setNodeSourceQuality(values)
    d.getNodeSourceQuality
    
    % simulation time
    d.setTimeSimulationDuration(simulateTime*3600); 
    d.setTimeQualityStep(qualitystep);
    d.getTimeQualityStep
    d.setTimeStatisticsType('AVERAGE');
    d.getTimePatternStep
    d.setTimePatternStep(7200)
    d.getTimePatternStep

    % bulk & wall
    d.setLinkBulkReactionCoeff(ones(1,d.LinkCount)*Kb);
    d.getLinkBulkReactionCoeff
    values = d.getNodeTankBulkReactionCoeff;
    values(d.NodeTankIndex)=Kb;
    if d.NodeTankIndex
        d.setNodeTankBulkReactionCoeff(values) 
        d.getLinkBulkReactionCoeff
        d.getNodeTankBulkReactionCoeff
    end

    d.setLinkWallReactionCoeff(ones(1,d.LinkCount)*Kw);
    d.getLinkWallReactionCoeff

    % Simulate all times
    d.solveCompleteHydraulics
    d.solveCompleteQuality
    
    EpanetAverageChlorine= d.getNodeActualQuality;
    EpanetAllChlorine=d.getComputedQualityTimeSeries;

    % MSX - Finding average chlorine and age
    d.MsxUnload
    d.msx(['temp','.msx'])
    d.setTimeStatisticsType('AVERAGE');
    % reactions
    d.setLinkBulkReactionCoeff(ones(1,d.LinkCount)*Kb);
    d.getLinkBulkReactionCoeff
    values = d.getNodeTankBulkReactionCoeff;
    values(d.NodeTankIndex)=Kb;
    if d.NodeTankIndex
        d.setNodeTankBulkReactionCoeff(values) 
        d.getLinkBulkReactionCoeff
        d.getNodeTankBulkReactionCoeff
    end
    d.setLinkWallReactionCoeff(ones(1,d.LinkCount)*Kw);
    d.getLinkWallReactionCoeff
    
% % %     % patterns zero all
% % %     vls = d.getNodeDemandPatternIndex;
% % %     vls(1:end)=0;
% % %     d.setNodeDemandPatternIndex(vls)
% % %     d.getNodeDemandPatternIndex

    % quality zero all
    vv = d.getNodeInitialQuality;
    vv(1:end)=0;
    d.setNodeInitialQuality(vv)
    d.getNodeInitialQuality
    
    s=d.getMsxComputedQualityNode;
    
%     nodesID=d.getNodeNameID;
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

    %REPORT
    % Solve for hydraulics & water quality
    d.MsxSolveCompleteHydraulics
    d.MsxSolveCompleteQuality
    % Write results to the “TestMsxReport” file
    d.MsxWriteReport %a specific water quality report file is named in the [REPORT] section of the MSX input file. %BUG
    copyfile([pwd,'\LIBRARIES\','epanetmsx.exe'],[pwd,'\RESULTS\','epanetmsx.exe']);
    copyfile([pwd,'\LIBRARIES\','epanetmsx.dll'],[pwd,'\RESULTS\','epanetmsx.dll']);
    copyfile([pwd,'\LIBRARIES\','epanet2.dll'],[pwd,'\RESULTS\','epanet2.dll']);
    fid = fopen('ReportMsx.bat','w');
    r = sprintf('cd RESULTS \nepanetmsx %s %s %s','temp.inp','temp.msx','temp.txt'); 
    fprintf(fid,'%s \n',r);fclose all;
    !ReportMsx.bat
    movefile('ReportMsx.bat',[pwd,'\RESULTS\','ReportMsx.bat']);
    copyfile([pwd,'\RESULTS\','temp.txt'],[pwd,'\RESULTS\','TestMsxReport2.txt']);
    open('TestMsxReport2.txt')
    
    
    % Plots - Net1_Rossman2000.msx
    figure;
    h(:,1)=plot(EpanetAverageWaterAge,'b');
    hold on;
    h(:,2)=plot((MsxResultsAverage.Age*24),'r');% EPI 24 BECAUSE RATE UNITS DAY
%     h(:,3)=plot([4.71 6.52 11.91 1.89 0],'k');%data from epanet example.inp
    h(:,3)=plot([1.98 6.9 8.92 9.17 6.63 9.45 8.22 6.12 8.29 0 11.73],'k');%data from epanet Net1
    legend(h,{'Matlab-Epanet','Matlab-Msx','EPANET'});
    title('Average Age');
    xlabel('Nodes');

    figure;
    hh(:,1)=plot(EpanetAverageChlorine,'b');
    hold on;
    hh(:,2)=plot(MsxResultsAverage.Chlorine,'r');
%     hh(:,3)=plot([.65 .52 .04 .81 1],'k');%data from epanet  example.inp
    hh(:,3)=plot([.88 .58 .42 .39 .61 .36 .47 .63 .45 1 .03],'k');%data from epanet Net1
    legend(hh,{'Matlab-Epanet','Matlab-Msx','EPANET'});
    title('Average Chlorine');
    xlabel('Nodes');
   
    figure;
%     hh(:,1)=plot(EpanetAverageTHMs,'b');
%     hold on;
    hh(:,2)=plot(MsxResultsAverage.THMs,'r');
%     hh(:,3)=plot([.65 .52 .04 .81 1],'k');%data from epanet  example.inp
%     hh(:,3)=plot([.88 .58 .42 .39 .61 .36 .47 .63 .45 1 .03],'k');%data from epanet Net1
%     legend(hh,{'Matlab-Epanet','Matlab-Msx','EPANET'});
    title('Average THMs');
    xlabel('Nodes');
    
    % Delete s files 
    a='abcdefghijklmnopqrstuvwxyz';
    for i=1:length(a)
        s=sprintf('s%s*',a(i));
        delete(s)
    end
    for i=1:9
        s=sprintf('s%.f*',i);
        delete(s)
    end
    rmpath(genpath(pwd));
    
end