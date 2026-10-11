function t=loadDatabase(path)
if nargin<1
    info=ffstudio.releaseInfo; path=fullfile(info.root,'data','aircraft_database.csv');
end
t=readtable(path,'TextType','string');
required={'ID','Aircraft','Year','Class','Power_kW','Payload_kg','MTOW_kg', ...
    'Empty_kg','WingArea_m2','Span_m','Cruise_kmh','Range_km','Source'};
assert(all(ismember(required,t.Properties.VariableNames)),'ffstudio:Database','Missing required CSV columns.');
assert(all(t.MTOW_kg>0 & t.WingArea_m2>0 & t.Span_m>0),'ffstudio:Database','Invalid mass/geometry data.');
t.AspectRatio=t.Span_m.^2./t.WingArea_m2;
t.WingLoading_Nm2=t.MTOW_kg*9.81./t.WingArea_m2;
t.PowerLoading_kWkg=t.Power_kW./t.MTOW_kg;
t.PayloadFraction=t.Payload_kg./t.MTOW_kg; t.EmptyFraction=t.Empty_kg./t.MTOW_kg;
t.TrendEligible=t.Class=="Land twin";
t.EmptyEligible=ismember(t.Class,["Land twin","Four engine"])&isfinite(t.Empty_kg);
end
