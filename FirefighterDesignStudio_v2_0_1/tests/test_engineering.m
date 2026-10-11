function tests=test_engineering
tests=functiontests(localfunctions);
end
function testReportClosure(test)
c=ffstudio.defaultConfig; d=ffstudio.sizeAircraft(c,'report');
verifyEqual(test,d.mtow_kg,21965.2846944,'AbsTol',.05);
verifyEqual(test,d.fuel_kg,3475.6317556,'AbsTol',.05);
verifyEqual(test,d.mtow_kg,d.empty_kg+d.fuel_kg+c.payload_kg+c.crew_kg,'AbsTol',1e-3);
verifyEqual(test,d.mission.stations_kg(6)-d.mission.stations_kg(7),c.payload_kg,'AbsTol',1e-8);
verifyEqual(test,d.mission.stations_kg(end)-d.empty_kg-c.crew_kg,d.mission.extraReserve_kg,'AbsTol',1e-3);
end
function testActualSpeedIntegral(test)
c=ffstudio.defaultConfig; d=ffstudio.sizeAircraft(c,'physics'); p=ffstudio.polar(c);
verifyEqual(test,d.mtow_kg,25896.9701589,'AbsTol',.2);
verifyEqual(test,d.fuel_kg,5431.7151185,'AbsTol',.2);
% Independent numerical integration of the outbound fuel ODE.
m0=d.mission.stations_kg(3); V=c.cruise_kmh/3.6; a=ffstudio.atmosphere(c.cruiseAltitude_m,c.deltaISA_K);
q=.5*a.rho_kgm3*V^2; S=d.wingArea_m2; duration=c.radius_km/c.cruise_kmh*3600;
ode=@(~,m)-c.sfcCruise_kgkWh/3.6e6*V/c.propEfficiency*(q*S*p.CD0+p.k*(m*c.gravity)^2/(q*S));
[~,m]=ode45(ode,[0 duration],m0,odeset('RelTol',1e-10,'AbsTol',1e-8));
verifyEqual(test,m(end),d.mission.stations_kg(4),'AbsTol',1e-4);
end
function testPerformanceFinding(test)
c=ffstudio.defaultConfig; d=ffstudio.sizeAircraft(c,'report'); p=ffstudio.performance(c,d);
verifyGreaterThan(test,p.cruisePower_kW,p.cruiseAvailable_kW);
verifyEqual(test,p.cruiseLD,11.10412259,'AbsTol',.01);
verifyEqual(test,p.loadedRange_km,1339.25250263,'AbsTol',.1);
verifyGreaterThan(test,p.dropSpeedMargin,1.3);
end
function testPolarAndTrends(test)
c=ffstudio.defaultConfig; p=ffstudio.polar(c);
verifyEqual(test,p.LDmax,1/(2*sqrt(p.k*p.CD0)),'AbsTol',1e-10);
t=ffstudio.loadDatabase; f=ffstudio.fitTrends(t,c);
verifyEqual(test,height(t),19); verifyEqual(test,nnz(t.TrendEligible),11);
verifyEqual(test,f.CruiseYear.n,9); verifyEqual(test,f.RangeYear.n,7);
verifyEqual(test,f.EmptyLaw.n,12); verifyEqual(test,f.EmptyLaw.A,1.44190798898,'AbsTol',1e-7);
verifyEqual(test,f.EmptyLaw.C,-.09468819631,'AbsTol',1e-9);
end
function testWaterAndCG(test)
c=ffstudio.defaultConfig; c.releaseCount=3; c.windNED_ms=[0 0 0];
r=ffstudio.dropFootprint(c);
verifyEqual(test,r.impacts.East_m,zeros(3,1),'AbsTol',1e-8);
verifyEqual(test,r.length_m,c.dropDuration_s*c.drop_kmh/3.6,'AbsTol',1e-3);
verifyGreaterThan(test,r.impacts.FallTime_s,zeros(3,1));
d=ffstudio.sizeAircraft(c,'report'); cg=ffstudio.cgLedger(c,d);
verifyGreaterThanOrEqual(test,cg.table.Fuel_kg,zeros(12,1));
verifyEqual(test,cg.table.Water_kg(7:end),zeros(6,1));
end
function testFullAnalysisAndExport(test)
c=ffstudio.defaultConfig; c.releaseCount=3; r=ffstudio.analyze(c);
verifySize(test,r.comparison,[7 4]); verifyTrue(test,all(strlength(r.findings)>0));
folder=tempname; mkdir(folder); path=ffstudio.exportReport(r,folder);
verifyTrue(test,isfile(path)); verifyTrue(test,isfile(fullfile(folder,'mission_report.csv')));
verifyTrue(test,isfile(fullfile(folder,'inputs.json'))); verifyTrue(test,isfile(fullfile(folder,'performance.png')));
end
function testReproducibleUncertainty(test)
c=ffstudio.defaultConfig; saved=rng;
a=ffstudio.uncertainty(c,4,42); b=ffstudio.uncertainty(c,4,42);
verifyEqual(test,a.table,b.table); verifyEqual(test,rng,saved);
verifyTrue(test,all(diff(a.massP05P50P95_kg)>=0));
end
