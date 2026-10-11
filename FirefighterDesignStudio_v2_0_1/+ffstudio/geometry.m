function r=geometry(c,d)
r.wingArea_m2=d.wingArea_m2; r.span_m=d.span_m;
r.rootChord_m=2*d.wingArea_m2/(d.span_m*(1+c.taper)); r.tipChord_m=c.taper*r.rootChord_m;
r.MAC_m=2/3*r.rootChord_m*(1+c.taper+c.taper^2)/(1+c.taper);
r.MACspanStation_m=d.span_m/6*(1+2*c.taper)/(1+c.taper);
r.horizontalTail_m2=c.VH*d.wingArea_m2*r.MAC_m/c.tailArmH_m;
r.verticalTail_m2=c.VV*d.wingArea_m2*d.span_m/c.tailArmV_m;
r.aileronSpanEach_m=c.aileronSpanFraction*d.span_m/2;
r.aileronChordAtMAC_m=c.aileronChordFraction*r.MAC_m;
r.elevatorChordFraction=c.elevatorChordFraction; r.rudderChordFraction=c.rudderChordFraction;
r.dihedral_deg=c.dihedral_deg;
r.tankVolume_m3=c.payload_kg/c.waterDensity_kgm3;
r.note='Tail/control geometry is preliminary. No measured neutral point, downwash or stability derivatives supplied.';
end
