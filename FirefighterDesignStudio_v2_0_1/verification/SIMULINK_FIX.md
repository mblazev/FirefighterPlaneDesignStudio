# Simulink initialization fix — v2.0.1

The old builder contained this restrictive check:

```matlab
assert(exist('new_system','file')==2, ...)
```

`exist` code 2 identifies normal MATLAB/file implementations. Built-in functions have code 5 when checked as built-ins; MEX and P-code have different codes. Restricting the result to 2 can falsely report a missing product. This assertion was removed.

The builder now attempts `load_system('simulink')` and `load_system('aerolib6dof2')` directly before creating or backing up any model. Each failure preserves the original MATLAB exception and identifies which library failed. `new_system` is then called normally. The force, mass, control and model wiring equations are unchanged.

Verification for this update: all 35 MATLAB sources were parsed with the installed R2026b Code Analyzer; static checks confirm the file-type assertion is absent and both real library loads precede model creation. The full-source and single-file downloads contain identical corrected builders, and ZIP contents were verified against the source hashes.

The earlier batch startup failed with MathWorks service error 5201, so this update does not claim a successful runtime Simulink build. Use **Build 6DOF model** in the working MATLAB desktop to confirm operation.

References: [MathWorks exist return codes and search types](https://www.mathworks.com/help/matlab/ref/exist.html), [new_system](https://www.mathworks.com/help/simulink/slref/new_system.html).
