function r=constraints(c)
p=ffstudio.polar(c); ws=linspace(1200,6500,160)';
a=ffstudio.atmosphere(c.cruiseAltitude_m,c.deltaISA_K); V=c.cruise_kmh/3.6;
q=.5*a.rho_kgm3*V^2; lapse=min(1,a.sigma^c.powerLapseExponent);
cruise=c.gravity*V/c.propEfficiency/1000/lapse.*(q*p.CD0./ws+p.k*ws/q);
a=ffstudio.atmosphere(c.fieldAltitude_m,c.deltaISA_K); lapse=min(1,a.sigma^c.powerLapseExponent);
Vcl=max(c.drop_kmh/3.6,1.3*sqrt(2*ws/(a.rho_kgm3*c.CLmaxClean)));
q=.5*a.rho_kgm3*Vcl.^2; dw=q*p.CD0./ws+p.k*ws./q;
climb=c.gravity*(c.climbTarget_ms+Vcl.*dw)/c.propEfficiency/1000/lapse;
oei=c.gravity*Vcl.*(c.oeiGradient+dw)/c.propEfficiency/1000/lapse*c.engineCount/(c.engineCount-1);
a=ffstudio.atmosphere(c.dropHeight_m,c.deltaISA_K);
r.maxWSdrop_Nm2=.5*a.rho_kgm3*(c.drop_kmh/3.6/1.3)^2*c.CLmaxLanding;
r.table=table(ws,cruise,climb,oei,max([cruise climb oei],[],2), ...
    'VariableNames',{'WingLoading_Nm2','Cruise_kWkg','Climb_kWkg','OEI_kWkg','Required_kWkg'});
r.selectedRequired_kWkg=interp1(ws,r.table.Required_kWkg,c.wingLoading_Nm2,'linear','extrap');
r.note='Illustrative OEI gradient only. No Vmc, prop windmilling or certified climb procedure.';
end
