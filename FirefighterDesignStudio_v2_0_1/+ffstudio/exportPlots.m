function exportPlots(r,folder)
%EXPORTPLOTS Static, reusable engineering figures.
if ~exist(folder,'dir'), mkdir(folder); end
f=figure('Visible','off','Position',[100 100 1100 450]); cleanup=onCleanup(@()delete(f));
tiledlayout(f,1,2); ax=nexttile;
plot(ax,0:11,r.report.mission.stations_kg/1000,'o-',0:11,r.physics.mission.stations_kg/1000,'s-');
xlabel(ax,'Station'); ylabel(ax,'Mass (tonnes)'); title(ax,'Mission mass'); grid(ax,'on'); legend(ax,{'Report','Actual-speed fuel'});
ax=nexttile; bar(ax,[r.report.empty_kg r.report.fuel_kg r.config.payload_kg r.config.crew_kg; ...
    r.physics.empty_kg r.physics.fuel_kg r.config.payload_kg r.config.crew_kg]/1000,'stacked');
xticks(ax,[1 2]); xticklabels(ax,{'Report','Actual-speed'}); ylabel(ax,'Mass (tonnes)'); legend(ax,{'Empty','Fuel','Water','Crew'}); title(ax,'Takeoff mass breakdown');
exportgraphics(f,fullfile(folder,'mission.png'),'Resolution',160);
clf(f); tiledlayout(f,1,2); ax=nexttile; t=r.performance.envelope{2};
plot(ax,t.Speed_kmh,t.RequiredPower_kW,t.Speed_kmh,t.AvailablePower_kW,'--');
xlabel(ax,'TAS (km/h)'); ylabel(ax,'Shaft power (kW)'); title(ax,'Report baseline at cruise altitude'); grid(ax,'on'); legend(ax,{'Required','Available'});
ax=nexttile; t=r.constraints.table; plot(ax,t.WingLoading_Nm2,t{:,2:4});
xline(ax,r.constraints.maxWSdrop_Nm2,'--','Drop stall limit');
xlabel(ax,'W/S (N/m2)'); ylabel(ax,'P/m (kW/kg)'); title(ax,'Illustrative constraints'); grid(ax,'on'); legend(ax,{'Cruise','Climb','OEI'});
exportgraphics(f,fullfile(folder,'performance.png'),'Resolution',160);
clf(f); tiledlayout(f,1,2); ax=nexttile; plot(ax,r.polar.CL,r.polar.CD); xlabel(ax,'CL'); ylabel(ax,'CD'); title(ax,'Drag polar'); grid(ax,'on');
ax=nexttile; plot(ax,r.polar.CL,r.polar.LD); xlabel(ax,'CL'); ylabel(ax,'L/D'); title(ax,'Lift / drag'); grid(ax,'on');
exportgraphics(f,fullfile(folder,'aerodynamics.png'),'Resolution',160);
clf(f); tiledlayout(f,1,2); ax=nexttile; plot(ax,r.drop.impacts.North_m,r.drop.impacts.East_m,'o-');
xlabel(ax,'North (m)'); ylabel(ax,'East (m)'); title(ax,'Parcel impacts'); grid(ax,'on');
ax=nexttile; plot(ax,r.cg.table.Station,r.cg.table.CG_MAC,'o-'); yline(ax,r.config.cgMin_MAC,'--'); yline(ax,r.config.cgMax_MAC,'--');
xlabel(ax,'Station'); ylabel(ax,'CG / MAC'); title(ax,'Assumed CG stations'); grid(ax,'on');
exportgraphics(f,fullfile(folder,'water_and_cg.png'),'Resolution',160);
clear cleanup;
end
