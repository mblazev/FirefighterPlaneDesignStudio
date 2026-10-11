function ffstudio_forces_sfun(block)
%FFSTUDIO_FORCES_SFUN Level-2 continuous MATLAB S-function.
block.NumDialogPrms=1; block.DialogPrmsTunable={'Nontunable'};
block.NumInputPorts=5; block.NumOutputPorts=1;
block.SetPreCompInpPortInfoToDynamic; block.SetPreCompOutPortInfoToDynamic;
dims=[1 3 3 3 3];
for i=1:5
    block.InputPort(i).Dimensions=dims(i); block.InputPort(i).DatatypeID=0;
    block.InputPort(i).Complexity='Real'; block.InputPort(i).DirectFeedthrough=true;
end
block.OutputPort(1).Dimensions=25; block.OutputPort(1).DatatypeID=0; block.OutputPort(1).Complexity='Real';
block.SampleTimes=[0 0]; block.SimStateCompliance='DefaultSimState';
block.RegBlockMethod('Outputs',@outputs);
end
function outputs(block)
block.OutputPort(1).Data=ffstudio.forces(block.InputPort(1).Data,block.InputPort(2).Data, ...
    block.InputPort(3).Data,block.InputPort(4).Data,block.InputPort(5).Data,block.DialogPrm(1).Data);
end
