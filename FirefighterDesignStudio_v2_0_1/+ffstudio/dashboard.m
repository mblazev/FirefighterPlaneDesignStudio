function app=dashboard(c)
%DASHBOARD Text-based parameter editor avoids numeric/logical UI coercion.
if nargin<1, c=ffstudio.defaultConfig; end
ffstudio.validateConfig(c); info=ffstudio.releaseInfo;
fig=uifigure('Name',['Firefighting Studio v' info.version], ...
    'Position',[60 60 1450 900]);
layout=uigridlayout(fig,[2 2]); layout.RowHeight={36,'1x'};
layout.ColumnWidth={350,'1x'};
status=uilabel(layout,'Text',['Version ' info.version ' | ' info.root]);
status.Layout.Column=[1 2];
left=uigridlayout(layout,[8 1]); left.Layout.Row=2; left.Layout.Column=1;
left.RowHeight={28,'1x',34,34,34,34,34,48};
uilabel(left,'Text','Inputs: edit values, then Recompute','FontWeight','bold');
[paths,values]=flatten(c,'');
inputTable=uitable(left,'Data',[paths values], ...
    'ColumnName',{'Parameter','Value'},'ColumnFormat',{'char','char'}, ...
    'ColumnEditable',[false true],'ColumnWidth',{205,110},'RowName',{});
recomputeButton=uibutton(left,'Text','Recompute','ButtonPushedFcn',@recompute);
studyButton=uibutton(left,'Text','Run sensitivity + uncertainty','ButtonPushedFcn',@studies);
exportButton=uibutton(left,'Text','Export report, figures and tables','ButtonPushedFcn',@export);
scenarioGrid=uigridlayout(left,[1 2]); scenarioGrid.Padding=[0 0 0 0];
uibutton(scenarioGrid,'Text','Save inputs','ButtonPushedFcn',@saveInputs);
uibutton(scenarioGrid,'Text','Load inputs','ButtonPushedFcn',@loadInputs);
flightGrid=uigridlayout(left,[1 2]); flightGrid.Padding=[0 0 0 0];
buildButton=uibutton(flightGrid,'Text','Build 6DOF model','ButtonPushedFcn',@buildModel);
flightButton=uibutton(flightGrid,'Text','Run 6DOF flight','ButtonPushedFcn',@fly);
uilabel(left,'Text','All numbers use the units in the field name. Boolean inputs: 0 or 1. Wind: [North East Down].', ...
    'WordWrap','on');
tabs=uitabgroup(layout); tabs.Layout.Row=2; tabs.Layout.Column=2;
g=tabGrid('Overview',[3 1],{70,'1x',160});
modeGrid=uigridlayout(g,[1 2]); modeGrid.ColumnWidth={200,'1x'};
modeDrop=uidropdown(modeGrid,'Items',{'Report method','Actual-speed fuel'},'ValueChangedFcn',@changeMode);
summary=uilabel(modeGrid,'Text','Calculating...','WordWrap','on','FontWeight','bold');
comparison=uitable(g,'RowName',{});
findings=uitextarea(g,'Editable','off');
g=tabGrid('Mission',[2 1],{'1x','1x'}); missionAxes=uiaxes(g); missionTable=uitable(g,'RowName',{});
g=tabGrid('Aerodynamics',[1 2],{'1x'}); polarAxes=uiaxes(g); ldAxes=uiaxes(g);
g=tabGrid('Performance',[2 2],{'1x','1x'});
powerAxes=uiaxes(g); climbAxes=uiaxes(g); constraintAxes=uiaxes(g); fieldTable=uitable(g,'RowName',{});
g=tabGrid('Database + trends',[2 2],{'1x','1x'});
databaseTable=uitable(g,'RowName',{}); databaseTable.Layout.Column=[1 2];
trendAxes=uiaxes(g); emptyAxes=uiaxes(g);
databaseTable.Layout.Row=1;
trendAxes.Layout.Row=2; trendAxes.Layout.Column=1;
emptyAxes.Layout.Row=2; emptyAxes.Layout.Column=2;
g=tabGrid('Geometry + CG',[2 2],{'1x','1x'});
geometryTable=uitable(g,'RowName',{}); cgAxes=uiaxes(g);
cgTable=uitable(g,'RowName',{}); cgTable.Layout.Column=[1 2];
g=tabGrid('Water release',[1 2],{'1x'}); footprintAxes=uiaxes(g); parcelAxes=uiaxes(g);
g=tabGrid('Studies',[2 2],{'1x','1x'});
sensitivityAxes=uiaxes(g); uncertaintyAxes=uiaxes(g);
studyNote=uitextarea(g,'Editable','off','Value',{'Run studies to calculate the sensitivity curves and 150 uncertainty samples.'});
studyNote.Layout.Column=[1 2];
studyNote.Layout.Row=2;
g=tabGrid('6DOF flight',[2 2],{'1x','1x'});
flightPathAxes=uiaxes(g); flightHeightAxes=uiaxes(g); flightMassAxes=uiaxes(g);
flightNote=uitextarea(g,'Editable','off','Value',{'Build or run the local water-release flight model using Aerospace Blockset.', ...
    'This is a preliminary flight experiment with assumed aerodynamic derivatives, inertia and control laws.'});
