local Selection = game:GetService("Selection");

local SelectionUtil = {};

function SelectionUtil.getSelection()
  local selected = Selection:Get()
	if #selected == 0 then return nil end
	return selected[1]
end

function SelectionUtil.getSelections()
  return Selection:Get();
end

SelectionUtil.SelectionChanged = Selection.SelectionChanged

return SelectionUtil;