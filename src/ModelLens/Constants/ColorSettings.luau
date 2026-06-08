local ColorSettings = {};

ColorSettings.Selection = {
  Selected = Color3.fromRGB(76, 103, 255),
  Unselected = Color3.fromRGB(50,50,50)
}

ColorSettings.Captured = {
  Captured = Color3.fromRGB(0,255,0),
  Uncaptured = Color3.fromRGB(255, 196, 0),
}

ColorSettings.BackgroundColor = {
  Black = Color3.fromRGB(0,0,0),
  White = Color3.fromRGB(255,255,255),
  Green = Color3.fromRGB(0,177,64),
  Transparent = Color3.fromRGB(128,128,128),
}

ColorSettings.StrokeColor = {
  Black = Color3.fromRGB(0,0,0),
  White = Color3.fromRGB(255,255,255),
  Green = Color3.fromRGB(0,177,64),
}

return ColorSettings;