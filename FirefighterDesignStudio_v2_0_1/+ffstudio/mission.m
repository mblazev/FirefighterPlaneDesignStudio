function r=mission(c,m0,mode)
if nargin<3, mode='report'; end
assert(ismember(mode,{'report','physics'}),'ffstudio:Mode','Unknown mission method.');
p=ffstudio.polar(c); S=m0*c.gravity/c.wingLoading_Nm2;
names=["Warm-up / taxi / take-off";"Loaded climb";"Outbound cruise"; ...
 "Descent to drop";"Low-level pattern";"Water release";"Empty climb"; ...
 "Return cruise";"Descent to reserve";"Reserve loiter";"Landing / taxi"];
fractions=[c.takeoffFraction;c.climbFraction;NaN;c.descentFraction;NaN;NaN; ...
    c.climbFraction;NaN;c.descentFraction;NaN;c.landingFraction];
duration=[NaN;NaN;c.radius_km/c.cruise_kmh*3600;NaN;c.pattern_min*60;0; ...
    NaN;c.radius_km/c.cruise_kmh*3600;NaN;c.loiter_min*60;NaN];
speed=nan(11,1); height=speed; sfc=speed; K=speed; extraCD=zeros(11,1);
speed([3 8])=c.cruise_kmh/3.6; height([3 8])=c.cruiseAltitude_m;
sfc([3 8])=c.sfcCruise_kgkWh; K([3 8])=p.LDmax;
speed(5)=c.drop_kmh/3.6; height(5)=c.dropHeight_m; sfc(5)=c.sfcLoiter_kgkWh;
K(5)=.70*p.LDmax; extraCD(5)=c.deltaCDpattern;
speed(10)=c.loiter_kmh/3.6; height(10)=c.loiterAltitude_m; sfc(10)=c.sfcLoiter_kgkWh;
K(10)=.866*p.LDmax; extraCD(10)=c.deltaCDloiter;
m=nan(12,1); m(1)=m0; power=nan(11,1); available=power; CL=power; LD=power;
for i=1:11
    if i==6
        m(i+1)=m(i)-c.payload_kg;
        assert(m(i+1)>0,'ffstudio:Mission','Payload exceeds aircraft mass at release.');
    elseif isfinite(fractions(i))
        m(i+1)=m(i)*fractions(i);
    elseif strcmp(mode,'report')
        cp=sfc(i)/3.6e6;
        fractions(i)=exp(-duration(i)*speed(i)*cp*c.gravity/(c.propEfficiency*K(i)));
        m(i+1)=m(i)*fractions(i); LD(i)=K(i);
    else
        a=ffstudio.atmosphere(height(i),c.deltaISA_K); q=.5*a.rho_kgm3*speed(i)^2;
        cp=sfc(i)/3.6e6;
        aa=cp*q*S*(p.CD0+extraCD(i))*speed(i)/c.propEfficiency;
        bb=cp*p.k*c.gravity^2/(q*S)*speed(i)/c.propEfficiency;
        angleEnd=atan(m(i)*sqrt(bb/aa))-sqrt(aa*bb)*duration(i);
        assert(angleEnd>0,'ffstudio:Mission','Unphysical mass depletion during a flight segment.');
        m(i+1)=sqrt(aa/bb)*tan(angleEnd); fractions(i)=m(i+1)/m(i);
    end
    if isfinite(speed(i))
        a=ffstudio.atmosphere(height(i),c.deltaISA_K); q=.5*a.rho_kgm3*speed(i)^2;
        CL(i)=m(i)*c.gravity/(q*S); CD=p.CD0+extraCD(i)+p.k*CL(i)^2;
        power(i)=q*S*CD*speed(i)/(c.propEfficiency*1000);
        available(i)=m0*c.powerLoading_kWkg*min(1,a.sigma^c.powerLapseExponent);
        if strcmp(mode,'physics'), LD(i)=CL(i)/CD; end
    end
end
burn=m(1:11)-m(2:12); burn(6)=0;
assert(all(m>0)&&all(burn>=-1e-6),'ffstudio:Mission','Invalid mission mass history.');
r.stations_kg=m; r.burn_kg=sum(burn); r.fuel_kg=c.reserveFactor*r.burn_kg;
r.extraReserve_kg=r.fuel_kg-r.burn_kg; r.mode=mode;
r.table=table((0:10)',(1:11)',names,m(1:11),m(2:12),fractions,burn,duration, ...
    power,available,LD,CL,'VariableNames',{'From','To','Phase','Start_kg','End_kg', ...
    'MassFraction','FuelBurn_kg','Duration_s','RequiredPower_kW','AvailablePower_kW','LD','CL'});
r.note='Climb/ground/descent/landing retain empirical report fractions. Requested speeds are checked against power availability, not automatically reduced.';
end
