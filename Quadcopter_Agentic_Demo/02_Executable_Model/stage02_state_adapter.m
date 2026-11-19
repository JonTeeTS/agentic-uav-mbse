function [state, position] = stage02_state_adapter(u)
%STAGE02_STATE_ADAPTER Supported plant bus to the local architecture interface.
%#codegen
state.PositionNED = u.WorldPosition;
state.VelocityNED = u.WorldVelocity;
yaw = u.EulerZYX(1); pitch = u.EulerZYX(2); roll = u.EulerZYX(3);
cy = cos(yaw/2); sy = sin(yaw/2);
cp = cos(pitch/2); sp = sin(pitch/2);
cr = cos(roll/2); sr = sin(roll/2);
% Scalar-first Hamilton quaternion, active body-to-NED rotation.
state.OrientationQuaternion = [cr*cp*cy + sr*sp*sy; ...
    sr*cp*cy - cr*sp*sy; cr*sp*cy + sr*cp*sy; cr*cp*sy - sr*sp*cy];
state.AngularVelocityBody = u.BodyAngularRateRPY;
position.PositionNED = u.WorldPosition;
end
