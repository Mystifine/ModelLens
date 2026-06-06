local Selection = game:GetService("Selection");

local SelectionService = {};

function SelectionService.getSelection()
  local selected = Selection:Get()
	if #selected == 0 then return nil end
	return selected[1]
end

function SelectionService.getSelections()
  return Selection:Get();
end

SelectionService.SelectionChanged = Selection.SelectionChanged

return SelectionService;