# Verification of v2.0.0 — 11 October 2026

## Completed checks

- Parsed all **35 MATLAB source files** using the installed MATLAB R2026b standalone Code Analyzer. No syntax errors were reported. Full diagnostics are in `code_analysis.txt`.
- Confirmed all delivered `ffstudio.*` calls resolve to delivered source files; no `ff.*` references or calls to `validateattributes` occur in the MATLAB sources.
- Confirmed the source defaults match the independent reference inputs, including logical `autopilot=true` and `engineOut=false`.
- Reviewed dashboard result fields against the actual calculation outputs and normalized imported vectors for the text editor.
- Defined **12 discoverable MATLAB regression tests** covering logical and numeric switch values, invalid values, JSON import, numerical closure, fuel integration, performance, trends, water/CG, full analysis/export and uncertainty repeatability. Definition/discovery checks are static; these tests have **not been executed** here.
- Independently recomputed report and actual-speed mass closure, mass stations, water subtraction, remaining extra reserve, polar maximum, loaded range, database counts and trend refits. Compared the actual-speed fuel closed form against a separate RK4 integration.
- Independently solved the level drop-leg trim using a bracketed force-balance root: alpha about 2.74 degrees, elevator about -1.99 degrees, throttle about 0.329. Its force residual is below 1e-7 N. This checks the assumed trim equations, not the Simulink implementation.

See `independent_numerical_reference.json`, `source_audit.json`, `baseline_comparison.csv` and `baseline_reference.html`.

| Quantity | Report method | Actual-speed fuel |
| --- | ---: | ---: |
| MTOW kg | 21965.28 | 25896.97 |
| Empty kg | 12289.65 | 14265.26 |
| Fuel kg | 3475.63 | 5431.72 |
| Wing area m2 | 61.57 | 72.59 |
| Span m | 26.61 | 28.89 |
| Installed power kW | 5052.02 | 5956.30 |

These numerical results were produced independently in Python with the default inputs, not by running the MATLAB package. Small atmospheric differences are allowed in the supplied MATLAB tests because the toolbox atmosphere provider may differ slightly in its constants.

## Runtime limitation

A MATLAB R2026b batch launch was attempted specifically to run:

```matlab
c = ffstudio.defaultConfig;
ffstudio.validateConfig(c);
disp('V2_BOOLEAN_VALIDATION_PASSED');
```

MATLAB startup returned **Unable to communicate with required MathWorks services (error 5201)** before executing the command. The success marker was not produced. Consequently, MATLAB numerical tests, the dashboard and Simulink build/simulation remain unverified at runtime. `matlab_startup.log` records the environment error. Static and independent numerical checks cannot confirm MATLAB GUI or Simulink runtime behavior.

Run the supplied checks inside your working MATLAB session:

```matlab
check_firefighter_studio
check_firefighter_studio(true,true)
```

The optional GUI check recomputes after editing both Boolean switches. The optional Simulink check creates a separate temporary model, checks initial trim, simulates one second, and checks finite states, quaternion normalization and absence of ground contact. It leaves that test model in its printed temporary folder.

## Rebuild changes relevant to the reported error

The exact original stack trace was not available. The reported error indicates a logical value was passed to a numeric-bound attribute check. This rebuild removes generic attribute-validation calls from the application code and uses explicit Boolean predicates for both switches. The dashboard stores parameter values as text and converts Boolean values separately. The new `+ffstudio` namespace and versioned launcher avoid the original package names and print the active folder so an old copy can be identified.

These changes address that failure mechanism throughout the rebuilt code. Successful launch on the user's MATLAB installation still needs runtime confirmation.
