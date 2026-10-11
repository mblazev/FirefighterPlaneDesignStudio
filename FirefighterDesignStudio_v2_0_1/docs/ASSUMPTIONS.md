# Source, equations and scope

## Reference material

The supplied `AD1_P1_Firefighter_Blazhevski` report provides the design mission, aircraft comparison data and early design selections. The reference file is unchanged. The CSV transcribes nineteen aircraft and retains the report's source attributions. Missing empty mass, cruise or range values remain `NaN`; no values are silently imputed. These third-party attributions have not been independently reverified.

The default mission uses 6000 kg water, 200 kg crew, a 700 km outbound radius and return leg, cruise at 580 km/h and 5500 m, a 220 km/h low-level pattern, and 45 minutes of reserve loiter. Rounded report sizing inputs include AR 11.5, Oswald factor 0.8, wetted-area ratio 5.5, best-L/D factor 11, W/S 3500 N/m2 and installed shaft power/mass 0.23 kW/kg. The empty-mass fraction is `1.442 * MTOW^(-0.0947)` with mass in kilograms. The tail volumes/control proportions are initial report design selections.

`defaultConfig.m` separates added engineering inputs with comments. They are editable assumptions rather than measured aircraft data.

## Mission and mass closure

Mass closure solves `MTOW = empty + crew + water + fuel`, with `fuel = reserveFactor * missionFuelBurn`. The water release is subtracted once between mass stations 5 and 6 and excluded from fuel burn. Unused extra fuel remains aboard at the final station. The reserve loiter is already a mission segment; the 1.06 factor adds fuel on top of the calculated burn.

The report method uses a propeller Breguet mass ratio for cruise with best L/D, the report's 0.70 best-L/D pattern factor and 0.866 best-L/D loiter factor. Empirical takeoff, climb, descent and landing fractions remain unchanged. Mass closure uses the first positive root bracket below 180 tonnes. An absent bracket is reported as an error.

The actual-speed method computes changing drag and fuel at fixed TAS, altitude, wing area and efficiency in each powered segment. For the parabolic polar, the fuel equation is `dm/dt = -(a + b*m^2)`, integrated analytically. Its commanded TAS is an assumption; power availability is reported separately. Climb and ground fractions remain empirical in this method. It is not a time-resolved full mission trajectory.

Fully loaded range retains the water and the same initial fuel budget, includes climb/descent/landing and reserve loiter, and retains extra reserve fuel. It represents one continuous loaded cruise leg.

## Atmosphere, polar and performance

The polar is `CD = CD0 + k*CL^2`, with `k = 1/(pi*AR*e)` and `CD0` inferred from the selected best L/D. No Reynolds/Mach dependence, drag build-up or propeller map is supplied. Pattern flap drag is an added constant. Lift is limited using assumed CLmax values; post-stall aerodynamics are not resolved.

Atmosphere uses Aerospace Toolbox `atmosisa` when available, otherwise the ISA troposphere equations. The supported altitude interval is 0–11000 m. Temperature offsets are applied at fixed ISA pressure. Available shaft power scales with `min(1, densityRatio^powerLapseExponent)`. The default exponent 0.70 must be replaced with a suitable engine map for meaningful altitude performance. The propeller efficiency and fuel consumption are constant inputs.

Power/climb curves use MTOW, while the requested loaded-cruise check uses the mission's start-of-outbound mass. The drop stall check uses the pre-pattern arrival mass and assumed landing CLmax. Constraint curves use MTOW wing loading, a conservative 1.3 drop-speed/stall ratio and an illustrative OEI climb gradient. No minimum control speed, windmilling drag or certified engine-out procedure is calculated.

Field estimates use a 0.35-weight static-thrust cap, ground friction, assumed ground lift and a 15 m obstacle. Landing adds a 3-degree approach path with no explicit flare allowance. Takeoff/landing targets are comparison inputs, not constraints that resize the aircraft. These estimates do not include a balanced-field calculation, certification margins, wind, runway slope or braking system validation.

## Geometry, CG and water

Wing planform is trapezoidal with assumed taper. Tail areas follow the selected tail volumes and assumed arms. CG is a weighted mass ledger using assumed empty, crew, fuel and water stations, expressed as MAC fractions. It does not establish a measured neutral point or static margin. Water is removed at one mission station in the sizing ledger.

Water trajectories use equal spherical parcels, constant diameter/drag coefficient, fixed density at release altitude, gravity and uniform NED wind. Aircraft TAS is converted directly to the initial parcel north velocity; aircraft heading/groundspeed dynamics are not coupled to this parcel model. No breakup, evaporation, plume interaction, terrain, spread calibration or effective litres/m2 coverage is predicted. Impact-line length is the distance traveled during the release interval in constant conditions.

## Flight experiment

The builder targets the installed R2026b Custom Variable Mass 6DOF (Quaternion) block. The flight begins in level trim at the water-release height/speed with the report or actual-speed design's pre-release mass. It simulates only the local release leg. NED earth coordinates and forward/right/down body coordinates are used. Forces include gravity explicitly. The model supplies current mass, inertia and inertia derivative, with inertia proportional to mass and fixed radii of gyration.

Water mass is removed at a prescribed constant rate and fuel flow at an assumed constant rate. The mass-flow-relative-velocity option is off: no outlet jet reaction force is modeled. CG motion, nonuniform inertia redistribution and sloshing are omitted. Trim, linear aerodynamic derivatives and a simple feedback law are illustrative. Elevator/aileron/rudder and throttle are limited. The engine-out switch reduces power and adds an approximate yaw moment; no validated engine/propeller failure dynamics or Vmc calculation is provided.

The Level-2 MATLAB S-function runs in normal simulation mode. No TLC file, real-time target or deployable flight controller is supplied. A ground-position stop block ends simulation at contact. There is no contact/landing dynamics model.

## Trends and studies

Trend fits use finite land-twin observations; the empty-fraction fit also includes four-engine aircraft with known empty mass. R-squared and sample counts are retained. Extrapolating to 2036 is an illustrative trend, not a statistically established design forecast.

Sensitivity changes one variable at a time in the report method. Uncertainty uses independent normal perturbations of empty scale (5%), cruise SFC (10%) and best-L/D factor (5%) with a fixed seed and lower clipping. Quantiles summarize these chosen inputs, not measured confidence bounds. MATLAB's previous random state is restored.

## MathWorks references

- [ISA atmosphere](https://www.mathworks.com/help/aerotbx/ug/atmosisa.html)
- [Custom Variable Mass 6DOF (Quaternion): ports, parameters and conventions](https://www.mathworks.com/help/aeroblks/customvariablemass6dofquaternion.html)
- [Level-2 MATLAB S-Function](https://www.mathworks.com/help/simulink/slref/level2matlabsfunction.html)

The programmatic block names and parameters were checked against the local R2026b library and official documentation. Building/compiling/running the model still requires verification in a working MATLAB session.
