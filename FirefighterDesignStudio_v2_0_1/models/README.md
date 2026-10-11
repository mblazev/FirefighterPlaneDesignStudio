# Locally generated flight model

Use the dashboard's **Build 6DOF model** button, or run:

```matlab
c = ffstudio.defaultConfig;
modelPath = ffstudio.buildSimulink(c);
flight = ffstudio.simulate6dof(c, modelPath);
```

This creates `ffstudio_v2_6dof.slx` here, using Aerospace Blockset. No precompiled SLX is included because the build could not be run in this environment. The source builder includes a model update step; a successful return confirms compilation in your MATLAB session. Full flight verification is separate.

The saved model contains its configuration in the model workspace. Opening it adds the parent package folder to the MATLAB path. Rebuilds save existing SLX files in `backups/`. Save or close unsaved model edits before rebuilding.
