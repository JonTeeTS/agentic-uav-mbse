function [metrics, data] = stage04_path_metrics(out, criteria)
%STAGE04_PATH_METRICS Evaluate exactly the approved sampled geometric path.
positionLog = out.get('telemetryPosition');
modeLog = out.get('telemetryFlightMode');
time = positionLog.PositionNED.Time(:);
position = stage03_rows(positionLog.PositionNED);
modeTime = modeLog.Mode.Time(:);
recordedMode = stage03_rows(modeLog.Mode);
if isempty(time) || size(position,2) ~= 3 || size(position,1) ~= numel(time) ...
        || any(~isfinite([time position]), 'all') || any(diff(time) <= 0)
    error('QuadMVP:InvalidPositionEvidence', 'Position/time evidence is missing, nonfinite, or invalid.');
end
if isempty(modeTime) || any(~isfinite([modeTime recordedMode]), 'all') ...
        || any(diff(modeTime) <= 0) || any(abs(recordedMode-round(recordedMode)) > 1e-9)
    error('QuadMVP:InvalidModeEvidence', 'Flight-mode evidence is missing or invalid.');
end
if max(diff(time)) > 1.5 * criteria.NominalSamplePeriodSeconds ...
        || max(diff(modeTime)) > 1.5 * criteria.NominalSamplePeriodSeconds
    error('QuadMVP:EvidenceGap', 'Recorded data has a gap exceeding the nominal telemetry sampling allowance.');
end
if numel(time) == numel(modeTime) && max(abs(time-modeTime)) < 1e-9
    mode = recordedMode;
    alignment = 'Matching recorded timestamps';
else
    if time(1) < modeTime(1)-1e-9 || time(end) > modeTime(end)+1e-9
        error('QuadMVP:UnalignedEvidence', 'Mode timestamps do not span the measured positions.');
    end
    mode = interp1(modeTime, recordedMode, min(max(time,modeTime(1)),modeTime(end)), 'previous');
    alignment = 'Zero-order-held discrete mode at original position timestamps; position samples unchanged';
end
vertices = criteria.PathVerticesNED;
parameters = quad_mvp_parameters();
if ~isequal(vertices, [parameters.TakeoffPosition'; parameters.Waypoints])
    error('QuadMVP:PathConfigurationChanged', 'Model mission differs from the approved fixed path.');
end
errorValues = nan(size(time));
legNumber = zeros(size(time));
legStats = struct([]);
arrivals = nan(1,3);
for leg = 1:3
    mask = mode == leg+1;
    index = find(mask);
    startPoint = vertices(leg,:);
    endpoint = vertices(leg+1,:);
    legStats(leg).Leg = leg;
    legStats(leg).Mode = leg+1;
    legStats(leg).Samples = numel(index);
    legStats(leg).MaximumErrorMeters = NaN;
    legStats(leg).RMSErrorMeters = NaN;
    legStats(leg).ClosestWaypointDistanceMeters = NaN;
    legStats(leg).ClosestWaypointTimeSeconds = NaN;
    legStats(leg).StartTimeSeconds = NaN;
    legStats(leg).EndTimeSeconds = NaN;
    if isempty(index), continue; end
    delta = endpoint-startPoint;
    projection = ((position(mask,:)-startPoint)*delta') / dot(delta,delta);
    projection = min(1,max(0,projection));
    closest = startPoint + projection.*delta;
    localError = vecnorm(position(mask,:)-closest,2,2);
    errorValues(mask) = localError;
    legNumber(mask) = leg;
    endpointDistance = vecnorm(position(mask,:)-endpoint,2,2);
    [closestDistance, localIndex] = min(endpointDistance);
    firstArrival = find(endpointDistance <= criteria.WaypointArrivalToleranceMeters,1,'first');
    if ~isempty(firstArrival), arrivals(leg) = time(index(firstArrival)); end
    legStats(leg).MaximumErrorMeters = max(localError);
    legStats(leg).RMSErrorMeters = sqrt(mean(localError.^2));
    legStats(leg).ClosestWaypointDistanceMeters = closestDistance;
    legStats(leg).ClosestWaypointTimeSeconds = time(index(localIndex));
    legStats(leg).StartTimeSeconds = time(index(1));
    legStats(leg).EndTimeSeconds = time(index(end));
end
active = legNumber > 0;
changes = [true; diff(mode) ~= 0];
modeSequence = mode(changes)';
assessedSequence = modeSequence(ismember(modeSequence,criteria.AssessedFlightModes));
ordered = isequal(assessedSequence, [2 3 4]) && all(isfinite(arrivals)) && all(diff(arrivals) > 0);
corridor = any(active) && all(errorValues(active) <= criteria.ToleranceMeters);
completed = ordered && arrivals(3) <= criteria.MaximumSimulationTimeSeconds;
metrics = struct;
metrics.CriteriaVersion = criteria.Version;
metrics.Requirement = 'UAV-MVP-FR-06';
metrics.TestCase = 'Path Followed';
metrics.ToleranceMeters = criteria.ToleranceMeters;
metrics.CorridorSatisfied = corridor;
metrics.OrderedWaypointArrivalSatisfied = ordered;
metrics.PathCompletedWithinLimit = completed;
metrics.OverallMaximumErrorMeters = NaN;
metrics.OverallRMSErrorMeters = NaN;
if any(active)
    metrics.OverallMaximumErrorMeters = max(errorValues(active));
    metrics.OverallRMSErrorMeters = sqrt(mean(errorValues(active).^2));
end
metrics.EvaluatedPositionSamples = nnz(active);
metrics.RecordedPositionSamples = numel(time);
metrics.MedianPositionSamplePeriodSeconds = median(diff(time));
metrics.TimeAlignment = alignment;
metrics.SimulationEndTimeSeconds = out.tout(end);
metrics.WaypointFirstArrivalTimesSeconds = arrivals;
metrics.ModeSequence = modeSequence;
metrics.LegStatistics = legStats;
metrics.Verdict = 'Fail';
if corridor && ordered && completed, metrics.Verdict = 'Pass'; end
metrics.Scope = 'Sampled 3D cruise waypoint path only; takeoff/landing performance, safety, hardware, and overall compliance unverified.';
data = struct('Time',time,'PositionNED',position,'Mode',mode, ...
    'TrackingErrorMeters',errorValues,'ActiveLeg',legNumber,'PathVerticesNED',vertices);
end
