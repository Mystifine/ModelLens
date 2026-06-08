local ValueUtil = require(script.Parent.Parent.Utility.ValueUtil);

local CameraProperties = {
  backgroundColor = ValueUtil.stringValue("Black"),
  strokeColor = ValueUtil.stringValue("Black"),
  strokeThickness = ValueUtil.numberValue(0),
};

return CameraProperties;