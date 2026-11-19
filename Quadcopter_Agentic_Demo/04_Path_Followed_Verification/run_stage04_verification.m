function [resultSet, metrics] = run_stage04_verification()
%RUN_STAGE04_VERIFICATION Execute the approved FR-06-only Simulink Test case.
init_stage04();
criteria = stage04_require_approval();
folder = fileparts(mfilename('fullpath'));
testFile = sltest.testmanager.load(fullfile(folder,'QuadcopterTests_AI.mldatx'));
suites = getTestSuites(testFile);
assert(isscalar(suites),'Expected exactly one approved test suite.');
cases = getTestCases(suites);
assert(isscalar(cases) && strcmp(cases.Name,'Path Followed'), ...
    'Expected exactly the approved Path Followed case.');
assert(cases.Enabled && getCustomCriteria(cases).Enabled,'The approved test/criteria must be enabled.');
assert(strcmp(getProperty(cases,'Model'),'QuadArchitecture_AI'), 'Unexpected model under test.');
assert(strcmp(getProperty(cases,'SimulationMode'),'Normal'), 'Expected normal simulation mode.');
assert(str2double(string(getProperty(cases,'StopTime'))) == criteria.MaximumSimulationTimeSeconds, ...
    'Stop time differs from the approved finite limit.');
runStart = datetime('now');
resultSet = run(cases);
resultSet.Name = 'Path Followed - FR-06 - PF-CRITERIA-v1';
sltest.testmanager.exportResults(resultSet,fullfile(folder,'PathFollowed_Results.mldatx'));
metricsFile = fullfile(folder,'PathFollowed_metrics.json');
info = dir(metricsFile);
if isempty(info) || datetime(info.datenum,'ConvertFrom','datenum') < runStart - seconds(1)
    metrics = struct('Verdict','Inconclusive', ...
        'Reason','This run did not produce fresh assessment metrics. Inspect native diagnostics.');
else
    metrics = jsondecode(fileread(metricsFile));
end
requirements = slreq.load(fullfile(folder,'Quadcopter_MVP_AI.slreqx'));
updateVerificationStatus(requirements);
sltest.testmanager.view;
slreq.open(requirements,'UAV-MVP-FR-06');
fprintf('Native Simulink Test outcome: %s\n',string(resultSet.Outcome));
fprintf('FR-06 Path Followed criterion: %s\n',metrics.Verdict);
end
