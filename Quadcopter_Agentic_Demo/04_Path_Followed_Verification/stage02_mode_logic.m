function flightMode = stage02_mode_logic(command, state)
%STAGE02_MODE_LOGIC 0 Ground, 1 Takeoff, 2..4 Waypoints, 5 Land, 6 Landed.
%#codegen
p = quad_mvp_parameters();
flightMode.Mode = command.Command;
if command.Command == 5 && state.PositionNED(3) >= -p.LandedHeight ...
        && norm(state.VelocityNED) < p.LandedSpeed
    flightMode.Mode = 6;
end
end
