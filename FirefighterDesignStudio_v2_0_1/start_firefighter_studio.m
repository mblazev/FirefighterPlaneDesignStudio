function app = start_firefighter_studio
%START_FIREFIGHTER_STUDIO Launch the rebuilt, separately named v2 package.
root = fileparts(mfilename('fullpath')); addpath(root,'-begin');
resolved = which('ffstudio.defaultConfig');
expected = fullfile(root,'+ffstudio','defaultConfig.m');
assert(strcmpi(resolved,expected),'ffstudio:Path', ...
    'MATLAB resolved another studio copy at %s. Run LAUNCH_STUDIO from this folder.',resolved);
info = ffstudio.releaseInfo;
fprintf('\nFirefighter Design Studio %s\nLoaded from: %s\n',info.version,root);
c = ffstudio.defaultConfig;
ffstudio.validateConfig(c);
fprintf('Input validation passed (including logical true/false).\n');
app = ffstudio.dashboard(c);
end
