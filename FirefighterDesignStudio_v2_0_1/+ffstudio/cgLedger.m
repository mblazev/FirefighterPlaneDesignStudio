function r=cgLedger(c,d)
mass=d.mission.stations_kg; water=c.payload_kg*ones(12,1); water(7:end)=0;
fuel=mass-d.empty_kg-c.crew_kg-water;
assert(all(fuel>=-.01),'ffstudio:CG','Inconsistent fuel ledger.');
cg=(d.empty_kg*c.cgEmpty_MAC+c.crew_kg*c.cgCrew_MAC+fuel*c.cgFuel_MAC+water*c.cgWater_MAC)./mass;
r.table=table((0:11)',mass,water,fuel,cg,cg>=c.cgMin_MAC&cg<=c.cgMax_MAC, ...
    'VariableNames',{'Station','Total_kg','Water_kg','Fuel_kg','CG_MAC','WithinAssumedLimits'});
r.dropShift_MAC=cg(7)-cg(6);
r.note='Assumed CG stations and limits; static stability requires measured aerodynamic data.';
end
