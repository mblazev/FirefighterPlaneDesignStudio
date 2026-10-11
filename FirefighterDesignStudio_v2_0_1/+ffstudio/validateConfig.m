function validateConfig(c)
%VALIDATECONFIG Explicit predicates handle numeric and logical values separately.
% No generic attribute validator is used: boolean range checks cannot trigger
% the logical-versus-numeric-bound failure seen in v1.
reference=ffstudio.defaultConfig;
must(isstruct(c)&&isscalar(c),'Configuration must be a scalar structure.');
names=fieldnames(reference);
for k=1:numel(names)
    name=names{k}; must(isfield(c,name),['Missing configuration field: ' name]);
    if isnumeric(reference.(name)) && isscalar(reference.(name))
        number(c.(name),name);
    end
end
must(c.schemaVersion==2,'Load scenario inputs saved for version 2.');
must((ischar(c.name)&&isrow(c.name))||(isstring(c.name)&&isscalar(c.name)), ...
    'name must be a text scalar.');
must(isstruct(c.dyn)&&isscalar(c.dyn),'dyn must be a scalar structure.');
names=fieldnames(reference.dyn);
for k=1:numel(names)
    name=names{k}; must(isfield(c.dyn,name),['Missing dynamics field: ' name]);
    if islogical(reference.dyn.(name))
        boolean(c.dyn.(name),['dyn.' name]);
    elseif isscalar(reference.dyn.(name))
        number(c.dyn.(name),['dyn.' name]);
    end
end
positive={'radius_km','cruise_kmh','drop_kmh','loiter_kmh','aspectRatio','oswald', ...
 'wettedRatio','KLD','wingLoading_Nm2','powerLoading_kWkg','propEfficiency', ...
 'sfcCruise_kgkWh','sfcLoiter_kgkWh','emptyA','emptyScale','sweepFactor','gravity', ...
 'CLmaxClean','CLmaxTakeoff','CLmaxLanding','tailArmH_m','tailArmV_m','VH','VV', ...
 'dropHeight_m','dropDuration_s','parcelDiameter_m','parcelCd','waterDensity_kgm3', ...
 'takeoffTarget_m','landingTarget_m','muBrake'};
for k=1:numel(positive), name=positive{k}; must(c.(name)>0,[name ' must be positive.']); end
nonnegative={'payload_kg','crew_kg','pattern_min','loiter_min','deltaCDpattern','deltaCDloiter', ...
 'cruiseAltitude_m','loiterAltitude_m','fieldAltitude_m','muRoll','powerLapseExponent', ...
 'climbTarget_ms','oeiGradient'};
for k=1:numel(nonnegative), name=nonnegative{k}; must(c.(name)>=0,[name ' must be nonnegative.']); end
must(c.propEfficiency<=1 && c.oswald<=1,'Efficiencies must be <= 1.');
must(c.reserveFactor>=1,'Reserve factor must be >= 1.');
must(c.emptyC>-1 && c.emptyC<0,'Empty exponent must be between -1 and 0.');
must(c.taper>0 && c.taper<=1,'Taper must be in (0,1].');
must(c.engineCount>=2 && c.engineCount==fix(c.engineCount),'Engine count must be an integer >= 2.');
must(c.releaseCount>=2 && c.releaseCount==fix(c.releaseCount),'Release count must be an integer >= 2.');
must(c.deltaISA_K>-80 && c.deltaISA_K<80,'Temperature offset must be between -80 and 80 K.');
must(all([c.cruiseAltitude_m c.loiterAltitude_m c.fieldAltitude_m c.dropHeight_m]<=11000), ...
    'Atmosphere model supports altitudes up to 11000 m.');
must(c.cgMin_MAC<c.cgMax_MAC,'Minimum CG limit must be below maximum.');
for name={'takeoffFraction','climbFraction','descentFraction','landingFraction'}
    v=c.(name{1}); must(v>0 && v<=1,[name{1} ' must be in (0,1].']);
end
vector3(c.windNED_ms,'windNED_ms'); vector3(c.dyn.radiusGyration_m,'dyn.radiusGyration_m');
must(all(c.dyn.radiusGyration_m>0),'Radii of gyration must be positive.');
must(c.dyn.dropStart_s>=0 && c.dyn.stopTime_s>0 && c.dyn.fuelFlow_kgs>=0, ...
    'Dynamics release time/fuel flow must be nonnegative and stop time positive.');
must(c.dyn.pulseStart_s>=0 && c.dyn.pulseDuration_s>=0,'Pulse times must be nonnegative.');
must(abs(c.dyn.Cmde)>1e-6,'Elevator pitch derivative must be nonzero.');
ratios={'aileronSpanFraction','aileronChordFraction','elevatorChordFraction','rudderChordFraction'};
for k=1:numel(ratios), name=ratios{k}; must(c.(name)>0 && c.(name)<=1,[name ' must be in (0,1].']); end
end

function number(v,name)
must(isnumeric(v)&&isscalar(v)&&isreal(v)&&isfinite(v), ...
    [name ' must be a finite real numeric scalar.']);
end
function vector3(v,name)
must(isnumeric(v)&&isvector(v)&&numel(v)==3&&isreal(v)&&all(isfinite(v)), ...
    [name ' must have three finite real numeric elements.']);
end
function boolean(v,name)
must((islogical(v)||isnumeric(v))&&isscalar(v)&&isreal(v)&&(v==0||v==1), ...
    [name ' must be logical true/false or numeric 0/1.']);
end
function must(ok,message)
if ~ok, error('ffstudio:Input','%s',message); end
end
