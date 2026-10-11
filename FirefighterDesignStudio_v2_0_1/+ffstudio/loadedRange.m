function km=loadedRange(c,d)
p=ffstudio.polar(c); start=d.mtow_kg*c.takeoffFraction*c.climbFraction;
final=d.empty_kg+c.crew_kg+c.payload_kg+d.mission.extraReserve_kg;
beforeLanding=final/c.landingFraction;
if strcmp(d.mode,'report')
    loiter=exp(-c.loiter_min*60*c.loiter_kmh/3.6*c.sfcLoiter_kgkWh/3.6e6* ...
        c.gravity/(c.propEfficiency*.866*p.LDmax));
    endCruise=beforeLanding/loiter/c.descentFraction;
    km=max(0,log(start/endCruise)*c.propEfficiency*p.LDmax/(c.sfcCruise_kgkWh/3.6e6*c.gravity)/1000);
else
    [aa,bb]=coeff(c.loiter_kmh/3.6,c.loiterAltitude_m,c.sfcLoiter_kgkWh,c.deltaCDloiter);
    angle=atan(beforeLanding*sqrt(bb/aa))+sqrt(aa*bb)*c.loiter_min*60;
    if angle>=pi/2, km=0; return; end
    endCruise=sqrt(aa/bb)*tan(angle)/c.descentFraction;
    [aa,bb]=coeff(c.cruise_kmh/3.6,c.cruiseAltitude_m,c.sfcCruise_kgkWh,0);
    duration=(atan(start*sqrt(bb/aa))-atan(endCruise*sqrt(bb/aa)))/sqrt(aa*bb);
    km=max(0,duration*c.cruise_kmh/3.6/1000);
end
    function [aa,bb]=coeff(V,h,sfc,extraCD)
        a=ffstudio.atmosphere(h,c.deltaISA_K); q=.5*a.rho_kgm3*V^2; cp=sfc/3.6e6;
        aa=cp*q*d.wingArea_m2*(p.CD0+extraCD)*V/c.propEfficiency;
        bb=cp*p.k*c.gravity^2/(q*d.wingArea_m2)*V/c.propEfficiency;
    end
end
