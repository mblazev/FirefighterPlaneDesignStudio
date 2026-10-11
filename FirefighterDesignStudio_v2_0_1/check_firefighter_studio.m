function report=check_firefighter_studio(smokeGUI,includeSimulink)
%CHECK_FIREFIGHTER_STUDIO Run regression tests and optional application checks.
% check_firefighter_studio          numerical + validation tests
% check_firefighter_studio(true)    also open, recompute and close the dashboard
% check_firefighter_studio(true,true) also build and run a 1-second 6DOF model
if nargin<1, smokeGUI=false; end
if nargin<2, includeSimulink=false; end
root=fileparts(mfilename('fullpath')); addpath(root,'-begin');
info=ffstudio.releaseInfo; fprintf('Checking Firefighting Studio v%s\n%s\n',info.version,root);
assert(strcmpi(which('ffstudio.defaultConfig'),fullfile(root,'+ffstudio','defaultConfig.m')), ...
    'ffstudio:Path','Another v2 package is ahead of this folder on the MATLAB path.');
report.tests=runtests(fullfile(root,'tests'));
assert(~isempty(report.tests),'ffstudio:Tests','No regression tests were discovered.');
assertSuccess(report.tests);
c=ffstudio.defaultConfig; report.validation='passed';
if smokeGUI
    app=ffstudio.dashboard(c); done=onCleanup(@()delete(app.Figure)); drawnow;
    r=getappdata(app.Figure,'FirefighterResults');
    assert(~isempty(r)&&isstruct(r),'ffstudio:GUI','Dashboard did not complete its initial calculation.');
    data=app.InputTable.Data;
    for i=1:size(data,1)
        if strcmp(data{i,1},'dyn.engineOut'), data{i,2}='1'; end
        if strcmp(data{i,1},'dyn.autopilot'), data{i,2}='0'; end
    end
    app.InputTable.Data=data; app.Recompute(); drawnow;
    r=getappdata(app.Figure,'FirefighterResults');
    assert(r.config.dyn.engineOut && ~r.config.dyn.autopilot,'ffstudio:GUI','Boolean editor round trip failed.');
    report.GUI='passed'; clear done;
else
    report.GUI='not requested';
end
if includeSimulink
    c.dyn.stopTime_s=1; d=ffstudio.sizeAircraft(c,'report');
    s=ffstudio.prepareDynamics(c,d);
    loads=ffstudio.forces(0,s.initialVelocityBody_ms,s.initialEuler_rad,[0 0 0],s.initialPositionNED_m,s);
    assert(norm(loads(1:6))<1e-5,'ffstudio:Trim','Initial force/moment balance failed.');
    tempFolder=tempname; mkdir(tempFolder);
    path=ffstudio.buildSimulink(c,tempFolder,d); report.flight=ffstudio.simulate6dof(c,path,d);
    assert(all(isfinite(report.flight.table{:,1:14}),'all'),'ffstudio:Simulation','Nonfinite flight state.');
    assert(report.flight.quaternionNormError<1e-3,'ffstudio:Simulation','Quaternion norm drift exceeded tolerance.');
    assert(~report.flight.groundContact,'ffstudio:Simulation','Ground contact during short trim check.');
    close_system('ffstudio_v2_6dof',0); report.Simulink='passed';
    fprintf('Optional test model saved in %s\n',tempFolder);
else
    report.Simulink='not requested';
end
fprintf('All requested checks passed. GUI: %s. Simulink: %s.\n',report.GUI,report.Simulink);
end
