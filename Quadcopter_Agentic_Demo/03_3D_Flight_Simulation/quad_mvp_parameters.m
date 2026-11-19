function p = quad_mvp_parameters()
%QUAD_MVP_PARAMETERS Demonstration design values, not verification criteria.
%#codegen
p.SampleTime = 0.02;
p.FixedStep = 0.005;
p.StopTime = 90;
p.StartTime = 1;
p.Mass = 1;
p.Gravity = 9.81;
p.InitialPosition = [0; 0; 0];
p.TakeoffPosition = [0; 0; -2];
p.Waypoints = [2 0 -2; 2 2 -2; 0 2 -2];
p.ArrivalRadius = 0.12;
p.ArrivalSpeed = 0.15;
p.HoverDwell = 1;
p.LandingSpeed = 0.25;
p.LandedHeight = 0.025;
p.LandedSpeed = 0.12;
p.Kp = [1.2; 1.2; 2.0];
p.Ki = [0.06; 0.06; 0.08];
p.Kd = [2.0; 2.0; 2.5];
p.IntegralLimit = [2; 2; 2];
p.AccelerationLimit = [2; 2; 2.5];
p.TiltLimit = 0.3;
p.ThrustLimits = zeros(2, 1);
p.AttitudePD = [100 20];
p.YawRateGain = 20;
p.ThrustGain = 30;
p.ThrustLimits = [0.2; 1.8] * p.Mass * p.Gravity;
end
