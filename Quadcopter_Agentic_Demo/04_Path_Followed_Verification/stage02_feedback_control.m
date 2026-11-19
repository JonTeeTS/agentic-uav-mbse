function control = stage02_feedback_control(reference, state, flightMode)
%STAGE02_FEEDBACK_CONTROL Position PID, derivative on measured velocity.
% The supported vehicle block contains the reduced-order inner attitude loops.
%#codegen
p = quad_mvp_parameters();
persistent integralError
if isempty(integralError)
    integralError = zeros(3, 1);
end
error = reference.PositionErrorNED;
if flightMode.Mode == 0 || flightMode.Mode == 6
    integralError(:) = 0;
    acceleration = zeros(3, 1);
else
    candidate = min(p.IntegralLimit, max(-p.IntegralLimit, ...
        integralError + p.SampleTime * error));
    raw = p.Kp .* error + p.Ki .* candidate - p.Kd .* state.VelocityNED;
    % Conditional integration prevents accumulation into acceleration limits.
    for axis = 1:3
        if abs(raw(axis)) <= p.AccelerationLimit(axis) || error(axis) * raw(axis) < 0
            integralError(axis) = candidate(axis);
        end
    end
    acceleration = p.Kp .* error + p.Ki .* integralError - p.Kd .* state.VelocityNED;
    acceleration = min(p.AccelerationLimit, max(-p.AccelerationLimit, acceleration));
end
% Yaw is held at zero. NED positive-down gravity; thrust acts along -body-Z.
upward = p.Gravity - acceleration(3);
control.Roll = min(p.TiltLimit, max(-p.TiltLimit, ...
    atan2(acceleration(2), hypot(acceleration(1), upward))));
control.Pitch = min(p.TiltLimit, max(-p.TiltLimit, ...
    atan2(-acceleration(1), upward)));
control.YawRate = 0;
control.Thrust = min(p.ThrustLimits(2), max(p.ThrustLimits(1), ...
    p.Mass * norm([acceleration(1); acceleration(2); upward])));
end
