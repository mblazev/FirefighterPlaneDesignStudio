% Three assumed-data release-leg experiments; requires Simulink and aerospace products.
root=fileparts(fileparts(mfilename('fullpath'))); addpath(root,'-begin');
c=ffstudio.defaultConfig; c.dyn.stopTime_s=20;
baselineFlight=ffstudio.simulate6dof(c);
pulse=c; pulse.dyn.elevatorPulse_deg=-2; pulseFlight=ffstudio.simulate6dof(pulse,baselineFlight.modelPath);
oei=c; oei.dyn.engineOut=true; engineOutFlight=ffstudio.simulate6dof(oei,baselineFlight.modelPath);
figure; tiledlayout(1,2);
nexttile; plot(baselineFlight.table.Time_s,baselineFlight.table.Height_m, ...
    pulseFlight.table.Time_s,pulseFlight.table.Height_m,engineOutFlight.table.Time_s,engineOutFlight.table.Height_m);
xlabel('Time (s)'); ylabel('Height (m)'); legend('Baseline','Elevator pulse','Engine out'); grid on;
nexttile; plot(baselineFlight.table.Time_s,baselineFlight.table.Speed_kmh, ...
    pulseFlight.table.Time_s,pulseFlight.table.Speed_kmh,engineOutFlight.table.Time_s,engineOutFlight.table.Speed_kmh);
xlabel('Time (s)'); ylabel('TAS (km/h)'); grid on;
disp(engineOutFlight.notes);
