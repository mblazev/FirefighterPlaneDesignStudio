function r=sizeAircraft(c,mode)
if nargin<2, mode='report'; end
ffstudio.validateConfig(c);
grid=linspace(max(5000,c.payload_kg+c.crew_kg+1000),180000,60);
values=arrayfun(@residual,grid);
idx=find(values(1:end-1).*values(2:end)<0,1);
assert(~isempty(idx),'ffstudio:Sizing','No mass closure below 180 tonnes for these inputs.');
m0=fzero(@residual,[grid(idx) grid(idx+1)],optimset('TolX',1e-5));
mis=ffstudio.mission(c,m0,mode);
r.mtow_kg=m0; r.fuel_kg=mis.fuel_kg;
r.empty_kg=c.emptyA*m0^(1+c.emptyC)*c.emptyScale*c.sweepFactor;
r.payload_kg=c.payload_kg; r.crew_kg=c.crew_kg;
r.emptyFraction=r.empty_kg/m0; r.payloadFraction=c.payload_kg/m0; r.fuelFraction=r.fuel_kg/m0;
r.wingArea_m2=m0*c.gravity/c.wingLoading_Nm2; r.span_m=sqrt(c.aspectRatio*r.wingArea_m2);
r.installedPower_kW=m0*c.powerLoading_kWkg; r.perEnginePower_kW=r.installedPower_kW/c.engineCount;
r.residual_kg=residual(m0); r.mission=mis; r.mode=mode;
r.iteration=table(grid',values','VariableNames',{'AssumedMTOW_kg','ClosureResidual_kg'});
    function v=residual(mass)
        try
            mm=ffstudio.mission(c,mass,mode);
            v=mass-mm.fuel_kg-c.payload_kg-c.crew_kg- ...
                c.emptyA*mass^(1+c.emptyC)*c.emptyScale*c.sweepFactor;
        catch err
            if strcmp(err.identifier,'ffstudio:Mission'), v=-1e9; else, rethrow(err); end
        end
    end
end
