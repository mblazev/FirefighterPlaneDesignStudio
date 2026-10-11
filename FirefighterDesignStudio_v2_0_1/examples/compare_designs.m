% Compare a design with the reference sizing and power assumption.
root=fileparts(fileparts(mfilename('fullpath'))); addpath(root,'-begin');
c=ffstudio.defaultConfig; baseline=ffstudio.analyze(c);
candidate=c; candidate.cruise_kmh=500; candidate.powerLoading_kWkg=.27;
revised=ffstudio.analyze(candidate);
disp(baseline.comparison); disp(revised.comparison);
fprintf('Baseline loaded cruise power margin: %.0f kW\n',baseline.performance.cruiseAvailable_kW-baseline.performance.cruisePower_kW);
fprintf('Candidate loaded cruise power margin: %.0f kW\n',revised.performance.cruiseAvailable_kW-revised.performance.cruisePower_kW);
ffstudio.exportReport(revised,fullfile(root,'results','candidate'));