result=[]; modelPath=''; busyButtons=[recomputeButton studyButton exportButton buildButton flightButton];
app=struct('Figure',fig,'InputTable',inputTable,'Version',info.version,'Recompute',@recompute);
recompute();

    function grid=tabGrid(name,shape,heights)
        t=uitab(tabs,'Title',name); grid=uigridlayout(t,shape); grid.RowHeight=heights;
    end
    function cfg=readInputs()
        cfg=ffstudio.defaultConfig; data=inputTable.Data;
        for j=1:size(data,1)
            path=char(data{j,1}); txt=strtrim(char(string(data{j,2})));
            if strcmp(path,'name'), value=txt;
            elseif startsWith(txt,'[')
                % JSON parsing reads numbers without executing user text.
                txt=regexprep(txt,'\s+',','); txt=strrep(txt,'[,','['); txt=strrep(txt,',]',']');
                txt=regexprep(txt,',+',','); value=jsondecode(txt);
                value=reshape(value,1,[]);
            else, value=str2double(txt);
            end
            if startsWith(path,'dyn.'), key=extractAfter(path,'dyn.'); cfg.dyn.(char(key))=value;
            else, cfg.(path)=value; end
        end
        cfg.dyn.autopilot=toBoolean(cfg.dyn.autopilot,'autopilot');
        cfg.dyn.engineOut=toBoolean(cfg.dyn.engineOut,'engineOut');
        ffstudio.validateConfig(cfg);
    end
    function b=toBoolean(v,label)
        if ~isnumeric(v)||~isscalar(v)||~isreal(v)||~isfinite(v)||~any(v==[0 1])
            error('ffstudio:Input','%s must be 0 or 1.',label);
        end
        b=logical(v);
    end
    function done=working(message)
        status.Text=message; set(busyButtons,'Enable','off'); drawnow;
        done=onCleanup(@()set(busyButtons(isvalid(busyButtons)),'Enable','on'));
    end
    function failed(err)
        status.Text=['Error: ' err.message];
        fprintf(2,'%s\n',getReport(err,'extended','hyperlinks','off'));
        uialert(fig,err.message,'Firefighting Studio');
    end
    function recompute(varargin)
        done=working('Calculating both mission methods...'); %#ok<NASGU>
        try
            c=readInputs(); result=ffstudio.analyze(c); modelPath='';
            setappdata(fig,'FirefighterResults',result); refresh();
            status.Text=['Ready | v' info.version ' | Inputs and both methods calculated'];
        catch err
            failed(err);
        end
    end
    function changeMode(varargin)
        if ~isempty(result), refresh(); end
    end
    function [d,p]=selected()
        if strcmp(modeDrop.Value,'Actual-speed fuel'), d=result.physics; p=result.physicsPerformance;
        else, d=result.report; p=result.performance; end
    end
    function refresh()
        [d,p]=selected(); cfg=result.config;
        summary.Text=sprintf('MTOW %.0f kg | Fuel %.0f kg | Wing %.1f m2 | Power %.0f kW | Cruise margin %+.0f kW', ...
            d.mtow_kg,d.fuel_kg,d.wingArea_m2,d.installedPower_kW,p.cruiseAvailable_kW-p.cruisePower_kW);
        showTable(comparison,result.comparison); findings.Value=cellstr(result.findings);
        plot(missionAxes,0:11,result.report.mission.stations_kg/1000,'o-', ...
            0:11,result.physics.mission.stations_kg/1000,'s-');
        labels(missionAxes,'Mission mass','Station','Mass (tonnes)'); legend(missionAxes,{'Report','Actual-speed fuel'},'Location','best');
        showTable(missionTable,d.mission.table);
        plot(polarAxes,result.polar.CL,result.polar.CD); labels(polarAxes,'Parabolic drag polar','CL','CD');
        plot(ldAxes,result.polar.CL,result.polar.LD); labels(ldAxes,'Lift / drag','CL','L/D');
        env=p.envelope{2}; plot(powerAxes,env.Speed_kmh,env.RequiredPower_kW,env.Speed_kmh,env.AvailablePower_kW,'--');
        labels(powerAxes,sprintf('Power at %.0f m',cfg.cruiseAltitude_m),'TAS (km/h)','Shaft power (kW)');
        legend(powerAxes,{'Required','Available'},'Location','best');
        env0=p.envelope{1}; plot(climbAxes,env0.Speed_kmh,env0.Climb_ms,env.Speed_kmh,env.Climb_ms);
        labels(climbAxes,'Climb envelope','TAS (km/h)','Climb (m/s)'); legend(climbAxes,{'Field','Cruise altitude'},'Location','best');
        ct=result.constraints.table; plot(constraintAxes,ct.WingLoading_Nm2,ct{:,2:4});
        xline(constraintAxes,result.constraints.maxWSdrop_Nm2,'--','Drop stall limit');
        labels(constraintAxes,'Power / mass constraints','W/S (N/m2)','P/m (kW/kg)');
        legend(constraintAxes,{'Cruise','Climb','OEI'},'Location','best');
        field=table([p.stallClean_kmh;p.dropStall_kmh;p.dropSpeedMargin;p.field.takeoff15m_m;p.field.landing15m_m;p.loadedRange_km], ...
            'RowNames',{'Clean stall km/h','Drop stall km/h','Drop speed/stall','Takeoff to 15m (m)','Landing from 15m (m)','Loaded range km'},'VariableNames',{'Value'});
        showTable(fieldTable,field); fieldTable.RowName=field.Properties.RowNames;
        showTable(databaseTable,result.database);
        land=result.database.Class=="Land twin"; db=result.database;
        scatter(trendAxes,db.Year(land),db.Cruise_kmh(land),'filled'); hold(trendAxes,'on');
        years=linspace(min(db.Year),cfg.designYear,100); f=result.trends.CruiseYear;
        plot(trendAxes,years,f.slope*years+f.intercept); hold(trendAxes,'off');
        labels(trendAxes,'Land twin cruise trend','Year','Cruise (km/h)');
        empty=db.EmptyEligible; scatter(emptyAxes,db.MTOW_kg(empty),db.EmptyFraction(empty),'filled'); hold(emptyAxes,'on');
        m=linspace(min(db.MTOW_kg(empty)),max(db.MTOW_kg(empty)),100);
        plot(emptyAxes,m,result.trends.EmptyLaw.A*m.^result.trends.EmptyLaw.C); hold(emptyAxes,'off');
        labels(emptyAxes,'Empty mass fraction fit','MTOW (kg)','Empty / MTOW');
        geo=ffstudio.geometry(cfg,d); [gp,gv]=flatten(geo,''); geometryTable.Data=[gp gv]; geometryTable.ColumnName={'Quantity','Value'};
        cg=ffstudio.cgLedger(cfg,d); showTable(cgTable,cg.table);
        plot(cgAxes,0:11,cg.table.CG_MAC,'o-'); yline(cgAxes,cfg.cgMin_MAC,'--'); yline(cgAxes,cfg.cgMax_MAC,'--');
        labels(cgAxes,'CG mass ledger','Station','CG / MAC');
        drop=result.drop; plot(footprintAxes,drop.impacts.North_m,drop.impacts.East_m,'o-');
        labels(footprintAxes,sprintf('Release line %.0f m; drift %.1f m',drop.length_m,drop.meanDrift_m),'North (m)','East (m)');
        path=drop.paths{1}; plot(parcelAxes,path(:,2),-path(:,4)); labels(parcelAxes,'First parcel trajectory','North (m)','Height (m)');
    end
    function showTable(widget,t)
        widget.Data=t; widget.ColumnName=t.Properties.VariableNames;
    end
    function labels(ax,titleText,x,y)
        title(ax,titleText); xlabel(ax,x); ylabel(ax,y); grid(ax,'on');
    end
    function studies(varargin)
        done=working('Running sensitivity and 150 uncertainty samples...'); %#ok<NASGU>
        try
            ensureFresh(); result.sensitivity=ffstudio.sensitivity(result.config);
            result.uncertainty=ffstudio.uncertainty(result.config,150,42);
            s=result.sensitivity; cla(sensitivityAxes); hold(sensitivityAxes,'on');
            names=fieldnames(s); names=names(~strcmp(names,'note'));
            for j=1:numel(names)
                t=s.(names{j}); idx=ceil(height(t)/2);
                plot(sensitivityAxes,t.Input/t.Input(idx),t.MTOW_kg/result.report.mtow_kg,'DisplayName',names{j});
            end
            hold(sensitivityAxes,'off'); labels(sensitivityAxes,'Single input sensitivity','Input / midpoint','MTOW / baseline'); legend(sensitivityAxes,'Location','best');
            histogram(uncertaintyAxes,result.uncertainty.table.MTOW_kg/1000,18);
            labels(uncertaintyAxes,'Illustrative uncertainty','MTOW (tonnes)','Samples');
            studyNote.Value={s.note,result.uncertainty.note,sprintf('MTOW P05 / P50 / P95: %.0f / %.0f / %.0f kg',result.uncertainty.massP05P50P95_kg)};
            setappdata(fig,'FirefighterResults',result); status.Text='Studies complete';
        catch err
            failed(err);
        end
    end
    function ensureFresh()
        latest=readInputs();
        if isempty(result)||~isequaln(latest,result.config), result=ffstudio.analyze(latest); refresh(); end
    end
    function export(varargin)
        folder=uigetdir(info.root,'Select report output folder'); if isequal(folder,0), return; end
        done=working('Exporting report and figures...'); %#ok<NASGU>
        try
            ensureFresh(); ffstudio.exportReport(result,folder); status.Text=['Exported: ' folder];
        catch err
            failed(err);
        end
    end
    function saveInputs(varargin)
        [file,folder]=uiputfile('*.json','Save scenario inputs','firefighter_inputs.json'); if isequal(file,0), return; end
        try
            cfg=readInputs(); ffstudio.writeText(fullfile(folder,file),jsonencode(cfg,'PrettyPrint',true)); status.Text='Inputs saved';
        catch err
            failed(err);
        end
    end
    function loadInputs(varargin)
        [file,folder]=uigetfile('*.json','Load version 2 scenario inputs'); if isequal(file,0), return; end
        try
            cfg=jsondecode(fileread(fullfile(folder,file))); ffstudio.validateConfig(cfg);
            [paths,values]=flatten(cfg,''); inputTable.Data=[paths values]; recompute();
        catch err
            failed(err);
        end
    end
    function buildModel(varargin)
        done=working('Building Aerospace Blockset model...'); %#ok<NASGU>
        try
            ensureFresh(); [d,~]=selected(); modelPath=ffstudio.buildSimulink(result.config,fullfile(info.root,'models'),d);
            open_system('ffstudio_v2_6dof'); status.Text=['Built: ' modelPath];
        catch err
            failed(err);
        end
    end
    function fly(varargin)
        done=working('Running water-release flight experiment...'); %#ok<NASGU>
        try
            ensureFresh(); [d,~]=selected(); flight=ffstudio.simulate6dof(result.config,modelPath,d);
            result.flight=flight; modelPath=flight.modelPath; t=flight.table;
            plot3(flightPathAxes,t.North_m,t.East_m,t.Height_m); labels(flightPathAxes,'Aircraft path','North (m)','East (m)'); zlabel(flightPathAxes,'Height (m)');
            plot(flightHeightAxes,t.Time_s,t.Height_m); labels(flightHeightAxes,'Release height','Time (s)','Height (m)');
            plot(flightMassAxes,t.Time_s,t.Mass_kg,t.Time_s,t.Water_kg); labels(flightMassAxes,'Changing mass','Time (s)','Mass (kg)'); legend(flightMassAxes,{'Aircraft','Water'});
            flightNote.Value=cellstr(flight.notes); setappdata(fig,'FirefighterResults',result); status.Text='6DOF flight complete';
        catch err
            failed(err);
        end
    end
end

function [paths,values]=flatten(s,prefix)
paths={}; values={}; names=fieldnames(s);
for i=1:numel(names)
    name=names{i}; path=[prefix name]; v=s.(name);
    if isstruct(v), [p,q]=flatten(v,[path '.']); paths=[paths;p]; values=[values;q]; %#ok<AGROW>
    else
        if isnumeric(v)||islogical(v), txt=mat2str(reshape(double(v),1,[]),12); else, txt=char(string(v)); end
        paths{end+1,1}=path; values{end+1,1}=txt; %#ok<AGROW>
    end
end
end
