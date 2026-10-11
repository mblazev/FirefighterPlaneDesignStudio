function c = defaultConfig
%DEFAULTCONFIG Report inputs plus explicitly preliminary engineering inputs.
c.schemaVersion=2;
c.name='Blazhevski 6000 kg land-based firefighter';
c.designYear=2036; c.payload_kg=6000; c.crew_kg=200;
c.radius_km=700; c.cruise_kmh=580; c.cruiseAltitude_m=5500;
c.drop_kmh=220; c.dropHeight_m=40; c.pattern_min=10;
c.loiter_min=45; c.loiter_kmh=300; c.loiterAltitude_m=1500;
c.aspectRatio=11.5; c.oswald=0.80; c.wettedRatio=5.5; c.KLD=11;
c.wingLoading_Nm2=3500; c.powerLoading_kWkg=0.230;
c.propEfficiency=0.80; c.sfcCruise_kgkWh=0.30; c.sfcLoiter_kgkWh=0.36;
c.takeoffFraction=0.970; c.climbFraction=0.985;
c.descentFraction=0.995; c.landingFraction=0.995;
c.reserveFactor=1.06; c.emptyA=1.442; c.emptyC=-0.0947;
c.emptyScale=1; c.sweepFactor=1; c.gravity=9.81;
% Added assumptions: lift limits, flap drag, engine lapse, field model.
c.CLmaxClean=1.6; c.CLmaxTakeoff=2.0; c.CLmaxLanding=2.4;
c.deltaCDpattern=0.06; c.deltaCDloiter=0;
c.powerLapseExponent=0.70; c.engineCount=2;
c.takeoffTarget_m=1000; c.landingTarget_m=1000;
c.climbTarget_ms=8; c.oeiGradient=0.024; c.muRoll=0.03; c.muBrake=0.35;
c.deltaISA_K=0; c.fieldAltitude_m=0;
% Report tail volumes/control ratios; added taper, tail arms and CG stations.
c.taper=0.45; c.tailArmH_m=10.5; c.tailArmV_m=10.2;
c.VH=1.106; c.VV=0.0753; c.dihedral_deg=2.75;
c.aileronSpanFraction=0.28; c.aileronChordFraction=0.29;
c.elevatorChordFraction=0.34; c.rudderChordFraction=0.335;
c.cgEmpty_MAC=0.28; c.cgCrew_MAC=-0.60; c.cgFuel_MAC=0.30; c.cgWater_MAC=0.30;
c.cgMin_MAC=0.15; c.cgMax_MAC=0.40;
% Illustrative parcel drop assumptions.
c.dropDuration_s=8; c.windNED_ms=[0 5 0];
c.parcelDiameter_m=0.005; c.parcelCd=0.47; c.waterDensity_kgm3=1000;
c.releaseDown_ms=0; c.releaseCount=21;
% Preliminary aerodynamic/control derivatives; per radian unless noted.
c.dyn.CL0=0.35; c.dyn.flapCL0=0.80; c.dyn.CLa=5.2; c.dyn.CLde=0.45; c.dyn.CLq=3.5;
c.dyn.Cm0=0; c.dyn.Cma=-0.8; c.dyn.Cmde=-1.1; c.dyn.Cmq=-12;
c.dyn.CYb=-0.7; c.dyn.CYdr=0.18;
c.dyn.Clb=-0.10; c.dyn.Clp=-0.45; c.dyn.Clda=0.18;
c.dyn.Cnb=0.15; c.dyn.Cnr=-0.20; c.dyn.Cndr=-0.12;
c.dyn.radiusGyration_m=[5 6 7];
c.dyn.dropStart_s=5; c.dyn.stopTime_s=25;
c.dyn.speedGain=0.025; c.dyn.heightGain=0.0015;
c.dyn.pitchGain=0.9; c.dyn.pitchRateGain=0.5;
c.dyn.rollGain=0.6; c.dyn.rollRateGain=0.3; c.dyn.yawRateGain=0.4;
c.dyn.fuelFlow_kgs=0.20; c.dyn.autopilot=true; c.dyn.engineOut=false;
c.dyn.elevatorPulse_deg=0; c.dyn.pulseStart_s=2; c.dyn.pulseDuration_s=1;
end
