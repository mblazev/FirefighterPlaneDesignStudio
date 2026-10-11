function r=dropFootprint(c)
ffstudio.validateConfig(c); a=ffstudio.atmosphere(c.dropHeight_m,c.deltaISA_K);
beta=3*a.rho_kgm3*c.parcelCd/(4*c.waterDensity_kgm3*c.parcelDiameter_m);
release=linspace(0,c.dropDuration_s,c.releaseCount)'; impact=zeros(numel(release),3);
fall=zeros(numel(release),1); paths=cell(numel(release),1);
options=odeset('Events',@ground,'RelTol',1e-6,'AbsTol',1e-7);
for k=1:numel(release)
    x0=[release(k)*c.drop_kmh/3.6;0;-c.dropHeight_m;c.drop_kmh/3.6;0;c.releaseDown_ms];
    [t,x,te,xe]=ode45(@ode,[0 120],x0,options);
    assert(~isempty(te),'ffstudio:Drop','Parcel did not reach ground within 120 s.');
    impact(k,:)=xe(end,1:3); fall(k)=te(end); paths{k}=[t x];
end
r.impacts=table(release,impact(:,1),impact(:,2),fall, ...
    'VariableNames',{'Release_s','North_m','East_m','FallTime_s'});
r.paths=paths; r.releaseRate_kgs=c.payload_kg/c.dropDuration_s;
r.length_m=max(impact(:,1))-min(impact(:,1)); r.meanDrift_m=mean(impact(:,2));
r.releaseLead_m=impact(1,1);
r.note='Spherical ballistic parcels only: no breakup, evaporation or calibrated spread. Impact points cannot establish effective coverage in litres/m2.';
    function dx=ode(~,x)
        rel=x(4:6)-c.windNED_ms(:);
        dx=[x(4:6);[0;0;c.gravity]-beta*norm(rel)*rel];
    end
    function [v,stop,dir]=ground(~,x)
        v=x(3); stop=1; dir=1;
    end
end
