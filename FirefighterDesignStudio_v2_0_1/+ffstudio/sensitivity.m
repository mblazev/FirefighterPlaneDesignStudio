function r=sensitivity(c)
spec={'radius_km',linspace(200,1000,17);'emptyScale',linspace(.9,1.1,17); ...
 'aspectRatio',linspace(8,15,17);'sfcCruise_kgkWh',linspace(.24,.38,17); ...
 'payload_kg',linspace(3000,9000,17)};
for j=1:size(spec,1)
    x=spec{j,2}; mass=nan(size(x)); fuel=mass;
    for k=1:numel(x)
        cc=c; cc.(spec{j,1})=x(k);
        try
            d=ffstudio.sizeAircraft(cc,'report'); mass(k)=d.mtow_kg; fuel(k)=d.fuel_kg;
        catch err
            if ~strcmp(err.identifier,'ffstudio:Sizing'), rethrow(err); end
        end
    end
    r.(spec{j,1})=table(x',mass',fuel','VariableNames',{'Input','MTOW_kg','Fuel_kg'});
end
r.note='One variable at a time, using report-method L/D fractions.';
end
