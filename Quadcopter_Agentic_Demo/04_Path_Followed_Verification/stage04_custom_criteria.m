function stage04_custom_criteria(test)
%STAGE04_CUSTOM_CRITERIA Simulink Test custom criteria for FR-06 only.
criteria = stage04_require_approval();
folder = fileparts(mfilename('fullpath'));
try
    out = test.sltest_simout;
    [metrics,data] = stage04_path_metrics(out,criteria);
    save(fullfile(folder,'PathFollowed_run.mat'),'out','metrics','data','criteria','-v7.3');
    writeMetrics(folder,metrics);
    stage04_plot_evidence(metrics,data);
catch exception
    metrics = struct('CriteriaVersion',criteria.Version,'Requirement','UAV-MVP-FR-06', ...
        'Verdict','Inconclusive','ErrorIdentifier',exception.identifier,'ErrorMessage',exception.message);
    writeMetrics(folder,metrics);
    rethrow(exception);
end
test.verifyTrue(metrics.CorridorSatisfied, ...
    sprintf('FR-06 corridor: maximum measured error %.9f m; approved limit %.2f m.', ...
    metrics.OverallMaximumErrorMeters,criteria.ToleranceMeters));
test.verifyTrue(metrics.OrderedWaypointArrivalSatisfied, ...
    'FR-06: all three assigned waypoint endpoints must be reached within 0.20 m in order.');
test.verifyTrue(metrics.PathCompletedWithinLimit, ...
    'FR-06: waypoint path must be completed within the approved 90 s limit.');
end

function writeMetrics(folder,metrics)
file = fopen(fullfile(folder,'PathFollowed_metrics.json'),'w','n','UTF-8');
if file == -1, error('QuadMVP:EvidenceWrite','Cannot write stage-local metrics.'); end
cleanup = onCleanup(@() fclose(file));
fprintf(file,'%s\n',jsonencode(metrics,'PrettyPrint',true));
end
