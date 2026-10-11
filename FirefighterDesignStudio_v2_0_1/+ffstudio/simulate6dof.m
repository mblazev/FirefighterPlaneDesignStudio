function r=simulate6dof(c,path,d)
%SIMULATE6DOF Run a local release-leg experiment in normal simulation mode.
if nargin<1, c=ffstudio.defaultConfig; end
if nargin<2, path=''; end
if nargin<3, d=ffstudio.sizeAircraft(c,'report'); end
s=ffstudio.prepareDynamics(c,d); info=ffstudio.releaseInfo; addpath(info.root,'-begin');
if isempty(path)||~exist(path,'file'), path=ffstudio.buildSimulink(c,fullfile(info.root,'models'),d); end
load_system(path); [~,model]=fileparts(path);
input=Simulink.SimulationInput(model);
input=input.setVariable('ffStudioSimConfig',s,'Workspace',model);
input=input.setModelParameter('StopTime',num2str(c.dyn.stopTime_s,16),'SimulationMode','normal', ...
    'ReturnWorkspaceOutputs','on');
input=input.setBlockParameter([model '/Aircraft'],'xme_0',mat2str(s.initialPositionNED_m,16), ...
    'Vm_0',mat2str(s.initialVelocityBody_ms,16),'eul_0',mat2str(s.initialEuler_rad,16),'pm_0',mat2str(s.initialRates_rads,16));
raw=sim(input); pos=raw.get('PositionNED'); time=pos.Time;
x=seriesData(pos,3); e=seriesData(raw.get('Euler'),3); vb=seriesData(raw.get('VelocityBody'),3);
omega=seriesData(raw.get('BodyRates'),3); quat=seriesData(raw.get('Quaternion'),4);
N=numel(time); diagnostics=zeros(N,7);
for i=1:N
    [~,a]=ffstudio.forces(time(i),vb(i,:),e(i,:),omega(i,:),x(i,:),s);
    diagnostics(i,:)=[a.speed_ms a.mass_kg a.water_kg a.alpha_deg a.throttle a.CLraw a.elevator_deg];
end
r.table=table(time,x(:,1),x(:,2),-x(:,3),diagnostics(:,1)*3.6,e(:,1)*180/pi,e(:,2)*180/pi,e(:,3)*180/pi, ...
    diagnostics(:,2),diagnostics(:,3),diagnostics(:,4),diagnostics(:,5),diagnostics(:,6),diagnostics(:,7), ...
    'VariableNames',{'Time_s','North_m','East_m','Height_m','Speed_kmh','Roll_deg','Pitch_deg','Yaw_deg', ...
    'Mass_kg','Water_kg','Alpha_deg','Throttle','CLraw','Elevator_deg'});
r.quaternionNormError=max(abs(sqrt(sum(quat.^2,2))-1)); r.groundContact=any(-x(:,3)<=0);
r.modelPath=path; r.raw=raw; r.trim=s;
r.notes=["Release leg only; assumed aerodynamic derivatives, inertia and feedback gains."; ...
    string(sprintf('Quaternion norm error %.3g; minimum height %.2f m; final speed %.1f km/h.', ...
    r.quaternionNormError,min(r.table.Height_m),r.table.Speed_kmh(end))); ...
    "Water mass changes over the prescribed release duration. No outlet reaction force or moving CG/inertia redistribution is resolved."];
if any(abs(r.table.CLraw)>c.CLmaxLanding), r.notes(end+1,1)="Assumed lift limit was reached during this experiment."; end
if r.groundContact, r.notes(end+1,1)="Simulation stopped at ground contact."; end
end
function y=seriesData(ts,width)
y=squeeze(ts.Data); n=numel(ts.Time);
if n==1, y=reshape(y,1,width);
elseif size(y,1)~=n && size(y,2)==n, y=y'; end
assert(isequal(size(y),[n width]),'ffstudio:Simulation','Unexpected logged signal shape.');
end
