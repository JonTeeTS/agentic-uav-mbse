function stageFolder = walkthrough_select_stage(projectRoot, stageName)
%WALKTHROUGH_SELECT_STAGE Switch clean demo checkpoints without saving files.
demoRoot = fullfile(char(projectRoot),'Quadcopter_Agentic_Demo');
allowed = {'01_Requirements_Architecture','02_Executable_Model', ...
    '03_3D_Flight_Simulation','04_Path_Followed_Verification'};
assert(ismember(char(stageName),allowed),'Choose one of the four demo stages.');
stageFolder = fullfile(demoRoot,char(stageName));
assert(isfolder(stageFolder),'The selected stage folder does not exist.');
modelNames = {'QuadArchitecture_AI','GCS_MVP_AI','ModeLogic_MVP_AI', ...
    'Guidance_MVP_AI','FeedbackControl_MVP_AI','VehicleModel_MVP_AI','Visualization_MVP_AI'};
for index = 1:numel(modelNames)
    if ~bdIsLoaded(modelNames{index}), continue; end
    modelFile = get_param(modelNames{index},'FileName');
    assert(startsWith(modelFile,[demoRoot filesep],'IgnoreCase',true), ...
        'A different project has a model with the same name. Close it before switching stages.');
    assert(strcmp(get_param(modelNames{index},'SimulationStatus'),'stopped'), ...
        'Stop the running demo simulation before switching stages.');
    assert(strcmp(get_param(modelNames{index},'Dirty'),'off'), ...
        'A demo model has unsaved edits. Save a working copy outside the checkpoints before switching.');
end
requirementSets = slreq.find('Type','ReqSet');
linkSets = slreq.find('Type','LinkSet');
for index = 1:numel(requirementSets)
    assert(startsWith(requirementSets(index).Filename,[demoRoot filesep],'IgnoreCase',true), ...
        'Close requirements from other projects before using the demo stage switcher.');
    assert(~requirementSets(index).Dirty, ...
        'A requirements set has unsaved edits. Save a working copy before switching stages.');
end
for index = 1:numel(linkSets)
    assert(startsWith(linkSets(index).Filename,[demoRoot filesep],'IgnoreCase',true), ...
        'Close requirement links from other projects before using the demo stage switcher.');
    assert(~linkSets(index).Dirty, ...
        'A link set has unsaved edits. Save a working copy before switching stages.');
end
dictionaryPaths = Simulink.data.dictionary.getOpenDictionaryPaths('QuadInterfaces_AI.sldd');
for index = 1:numel(dictionaryPaths)
    assert(startsWith(dictionaryPaths{index},[demoRoot filesep],'IgnoreCase',true), ...
        'Close the other-project QuadInterfaces_AI dictionary before switching.');
    dictionary = Simulink.data.dictionary.open(dictionaryPaths{index});
    assert(~dictionary.HasUnsavedChanges, ...
        'The interface dictionary has unsaved edits. Save a working copy before switching.');
end
for index = 1:numel(modelNames)
    if bdIsLoaded(modelNames{index}), close_system(modelNames{index},0); end
end
slreq.clear();
if ~isempty(dictionaryPaths)
    Simulink.data.dictionary.closeAll('QuadInterfaces_AI.sldd');
end
cd(stageFolder);
scratch = fullfile(char(projectRoot),'walkthrough_workspace',char(stageName));
Simulink.fileGenControl('set','CacheFolder',fullfile(scratch,'cache'), ...
    'CodeGenFolder',fullfile(scratch,'codegen'),'createDir',true);
disp("Reviewing " + string(stageName));
end
