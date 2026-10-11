# Firefighting Studio v2.0.1

Complete rebuild for MATLAB R2026b, based on **AD1_P1_Firefighter_Blazhevski**. This folder replaces the earlier package as a complete installation. Keep it in its own folder.

## Start here

1. Extract the ZIP to a **new folder**. Close the old Firefighting Studio window.
2. In MATLAB, open the extracted `FirefighterDesignStudio_v2_0_1` folder as the **Current Folder**. This is the folder containing `LAUNCH_STUDIO.m` and `+ffstudio`.
3. Run:

```matlab
LAUNCH_STUDIO
```

The Command Window should print **Firefighter Design Studio 2.0.1**, the new folder path, and **Input validation passed (including logical true/false)**. The dashboard title should say **Firefighting Studio v2.0.1**.

The new package is named `ffstudio`. Its numeric checks use explicit predicates, and the input editor converts text to numbers itself. The autopilot and engine-out switches accept `true`/`false` in MATLAB configuration structures and **0/1 in the dashboard**. It does not call `validateattributes`.

## What is included

| Tool | What it calculates |
| --- | --- |
| Overview | Printed report versus recomputed sizing and actual-speed fuel sizing; design findings |
| Mission | Twelve mass stations, segment fuel, water release, reserves, power required and available |
| Aerodynamics | Drag polar, best lift/drag, lift/drag at actual cruise speed |
| Performance | Power, climb, stall, preliminary takeoff and landing, loaded range, power/wing-loading constraints |
| Database + trends | Nineteen source aircraft, finite-data masks, linear fits and empty-mass fit |
| Geometry + CG | Wing and tail sizing, tank volume, assumed CG mass ledger |
| Water release | Ballistic parcel trajectories in constant wind and impact points |
| Studies | Five input sweeps and reproducible illustrative uncertainty samples |
| 6DOF flight | Source-built Aerospace Blockset quaternion model with changing mass/inertia, feedback, elevator pulse and engine-out switch |
| Export | HTML report, PNG figures, CSV tables, JSON scenario/summary, MATLAB results |

The left input table exposes the complete configuration, including the advanced `dyn.*` inputs. Use square brackets for vectors, for example `[0 5 0]`. Click **Recompute** after editing. Choose the sizing method in Overview to switch the mission, performance, geometry and CG displays. Export includes both methods. Save/load inputs uses version 2 JSON files.

Run **Build 6DOF model** to create `models/ffstudio_v2_6dof.slx` locally. **Run 6DOF flight** uses the current inputs and selected sizing method. Saved models are backed up before a rebuild; an open model with unsaved edits must be saved or closed first.

Version 2.0.1 fixes the incorrect "Simulink is required" message. The previous builder accepted only a normal file implementation of `new_system`, which could reject a built-in implementation. It now loads the actual Simulink and Aerospace Blockset libraries. A failed load reports the original MATLAB message and retains its exception as a cause. This distinguishes a Simulink startup problem from an Aerospace Blockset library problem without inferring installation or licensing from file type.

## Command Window use

```matlab
% Default configuration and complete engineering analysis
c = ffstudio.defaultConfig;
r = ffstudio.analyze(c);
disp(r.comparison)

% Customize a scenario
c.cruise_kmh = 500;
c.dyn.autopilot = true;
c.dyn.engineOut = false;
ffstudio.validateConfig(c);
r = ffstudio.analyze(c);
ffstudio.exportReport(r, fullfile(pwd,'results','my_scenario'));

% Calculate and export the baseline with design studies
results = analyze_firefighter;

% Run a flight experiment (requires Simulink and Aerospace products)
flight = ffstudio.simulate6dof(c);
plot(flight.table.Time_s, flight.table.Height_m)
```

Examples are in `examples/compare_designs.m` and `examples/flight_experiments.m`. `data/default_inputs.json` is the reference scenario.

## Checks and troubleshooting

```matlab
check_firefighter_studio             % 12 numerical/input/export regression tests
check_firefighter_studio(true)       % also open/recompute/close the dashboard
check_firefighter_studio(true,true)  % also build and run a short 6DOF check
```

The tests specifically cover default logical values, both logical switch states, numeric 0/1 switches, invalid switches, numeric type errors and JSON round trips. The GUI check changes both switches in the input table and recalculates. Optional checks require a working MATLAB desktop and the relevant products.

If the old error appears, first check the dashboard title and the printed folder. Run this **from the extracted v2 folder** to see the resolved source:

```matlab
which ffstudio.validateConfig -all
which start_firefighter_studio -all
```

If another v2 copy appears first, restart MATLAB and run `LAUNCH_STUDIO` from the intended folder. Dashboard errors print a full stack trace in the Command Window, so the failing file and line can be identified.

## Verification and scope

Standalone MATLAB Code Analyzer parsing and independent numerical checks were performed. **The MATLAB runtime, GUI and Simulink model could not be executed here:** MATLAB batch startup returned MathWorks service error **5201** before running the validation command. The included tests must still be run in a working MATLAB session. See `verification/VALIDATION.md` and `verification/baseline_reference.html` for the evidence and limits.

The report baseline recomputes to about **21,965 kg MTOW** and **3,476 kg fuel**. The actual-speed drag/fuel method gives about **25,897 kg MTOW** and **5,432 kg fuel**. With the assumed altitude power lapse, loaded cruise at 580 km/h needs about **3,734 kW**, while about **3,405 kW** is available. This is a design finding, not a confirmed feasible aircraft.

Read `docs/ASSUMPTIONS.md` before using results in design decisions. Aerospace Toolbox and Blockset provide atmosphere, rotations and equations of motion; they do not supply the missing aircraft aerodynamic derivatives, engine maps, validated drop coverage or certification evidence. The supplied report has been treated as reference material and has not been changed.
