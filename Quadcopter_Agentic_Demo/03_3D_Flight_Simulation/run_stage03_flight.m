function [out, report] = run_stage03_flight()
%RUN_STAGE03_FLIGHT Run the autonomous mission with native UAV Animation.
% This demonstrates visualization; it does not execute Path Followed.
init_stage03();
folder = fileparts(mfilename('fullpath'));
open_system(fullfile(folder, 'QuadArchitecture_AI.slx'));
report = struct('Stage', '03_3D_Flight_Simulation', 'ModelCompiles', false, ...
    'SimulationRuns', false, 'FormalRequirementTests', 'Not run');
try
    set_param('QuadArchitecture_AI', 'SimulationCommand', 'update');
    report.ModelCompiles = true;
    in = Simulink.SimulationInput('QuadArchitecture_AI');
    out = sim(in);
    report.SimulationRuns = true;
    position = stage03_rows(out.visualizationState.PositionNED);
    velocity = stage03_rows(out.visualizationState.VelocityNED);
    quaternion = stage03_rows(out.visualizationState.OrientationQuaternion);
    mode = stage03_rows(out.telemetryFlightMode.Mode);
    changes = [true; diff(mode) ~= 0];
    report.EndTime = out.tout(end);
    report.StopDescription = out.SimulationMetadata.ExecutionInfo.StopEventDescription;
    report.SimulationWarnings = numel(out.SimulationMetadata.ExecutionInfo.WarningDiagnostics);
    report.ModeSequence = mode(changes)';
    report.ModeTransitionTimes = out.telemetryFlightMode.Mode.Time(changes)';
    telemetryPosition = stage03_rows(out.telemetryPosition.PositionNED);
    report.FinalPositionNED = telemetryPosition(end, :);
    report.LastVisualizationSampleTime = out.visualizationState.PositionNED.Time(end);
    report.LastVisualizationPositionNED = position(end, :);
    report.LastVisualizationVelocityNED = velocity(end, :);
    report.FiniteState = all(isfinite([position velocity quaternion]), 'all');
    report.MaximumQuaternionNormError = max(abs(vecnorm(quaternion, 2, 2) - 1));
    report.ModelCoordinates = 'NED, meters; scalar-first Hamilton body-to-NED quaternion';
    report.DisplayCoordinates = 'ENU, converted by UAV Animation (R2026b)';
    report.LandingLimit = 'Inherited idealized proximity stop; no physical ground-contact model.';
    report.Parameters = quad_mvp_parameters();
    [animation, plots] = stage03_review_figures(out);
    report.AnimationFigureOpen = isgraphics(animation);
    report.PositionPlotsOpen = isgraphics(plots);
    save(fullfile(folder, 'flight_result.mat'), 'out', 'report', '-v7.3');
    writeReport(folder, report);
    fprintf('Model compiles: yes\nMission runs with UAV Animation: yes\n');
    fprintf('Stop at %.3f s; observed modes %s\n', report.EndTime, mat2str(report.ModeSequence));
    fprintf('Simulation warnings: %d\nFinal NED position: %s m\n', ...
        report.SimulationWarnings, mat2str(report.FinalPositionNED, 6));
    fprintf('Native animation and position plots are open. Formal tests were not run.\n');
catch exception
    report.ErrorIdentifier = exception.identifier;
    report.ErrorMessage = exception.message;
    writeReport(folder, report);
    rethrow(exception);
end
end

function writeReport(folder, report)
file = fopen(fullfile(folder, 'flight_status.json'), 'w', 'n', 'UTF-8');
if file == -1
    error('QuadMVP:ReportWrite', 'Cannot write the local flight status.');
end
cleanup = onCleanup(@() fclose(file));
fprintf(file, '%s\n', jsonencode(report, 'PrettyPrint', true));
end
