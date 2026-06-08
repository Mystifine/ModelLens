local ServerStorage = game:GetService("ServerStorage");

local PresetsUtil = {};

function PresetsUtil.getCustomPresetsContainer()
  local customPresets = ServerStorage:FindFirstChild("ModelLensCustomPresets");
  return customPresets;
end

function PresetsUtil.getCustomPresets()
  local customPresets = PresetsUtil.getCustomPresetsContainer();
  if not customPresets then
    return nil;
  end

  local presets = customPresets:GetChildren();
  local loadedPresets = {};
  for i = 1, #presets do
    local data = require(presets[i]);
    table.insert(loadedPresets, data);
  end
  return loadedPresets;
end

function PresetsUtil.saveCustomPreset(cameraSettings, effectSettings)

  local customPresetsContainer = PresetsUtil.getCustomPresetsContainer();
  if not customPresetsContainer then
    customPresetsContainer = Instance.new("Folder");
    customPresetsContainer.Name = "ModelLensCustomPresets";
    customPresetsContainer.Parent = ServerStorage;
  end

  local lines = {"local CustomPresetSettings = {",'    presetName="CustomPreset",'}
  
  for key, valueObj in cameraSettings do
    local val = valueObj.Value
    if type(val) == "string" then
      table.insert(lines, string.format('    %s = "%s",', key, val))
    else
      table.insert(lines, string.format("    %s = %s,", key, tostring(val)))
    end
  end

  for key, valueObj in effectSettings do
    local val = valueObj.Value
    if type(val) == "string" then
      table.insert(lines, string.format('    %s = "%s",', key, val))
    else
      table.insert(lines, string.format("    %s = %s,", key, tostring(val)))
    end
  end
  
  table.insert(lines, "}")
  table.insert(lines, "")
  table.insert(lines, "return CustomPresetSettings")
  
  local source = table.concat(lines, "\n")

  local module = Instance.new("ModuleScript");
  module.Source = source;
  module.Name = "CustomPresets";
  module.Parent = customPresetsContainer;
end

return PresetsUtil;
