% Select this folder in MATLAB and press Run, or enter LAUNCH_STUDIO.
studioRoot = fileparts(mfilename('fullpath'));
addpath(studioRoot,'-begin');
studioApp = start_firefighter_studio;
