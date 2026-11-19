function [out, report] = run_stage02_smoke()
%RUN_STAGE02_SMOKE Compile and run the integrated demonstration.
% This is an execution smoke check, not a requirements verification test.
init_stage02();
stageFolder = fileparts(mfilename('fullpath'));
open_system(fullfile(stageFolder, 'QuadArchitecture_AI.slx'));
report = struct('Model', 'QuadArchitecture_AI', 'Compiles', false, ...
    'SimulationRuns', false, 'RequirementTests', 'Not run', ...
    'VisualVerification', 'Not performed');
try
    set_param('QuadArchitecture_AI', 'SimulationCommand', 'update');
    report.Compiles = true;
    in = Simulink.SimulationInput('QuadArchitecture_AI');
    out = sim(in);
    report.SimulationRuns = true;
    position = sampleRows(out.visualizationState.PositionNED);
    velocity = sampleRows(out.visualizationState.VelocityNED);
    quaternion = sampleRows(out.visualizationState.OrientationQuaternion);
    angularRate = sampleRows(out.visualizationState.AngularVelocityBody);
    mode = sampleRows(out.telemetryFlightMode.Mode);
    changes = [true; diff(mode) ~= 0];
    report.EndTime = out.tout(end);
    report.StopEvent = out.SimulationMetadata.ExecutionInfo.StopEvent;
    report.StopDescription = out.SimulationMetadata.ExecutionInfo.StopEventDescription;
    report.SimulationWarnings = numel(out.SimulationMetadata.ExecutionInfo.WarningDiagnostics);
    report.ModeSequence = mode(changes)';
    report.ModeTransitionTimes = out.telemetryFlightMode.Mode.Time(changes)';
    report.FinalPositionNED = position(end, :);
    report.FinalVelocityNED = velocity(end, :);
    report.StateSamples = size(position, 1);
    report.FiniteState = all(isfinite([position velocity quaternion angularRate]), 'all');
    report.Parameters = quad_mvp_parameters();
    report.Scope = 'Execution smoke observations only; no approved Path Followed tolerance or requirement verdict.';
    save(fullfile(stageFolder, 'smoke_result.mat'), 'out', 'report', '-v7.3');
    writeReport(stageFolder, report);
    fprintf('Model compiles: yes\nSimulation runs: yes\nEnd time: %.3f s\n', report.EndTime);
    fprintf('Observed modes: %s\n', mat2str(report.ModeSequence));
    fprintf('Final NED position: %s m\n', mat2str(report.FinalPositionNED, 6));
    fprintf('Formal requirements tests: not run\nVisual verification: not performed\n');
catch exception
    report.ErrorIdentifier = exception.identifier;
    report.ErrorMessage = exception.message;
    writeReport(stageFolder, report);
    rethrow(exception);
end
end

function rows = sampleRows(series)
count = numel(series.Time);
if series.IsTimeFirst
    rows = reshape(series.Data, count, []);
else
    rows = reshape(series.Data, [], count)';
end
end

function writeReport(stageFolder, report)
file = fopen(fullfile(stageFolder, 'smoke_status.json'), 'w', 'n', 'UTF-8');
if file == -1
    error('QuadMVP:ReportWrite', 'Cannot write the stage-local smoke report.');
end
cleanup = onCleanup(@() fclose(file));
fprintf(file, '%s\n', jsonencode(report, 'PrettyPrint', true));
end
