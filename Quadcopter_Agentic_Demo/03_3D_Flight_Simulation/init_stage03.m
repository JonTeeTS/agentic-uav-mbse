function init_stage03()
%INIT_STAGE03 Resolve this stage's files and keep generated output local.
stageFolder = fileparts(mfilename('fullpath'));
models = {'QuadArchitecture_AI', 'GCS_MVP_AI', 'ModeLogic_MVP_AI', ...
    'Guidance_MVP_AI', 'FeedbackControl_MVP_AI', 'VehicleModel_MVP_AI', ...
    'Visualization_MVP_AI'};
for index = 1:numel(models)
    if bdIsLoaded(models{index}) && ~strcmpi(get_param(models{index}, 'FileName'), ...
            fullfile(stageFolder, [models{index} '.slx']))
        error('QuadMVP:OtherStageLoaded', ...
            'Close the other-stage copy of %s before running stage 03.', models{index});
    end
end
if ~strcmpi(pwd, stageFolder)
    cd(stageFolder);
end
Simulink.fileGenControl('set', 'CacheFolder', fullfile(stageFolder, 'cache'), ...
    'CodeGenFolder', fullfile(stageFolder, 'codegen'), 'createDir', true);
dictionary = Simulink.data.dictionary.open(fullfile(stageFolder, 'QuadInterfaces_AI.sldd'));
designData = getSection(dictionary, 'Design Data');
parameters = quad_mvp_parameters();
if exist(designData, 'MVP')
    entry = getEntry(designData, 'MVP');
    if ~isequal(getValue(entry), parameters)
        setValue(entry, parameters);
        saveChanges(dictionary);
    end
else
    addEntry(designData, 'MVP', parameters);
    saveChanges(dictionary);
end
end

