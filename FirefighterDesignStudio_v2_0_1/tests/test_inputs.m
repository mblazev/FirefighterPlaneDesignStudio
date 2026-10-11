function tests=test_inputs
tests=functiontests(localfunctions);
end
function testDefaultLogicals(test)
c=ffstudio.defaultConfig;
verifyClass(test,c.dyn.autopilot,'logical'); verifyClass(test,c.dyn.engineOut,'logical');
ffstudio.validateConfig(c);
for autopilot=[false true]
    for engineOut=[false true]
        c.dyn.autopilot=autopilot; c.dyn.engineOut=engineOut; ffstudio.validateConfig(c);
    end
end
end
function testNumericSwitches(test)
c=ffstudio.defaultConfig;
for v=[0 1]
    c.dyn.autopilot=v; c.dyn.engineOut=v; ffstudio.validateConfig(c);
end
verifyTrue(test,true);
end
function testInvalidSwitches(test)
bad={2,-1,.5,NaN,Inf,[0 1],1+1i,'true',[],struct};
for key={'autopilot','engineOut'}
    for i=1:numel(bad)
        c=ffstudio.defaultConfig; c.dyn.(key{1})=bad{i};
        verifyError(test,@()ffstudio.validateConfig(c),'ffstudio:Input');
    end
end
end
function testInvalidNumbers(test)
for v={true,NaN,Inf,-1,0,'3500',[1 2],1+1i}
    c=ffstudio.defaultConfig; c.wingLoading_Nm2=v{1};
    verifyError(test,@()ffstudio.validateConfig(c),'ffstudio:Input');
end
c=ffstudio.defaultConfig; c.windNED_ms=[0 5];
verifyError(test,@()ffstudio.validateConfig(c),'ffstudio:Input');
c=ffstudio.defaultConfig; c.propEfficiency=1.1;
verifyError(test,@()ffstudio.validateConfig(c),'ffstudio:Input');
c=ffstudio.defaultConfig; c=rmfield(c,'payload_kg');
verifyError(test,@()ffstudio.validateConfig(c),'ffstudio:Input');
end
function testJsonRoundTrip(test)
c=ffstudio.defaultConfig; copy=jsondecode(jsonencode(c)); ffstudio.validateConfig(copy);
verifyEqual(test,copy.dyn.autopilot,true); verifyEqual(test,copy.dyn.engineOut,false);
verifyEqual(test,copy.windNED_ms(:),c.windNED_ms(:));
end
