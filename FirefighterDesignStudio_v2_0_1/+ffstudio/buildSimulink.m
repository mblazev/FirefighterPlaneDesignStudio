function path=buildSimulink(c,folder,d)
%BUILDSIMULINK Build the R2026b Aerospace Blockset flight experiment.
info=ffstudio.releaseInfo; addpath(info.root,'-begin');
if nargin<1, c=ffstudio.defaultConfig; end
if nargin<2||isempty(folder), folder=fullfile(info.root,'models'); end
if nargin<3, d=ffstudio.sizeAircraft(c,'report'); end
ffstudio.validateConfig(c);
% Simulink commands can be built-ins, MEX or P-code. File type is not a
% reliable installation or license check: try the real library operations.
try
    load_system('simulink');
catch cause
    problem=MException('ffstudio:SimulinkLoad', ...
        'Simulink could not initialize. MATLAB reported: %s',cause.message);
    problem=addCause(problem,cause); throwAsCaller(problem);
end
try
    load_system('aerolib6dof2');
catch cause
    problem=MException('ffstudio:AerospaceBlocksetLoad', ...
        'The Aerospace Blockset 6DOF library could not load. MATLAB reported: %s',cause.message);
    problem=addCause(problem,cause); throwAsCaller(problem);
end
s=ffstudio.prepareDynamics(c,d);
if ~exist(folder,'dir'), mkdir(folder); end
model='ffstudio_v2_6dof'; path=fullfile(folder,[model '.slx']);
if bdIsLoaded(model)
    assert(strcmp(get_param(model,'Dirty'),'off'),'ffstudio:Model','Save or close the edited 6DOF model before rebuilding.');
    close_system(model,0);
end
if exist(path,'file')
    backups=fullfile(folder,'backups'); if ~exist(backups,'dir'), mkdir(backups); end
    copyfile(path,fullfile(backups,[model '_' char(datetime('now','Format','yyyyMMdd_HHmmss_SSS')) '.slx']));
end
new_system(model);
cleanup=onCleanup(@()closeFailed(model));
ws=get_param(model,'ModelWorkspace'); assignin(ws,'ffStudioSimConfig',s);
set_param(model,'Solver','ode45','MaxStep','0.02','RelTol','1e-6','AbsTol','1e-7', ...
    'StopTime',num2str(c.dyn.stopTime_s,16),'SimulationMode','normal','ReturnWorkspaceOutputs','on');
add_block('simulink/Sources/Clock',[model '/Time'],'Position',[30 35 60 55]);
add_block('simulink/User-Defined Functions/Level-2 MATLAB S-Function',[model '/Loads'], ...
    'FunctionName','ffstudio_forces_sfun','Parameters','ffStudioSimConfig','Position',[140 110 290 270]);
add_block('simulink/Signal Routing/Demux',[model '/SeparateLoads'], ...
    'Outputs','[3 3 1 9 9]','Position',[335 100 340 300]);
add_block('aerolib6dof2/Custom Variable Mass 6DOF (Quaternion)',[model '/Aircraft'], ...
    'mtype','Custom Variable','units','Metric (MKS)','vre_flag','off', ...
    'xme_0',mat2str(s.initialPositionNED_m,16),'Vm_0',mat2str(s.initialVelocityBody_ms,16), ...
    'eul_0',mat2str(s.initialEuler_rad,16),'pm_0',mat2str(s.initialRates_rads,16), ...
    'Position',[535 100 750 355]);
add_block('simulink/Math Operations/Reshape',[model '/InertiaRate'], ...
    'OutputDimensionality','Customize','OutputDimensions','[3 3]','Position',[395 250 465 275]);
add_block('simulink/Math Operations/Reshape',[model '/Inertia'], ...
    'OutputDimensionality','Customize','OutputDimensions','[3 3]','Position',[395 290 465 315]);
connect('Time/1','Loads/1'); connect('Loads/1','SeparateLoads/1');
for i=1:3, connect(sprintf('SeparateLoads/%d',i),sprintf('Aircraft/%d',i)); end
connect('SeparateLoads/4','InertiaRate/1'); connect('InertiaRate/1','Aircraft/4');
connect('SeparateLoads/5','Inertia/1'); connect('Inertia/1','Aircraft/5');
connect('Aircraft/6','Loads/2'); connect('Aircraft/3','Loads/3'); connect('Aircraft/7','Loads/4'); connect('Aircraft/2','Loads/5');
names={'VelocityEarth','PositionNED','Euler','Quaternion','DCM','VelocityBody','BodyRates'};
for i=1:numel(names)
    add_block('simulink/Sinks/To Workspace',[model '/' names{i}], ...
        'VariableName',names{i},'SaveFormat','Timeseries','Position',[860 40+i*45 985 65+i*45]);
    connect(sprintf('Aircraft/%d',i),[names{i} '/1']);
end
add_block('simulink/Sinks/To Workspace',[model '/MassHistory'], ...
    'VariableName','MassHistory','SaveFormat','Timeseries','Position',[535 410 660 435]);
connect('SeparateLoads/3','MassHistory/1');
add_block('simulink/Signal Routing/Selector',[model '/DownPosition'], ...
    'NumberOfDimensions','1','InputPortWidth','3','IndexOptionArray',{'Index vector (dialog)'}, ...
    'Indices','3','Position',[795 435 865 460]);
add_block('simulink/Logic and Bit Operations/Compare To Constant',[model '/AtGround'], ...
    'relop','>=','const','0','Position',[895 435 965 460]);
add_block('simulink/Sinks/Stop Simulation',[model '/StopAtGround'],'Position',[1000 435 1040 460]);
connect('Aircraft/2','DownPosition/1'); connect('DownPosition/1','AtGround/1'); connect('AtGround/1','StopAtGround/1');
note=Simulink.Annotation(model,['Preliminary water-release flight experiment: NED / body axes, variable mass and inertia.' newline ...
    'Gravity is included in Loads. No mass-flow relative velocity, jet reaction, calibrated aero or certified control law.']);
note.Position=[50 490 1000 550];
% Opening the saved model also makes the MATLAB package available.
callback=['addpath(fileparts(fileparts(get_param(''' model ''',''FileName''))),''-begin'');'];
set_param(model,'PostLoadFcn',callback);
set_param(model,'SimulationCommand','update'); save_system(model,path);
clear cleanup;
    function connect(from,to), add_line(model,from,to,'autorouting','on'); end
end
function closeFailed(model)
if bdIsLoaded(model) && (isempty(get_param(model,'FileName'))||strcmp(get_param(model,'Dirty'),'on'))
    close_system(model,0);
end
end
