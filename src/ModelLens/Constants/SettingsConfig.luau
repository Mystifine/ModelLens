local ColorSettings = require(script.Parent.ColorSettings);

local SettingsConfig = {};

SettingsConfig.fieldOfView = {
  min = 20,
  max = 120
}

SettingsConfig.orbitY = {
  min = -80,
  max = 80
}

SettingsConfig.orbitX = {
  min = 0,
  max = 360
}

SettingsConfig.distance = {
  min = 0.3,
  max = 4,
}

SettingsConfig.panX = {
  min = -5,
  max = 5,
}

SettingsConfig.panY = {
  min = -5,
  max = 5,
}

SettingsConfig.ambient = {
  min = 0,
  max = 1,
}

SettingsConfig.brightness = {
  min = 0,
  max = 1,
}

SettingsConfig.strokeThickness = {
  min = 0,
  max = 10,
}

SettingsConfig.backgroundColor = {
  options = ColorSettings.BackgroundColor
}

SettingsConfig.strokeColor = {
  options = ColorSettings.StrokeColor,
}

return SettingsConfig;