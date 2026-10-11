function path=exportReport(r,folder)
%EXPORTREPORT Portable HTML, CSV, figures, JSON inputs and full MATLAB results.
if ~exist(folder,'dir'), mkdir(folder); end
writetable(r.comparison,fullfile(folder,'comparison.csv'));
writetable(r.database,fullfile(folder,'aircraft_database.csv'));
writetable(r.report.mission.table,fullfile(folder,'mission_report.csv'));
writetable(r.physics.mission.table,fullfile(folder,'mission_actual_speed.csv'));
writetable(r.constraints.table,fullfile(folder,'constraints.csv'));
writetable(r.cg.table,fullfile(folder,'cg_report.csv'));
physicsCG=ffstudio.cgLedger(r.config,r.physics);
writetable(physicsCG.table,fullfile(folder,'cg_actual_speed.csv'));
writetable(r.drop.impacts,fullfile(folder,'water_impacts.csv'));
for i=1:2
    writetable(r.performance.envelope{i},fullfile(folder,sprintf('envelope_report_%d.csv',i)));
    writetable(r.physicsPerformance.envelope{i},fullfile(folder,sprintf('envelope_actual_speed_%d.csv',i)));
end
if isfield(r,'sensitivity')
    names=fieldnames(r.sensitivity);
    for i=1:numel(names)
        if istable(r.sensitivity.(names{i}))
            writetable(r.sensitivity.(names{i}),fullfile(folder,['sensitivity_' names{i} '.csv']));
        end
    end
end
if isfield(r,'uncertainty'), writetable(r.uncertainty.table,fullfile(folder,'uncertainty.csv')); end
if isfield(r,'flight'), writetable(r.flight.table,fullfile(folder,'flight.csv')); end
ffstudio.writeText(fullfile(folder,'inputs.json'),jsonencode(r.config,'PrettyPrint',true));
summary.version=r.release.version; summary.report=summaryOf(r.report,r.performance);
summary.actualSpeed=summaryOf(r.physics,r.physicsPerformance);
summary.findings=r.findings; summary.polar=rmfield(r.polar,{'CL','CD','LD'});
ffstudio.writeText(fullfile(folder,'summary.json'),jsonencode(summary,'PrettyPrint',true));
save(fullfile(folder,'firefighter_results.mat'),'r');
ffstudio.exportPlots(r,folder);
list=join("<li>"+escape(r.findings)+"</li>",newline);
html="<!doctype html><html lang='en'><meta charset='utf-8'><meta name='viewport' content='width=device-width,initial-scale=1'>"+ ...
    "<title>Firefighting Studio report</title><style>body{font:16px system-ui;line-height:1.6;background:#edf2f6;color:#172c3f}main{max-width:1100px;margin:30px auto;padding:30px;background:white}table{border-collapse:collapse;width:100%}td,th{padding:9px;border-bottom:1px solid #d8e2eb;text-align:left}img{width:100%}.note{background:#fff2db;padding:15px}a{color:#136b91}</style><main>"+ ...
    "<h1>"+escape(string(r.config.name))+"</h1><p>Firefighting Studio v"+string(r.release.version)+" | "+string(datetime('now'))+"</p>"+ ...
    "<h2>Mass and geometry</h2>"+tableHtml(r.comparison)+ ...
    "<h2>Findings</h2><ul>"+list+"</ul>"+ ...
    "<img src='mission.png' alt='Mission mass'><img src='performance.png' alt='Power and constraints'>"+ ...
    "<img src='aerodynamics.png' alt='Drag polar'><img src='water_and_cg.png' alt='Water impacts and CG'>"+ ...
    "<h2>Mission: report method</h2>"+tableHtml(r.report.mission.table)+ ...
    "<h2>Mission: actual-speed fuel</h2>"+tableHtml(r.physics.mission.table)+ ...
    "<p class='note'>Preliminary design calculations. Flight derivatives, lift limits, power lapse, inertia, field and parcel inputs are assumptions. Actual-speed fuel closure does not establish power feasibility. Water parcels do not establish effective coverage. See the package assumptions guide.</p>"+ ...
    "<p><a href='inputs.json'>Scenario inputs</a> | <a href='summary.json'>Summary</a> | <a href='comparison.csv'>Comparison CSV</a> | <a href='firefighter_results.mat'>Full MATLAB results</a></p></main></html>";
path=fullfile(folder,'report.html'); ffstudio.writeText(path,html);
end

function s=summaryOf(d,p)
s=struct('mtow_kg',d.mtow_kg,'empty_kg',d.empty_kg,'fuel_kg',d.fuel_kg, ...
    'wingArea_m2',d.wingArea_m2,'span_m',d.span_m,'installedPower_kW',d.installedPower_kW, ...
    'cruisePower_kW',p.cruisePower_kW,'cruiseAvailable_kW',p.cruiseAvailable_kW, ...
    'loadedRange_km',p.loadedRange_km,'dropSpeedMargin',p.dropSpeedMargin);
end
function s=escape(s)
s=string(s); s=replace(s,'&','&amp;'); s=replace(s,'<','&lt;'); s=replace(s,'>','&gt;'); s=replace(s,'"','&quot;');
end
function s=tableHtml(t)
s="<table><tr>"+join("<th>"+escape(string(t.Properties.VariableNames))+"</th>","")+"</tr>";
data=table2cell(t);
for i=1:size(data,1)
    row="<tr>";
    for j=1:size(data,2)
        v=data{i,j}; if isnumeric(v), txt=sprintf('%.4g ',v); else, txt=string(v); end
        row=row+"<td>"+escape(txt)+"</td>";
    end
    s=s+row+"</tr>";
end
s=s+"</table>";
end
