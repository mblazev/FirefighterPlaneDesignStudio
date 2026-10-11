function results = analyze_firefighter(folder)
root=fileparts(mfilename('fullpath')); addpath(root,'-begin');
if nargin<1, folder=fullfile(root,'results'); end
c=ffstudio.defaultConfig;
results=ffstudio.analyze(c);
results.sensitivity=ffstudio.sensitivity(c);
results.uncertainty=ffstudio.uncertainty(c,150,42);
ffstudio.exportReport(results,folder);
save(fullfile(folder,'analysis.mat'),'results');
fprintf('Report method: %.0f kg MTOW, %.0f kg fuel.\n',results.report.mtow_kg,results.report.fuel_kg);
fprintf('Actual-speed fuel: %.0f kg MTOW, %.0f kg fuel.\n',results.physics.mtow_kg,results.physics.fuel_kg);
fprintf('Saved to %s\n',folder);
end
