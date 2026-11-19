function reference = stage02_guidance(waypoints, state, flightMode)
%STAGE02_GUIDANCE Position references and NED position error.
%#codegen
p = quad_mvp_parameters();
persistent landingDown previousMode
if isempty(landingDown)
    landingDown = 0;
    previousMode = 0;
end
mode = flightMode.Mode;
target = p.InitialPosition;
if mode == 1
    target = p.TakeoffPosition;
elseif mode >= 2 && mode <= 4
    target = waypoints.PositionNED(mode - 1, :)';
elseif mode >= 5
    if previousMode < 5
        landingDown = state.PositionNED(3);
    end
    landingDown = min(0, landingDown + p.LandingSpeed * p.SampleTime);
    target = [waypoints.PositionNED(3, 1); waypoints.PositionNED(3, 2); landingDown];
end
previousMode = mode;
reference.PositionNED = target;
reference.PositionErrorNED = target - state.PositionNED;
end
