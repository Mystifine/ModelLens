local SelectionService = require(script.Parent.SelectionService);
local WidgetUI = require(script.Parent.WidgetUI);

local toolbar = plugin:CreateToolbar("ModelLens");
local openButton = toolbar:CreateButton(
  "ModelLens", 
  "Open ModelLens Window", 
  ""
)

local widget = WidgetUI.create(plugin);

openButton.Click:Connect(function()
	widget.Enabled = not widget.Enabled

	local model = SelectionService.getSelection()
	if model then
		print("Selected:", model.Name)
	else
		print("Nothing selected")
	end
end)