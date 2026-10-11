function [out,diag]=forces(t,vbody,euler,omega,position,s)
%FORCES Body F/M, current mass, inertia derivative and inertia for 6DOF.
% NED earth axes; body x forward, y right, z down; Euler [roll pitch yaw].
c=s.config; dyn=c.dyn; g=c.gravity; S=s.design.wingArea_m2; b=s.design.span_m; mac=s.geometry.MAC_m;
euler=euler(:); omega=omega(:); position=position(:);
C=angle2dcm(euler(3),euler(2),euler(1));
vair=vbody(:)-C*c.windNED_ms(:); V=max(norm(vair),5);
alpha=atan2(vair(3),vair(1)); beta=asin(max(-1,min(1,vair(2)/V)));
height=-position(3); a=ffstudio.atmosphere(max(0,min(11000,height)),c.deltaISA_K); q=.5*a.rho_kgm3*V^2;
elapsed=max(0,min(c.dropDuration_s,t-dyn.dropStart_s)); water=c.payload_kg*(1-elapsed/c.dropDuration_s);
floorMass=s.design.empty_kg+c.crew_kg;
mass=max(floorMass,s.initialMass_kg-c.payload_kg+water-dyn.fuelFlow_kgs*t);
mdot=-dyn.fuelFlow_kgs;
if t>=dyn.dropStart_s && t<dyn.dropStart_s+c.dropDuration_s, mdot=mdot-c.payload_kg/c.dropDuration_s; end
if mass<=floorMass, mdot=0; end
I=diagMatrix(mass*dyn.radiusGyration_m.^2); dI=diagMatrix(mdot*dyn.radiusGyration_m.^2);
de=s.trimElevator_rad; da=0; dr=0; throttle=s.trimThrottle;
if dyn.autopilot
    command=s.trimAlpha_rad+clip(dyn.heightGain*(s.targetHeight_m-height),-.10,.10);
    de=de-dyn.pitchGain*(command-euler(2))+dyn.pitchRateGain*omega(2);
    da=-dyn.rollGain*euler(1)-dyn.rollRateGain*omega(1); dr=dyn.yawRateGain*omega(3);
    throttle=throttle+dyn.speedGain*(s.targetSpeed_ms-V);
end
if t>=dyn.pulseStart_s && t<dyn.pulseStart_s+dyn.pulseDuration_s, de=de+dyn.elevatorPulse_deg*pi/180; end
de=clip(de,-25*pi/180,25*pi/180); da=clip(da,-20*pi/180,20*pi/180); dr=clip(dr,-25*pi/180,25*pi/180); throttle=clip(throttle,0,1);
phat=omega(1)*b/(2*V); qhat=omega(2)*mac/(2*V); rhat=omega(3)*b/(2*V);
CLraw=dyn.CL0+dyn.flapCL0+dyn.CLa*alpha+dyn.CLde*de+dyn.CLq*qhat;
CL=clip(CLraw,-c.CLmaxLanding,c.CLmaxLanding); CD=s.polar.CD0+c.deltaCDpattern+s.polar.k*CL^2;
CY=dyn.CYb*beta+dyn.CYdr*dr;
Cl=dyn.Clb*beta+dyn.Clp*phat+dyn.Clda*da; Cm=dyn.Cm0+dyn.Cma*alpha+dyn.Cmde*de+dyn.Cmq*qhat;
Cn=dyn.Cnb*beta+dyn.Cnr*rhat+dyn.Cndr*dr;
P=s.design.installedPower_kW*1000*min(1,a.sigma^c.powerLapseExponent)*throttle;
if dyn.engineOut, P=P*(c.engineCount-1)/c.engineCount; end
T=min(c.propEfficiency*P/V,.35*mass*g); D=q*S*CD; L=q*S*CL;
F=[T-D*cos(alpha)+L*sin(alpha);q*S*CY;-D*sin(alpha)-L*cos(alpha)]+C*[0;0;mass*g];
M=q*S*[b*Cl;mac*Cm;b*Cn];
if dyn.engineOut, M(3)=M(3)+T*b*.20/(c.engineCount-1); end
out=[F;M;mass;dI(:);I(:)];
diag=struct('speed_ms',V,'height_m',height,'alpha_deg',alpha*180/pi, ...
    'CLraw',CLraw,'throttle',throttle,'elevator_deg',de*180/pi,'water_kg',water,'mass_kg',mass,'groundContact',height<=0);
end
function v=clip(v,lo,hi), v=max(lo,min(hi,v)); end
function I=diagMatrix(v), I=diag(v); end
