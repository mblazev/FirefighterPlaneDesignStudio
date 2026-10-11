function s=prepareDynamics(c,d)
%PREPAREDYNAMICS Level-flight trim at the start of the water-release leg.
ffstudio.validateConfig(c);
assert(exist('angle2dcm','file')==2,'ffstudio:Toolbox','Aerospace Toolbox angle2dcm is required.');
if nargin<2, d=ffstudio.sizeAircraft(c,'report'); end
s.config=c; s.design=d; s.polar=ffstudio.polar(c); s.geometry=ffstudio.geometry(c,d);
s.initialMass_kg=d.mission.stations_kg(6); s.targetSpeed_ms=c.drop_kmh/3.6; s.targetHeight_m=c.dropHeight_m;
a=ffstudio.atmosphere(c.dropHeight_m,c.deltaISA_K); q=.5*a.rho_kgm3*s.targetSpeed_ms^2;
required=s.initialMass_kg*c.gravity/(q*d.wingArea_m2);
A=[c.dyn.CLa c.dyn.CLde;c.dyn.Cma c.dyn.Cmde];
assert(abs(det(A))>1e-7,'ffstudio:Trim','Aerodynamic trim equations are singular.');
linear=A\[required-c.dyn.CL0-c.dyn.flapCL0;-c.dyn.Cm0];
alpha=fzero(@balance,linear(1)); de=-(c.dyn.Cm0+c.dyn.Cma*alpha)/c.dyn.Cmde;
CL=c.dyn.CL0+c.dyn.flapCL0+c.dyn.CLa*alpha+c.dyn.CLde*de;
CD=s.polar.CD0+c.deltaCDpattern+s.polar.k*CL^2;
assert(abs(alpha)<20*pi/180&&abs(de)<25*pi/180&&CL<=c.CLmaxLanding, ...
    'ffstudio:Trim','Drop trim exceeds assumed angle, elevator or lift limits.');
drag=q*d.wingArea_m2*CD; thrust=drag/cos(alpha);
available=d.installedPower_kW*1000*min(1,a.sigma^c.powerLapseExponent);
throttle=thrust*s.targetSpeed_ms/(c.propEfficiency*available);
assert(throttle<=1,'ffstudio:Trim','Available power cannot trim the drop leg.');
s.trimAlpha_rad=alpha; s.trimElevator_rad=de; s.trimThrottle=throttle;
s.initialEuler_rad=[0 alpha 0]; C=angle2dcm(0,alpha,0);
s.initialVelocityBody_ms=([s.targetSpeed_ms*cos(alpha);0;s.targetSpeed_ms*sin(alpha)]+C*c.windNED_ms(:))';
s.initialPositionNED_m=[0 0 -c.dropHeight_m]; s.initialRates_rads=[0 0 0];
    function y=balance(aa)
        ee=-(c.dyn.Cm0+c.dyn.Cma*aa)/c.dyn.Cmde;
        lift=c.dyn.CL0+c.dyn.flapCL0+c.dyn.CLa*aa+c.dyn.CLde*ee;
        dragCD=s.polar.CD0+c.deltaCDpattern+s.polar.k*lift^2;
        y=lift+dragCD*tan(aa)-required;
    end
end
