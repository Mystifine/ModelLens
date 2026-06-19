local WidgetUI = require(script.Parent.UI.WidgetUI);

local toolbar = plugin:CreateToolbar("ModelLens");
local openButton = toolbar:CreateButton(
  "ModelLens", 
  "Open ModelLens Window", 
  "rbxassetid://81951763254101"
)

local widget = nil;
openButton.Click:Connect(function()
	if not widget then
    widget = WidgetUI.create(plugin);
    widget.Enabled = true;
  else
    widget.Enabled = not widget.Enabled
	end
end)