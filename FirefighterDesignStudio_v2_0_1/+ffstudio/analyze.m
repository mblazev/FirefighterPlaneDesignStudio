function r=analyze(c)
ffstudio.validateConfig(c); r.config=c; r.release=ffstudio.releaseInfo;
r.database=ffstudio.loadDatabase; r.polar=ffstudio.polar(c);
r.trends=ffstudio.fitTrends(r.database,c);
r.report=ffstudio.sizeAircraft(c,'report'); r.physics=ffstudio.sizeAircraft(c,'physics');
r.performance=ffstudio.performance(c,r.report); r.physicsPerformance=ffstudio.performance(c,r.physics);
r.constraints=ffstudio.constraints(c); r.geometry=ffstudio.geometry(c,r.report);
r.cg=ffstudio.cgLedger(c,r.report); r.drop=ffstudio.dropFootprint(c);
r.comparison=table(["MTOW kg";"Empty kg";"Fuel kg";"Wing area m2";"Span m"; ...
 "Installed power kW";"Loaded range km"],[21967;12291;3476;61.6;26.6;5053;1339], ...
 [r.report.mtow_kg;r.report.empty_kg;r.report.fuel_kg;r.report.wingArea_m2;r.report.span_m; ...
 r.report.installedPower_kW;r.performance.loadedRange_km], ...
 [r.physics.mtow_kg;r.physics.empty_kg;r.physics.fuel_kg;r.physics.wingArea_m2;r.physics.span_m; ...
 r.physics.installedPower_kW;r.physicsPerformance.loadedRange_km], ...
 'VariableNames',{'Quantity','ReportPrinted','ReportRecomputed','ActualSpeedFuel'});
r.findings=strings(0,1);
if r.performance.cruisePower_kW>r.performance.cruiseAvailable_kW
    r.findings(end+1,1)=sprintf('%.0f km/h loaded cruise needs %.0f kW; %.0f kW is assumed available at altitude. Replace the engine lapse assumption with an engine map or change the design.', ...
        c.cruise_kmh,r.performance.cruisePower_kW,r.performance.cruiseAvailable_kW);
end
r.findings(end+1,1)=sprintf('Cruise L/D %.2f versus best L/D %.2f. Best-L/D speed %.0f km/h.', ...
    r.performance.cruiseLD,r.polar.LDmax,r.performance.bestLDspeed_kmh);
if r.performance.dropSpeedMargin<1.3
    r.findings(end+1,1)=sprintf('Drop speed/stall ratio %.2f is below the assumed 1.3 margin.',r.performance.dropSpeedMargin);
end
r.findings(end+1,1)='Actual-speed fuel sizing assumes the commanded speed can be maintained. Mass closure alone does not establish a feasible design.';
r.findings(end+1,1)='Report comparison values are rounded. Database/source attributions are transcribed from the attachment and have not been independently reverified.';
r.findings(end+1,1)='CLmax, power lapse, CG, inertia, field estimates, parcel properties and flight derivatives are preliminary inputs.';
end
