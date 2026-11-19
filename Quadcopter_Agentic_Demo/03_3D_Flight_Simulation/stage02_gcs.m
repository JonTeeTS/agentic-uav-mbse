function [command, waypoints, stop] = stage02_gcs(t, position, flightMode)
%STAGE02_GCS Feedback-driven mission sequence and optional settling dwell.
%#codegen
p = quad_mvp_parameters();
persistent phase dwell previousPosition
if isempty(phase)
    phase = 0;
    dwell = 0;
    previousPosition = p.InitialPosition;
end
speed = norm(position.PositionNED - previousPosition) / p.SampleTime;
previousPosition = position.PositionNED;
if phase == 0 && t >= p.StartTime
    phase = 1;
end
if phase >= 1 && phase <= 4
    if phase == 1
        target = p.TakeoffPosition;
    else
        target = p.Waypoints(phase - 1, :)';
    end
    if norm(position.PositionNED - target) < p.ArrivalRadius && speed < p.ArrivalSpeed
        dwell = dwell + p.SampleTime;
    else
        dwell = 0;
    end
    if dwell >= p.HoverDwell
        phase = phase + 1;
        dwell = 0;
    end
end
command.Command = phase;
waypoints.PositionNED = p.Waypoints;
stop = flightMode.Mode == 6 && t > p.StartTime;
end
