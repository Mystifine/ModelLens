

local ValueUtil = {};

function ValueUtil.stringValue(val : string)
  local strValue = Instance.new("StringValue");
  strValue.Value = val;
  return strValue;
end

function ValueUtil.numberValue(val : number)
  local numValue = Instance.new("NumberValue");
  numValue.Value = val;
  return numValue;
end

return ValueUtil;