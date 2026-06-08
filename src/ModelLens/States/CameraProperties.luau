local ValueUtil = require(script.Parent.Parent.Utility.ValueUtil);

local CameraProperties = {
  orbitX = ValueUtil.numberValue(180); 
  orbitY = ValueUtil.numberValue(0); 
  fieldOfView = ValueUtil.numberValue(70),
  ambient = ValueUtil.numberValue(0.8),
  brightness = ValueUtil.numberValue(1.0),
  panX = ValueUtil.numberValue(0),
  panY = ValueUtil.numberValue(0),
  distance = ValueUtil.numberValue(1),
};

return CameraProperties;