function r=performance(c,d)
p=ffstudio.polar(c); h=[c.fieldAltitude_m c.cruiseAltitude_m]; V=linspace(45,210,220)';
for i=1:numel(h)
    a=ffstudio.atmosphere(h(i),c.deltaISA_K); q=.5*a.rho_kgm3*V.^2;
    CL=d.mtow_kg*c.gravity./(q*d.wingArea_m2); CD=p.CD0+p.k*CL.^2;
    D=q*d.wingArea_m2.*CD; Pr=D.*V/(1000*c.propEfficiency);
    Pa=d.installedPower_kW*min(1,a.sigma^c.powerLapseExponent);
    roc=(1000*c.propEfficiency*Pa-D.*V)/(d.mtow_kg*c.gravity); valid=CL<=c.CLmaxClean;
    r.envelope{i}=table(V*3.6,CL,CD,D,Pr,Pa*ones(size(V)),roc,valid, ...
        'VariableNames',{'Speed_kmh','CL','CD','Drag_N','RequiredPower_kW','AvailablePower_kW','Climb_ms','AboveStall'});
    ok=valid & Pr<=Pa;
    if any(ok), r.maxLevelSpeed_kmh(i)=max(V(ok))*3.6; else, r.maxLevelSpeed_kmh(i)=NaN; end
    r.altitudes_m(i)=h(i);
    if any(valid), r.bestROC_ms(i)=max(roc(valid)); else, r.bestROC_ms(i)=NaN; end
end
a=ffstudio.atmosphere(c.cruiseAltitude_m,c.deltaISA_K); V=c.cruise_kmh/3.6;
q=.5*a.rho_kgm3*V^2; m=d.mission.stations_kg(3); CL=m*c.gravity/(q*d.wingArea_m2);
r.cruiseCL=CL; r.cruiseLD=CL/(p.CD0+p.k*CL^2);
r.cruisePower_kW=q*d.wingArea_m2*(p.CD0+p.k*CL^2)*V/(c.propEfficiency*1000);
r.cruiseAvailable_kW=d.installedPower_kW*min(1,a.sigma^c.powerLapseExponent);
r.cruiseMach=V/a.sound_ms;
r.bestLDspeed_kmh=sqrt(2*m*c.gravity/(a.rho_kgm3*d.wingArea_m2*p.CLbest))*3.6;
a=ffstudio.atmosphere(c.fieldAltitude_m,c.deltaISA_K);
r.stallClean_kmh=sqrt(2*d.mtow_kg*c.gravity/(a.rho_kgm3*d.wingArea_m2*c.CLmaxClean))*3.6;
r.stallLanding_kmh=sqrt(2*d.mtow_kg*c.gravity/(a.rho_kgm3*d.wingArea_m2*c.CLmaxLanding))*3.6;
a=ffstudio.atmosphere(c.dropHeight_m,c.deltaISA_K);
r.dropStall_kmh=sqrt(2*d.mission.stations_kg(5)*c.gravity/(a.rho_kgm3*d.wingArea_m2*c.CLmaxLanding))*3.6;
r.dropSpeedMargin=c.drop_kmh/r.dropStall_kmh;
r.field=fieldEstimate(c,d); r.loadedRange_km=ffstudio.loadedRange(c,d);
end

function r=fieldEstimate(c,d)
a=ffstudio.atmosphere(c.fieldAltitude_m,c.deltaISA_K); p=ffstudio.polar(c);
W=d.mtow_kg*c.gravity; S=d.wingArea_m2; rho=a.rho_kgm3;
Vlo=1.2*sqrt(2*W/(rho*S*c.CLmaxTakeoff)); V=linspace(0,Vlo,500)';
q=.5*rho*V.^2; CLg=.70*c.CLmaxTakeoff; L=q*S*CLg;
D=q*S*(p.CD0+.04+p.k*CLg^2);
P=d.installedPower_kW*1000*min(1,a.sigma^c.powerLapseExponent);
T=min(c.propEfficiency*P./max(V,20),.35*W);
acc=(T-D-c.muRoll*max(0,W-L))/d.mtow_kg;
if any(acc<=0)
    r.takeoffGround_m=Inf; r.takeoff15m_m=Inf;
else
    r.takeoffGround_m=trapz(V,V./acc); qlo=.5*rho*Vlo^2; CL=W/(qlo*S);
    Dlo=qlo*S*(p.CD0+.04+p.k*CL^2);
    grad=(min(c.propEfficiency*P/Vlo,.35*W)-Dlo)/W;
    if grad<=0, r.takeoff15m_m=Inf; else, r.takeoff15m_m=r.takeoffGround_m+15/grad; end
end
ml=d.mission.stations_kg(end); WL=ml*c.gravity;
Vtd=1.15*sqrt(2*WL/(rho*S*c.CLmaxLanding)); V=linspace(0,Vtd,500)'; q=.5*rho*V.^2;
L=q*S*.5*c.CLmaxLanding; D=q*S*(p.CD0+.08+p.k*(.5*c.CLmaxLanding)^2);
dec=(D+c.muBrake*max(0,WL-L))/ml;
r.landingGround_m=trapz(V,V./max(dec,.01));
r.landing15m_m=r.landingGround_m+15/tan(3*pi/180);
r.note='Preliminary field estimates: 0.35W static thrust cap and 3 degree landing path. No balanced field, certified obstacle factors or explicit flare allowance.';
end
