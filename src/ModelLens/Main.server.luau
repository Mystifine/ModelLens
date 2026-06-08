local WidgetUI = require(script.Parent.UI.WidgetUI);

local toolbar = plugin:CreateToolbar("ModelLens");
local openButton = toolbar:CreateButton(
  "ModelLens", 
  "Open ModelLens Window", 
  "rbxassetid://81951763254101"
)

local widget = WidgetUI.create(plugin);
openButton.Click:Connect(function()
	widget.Enabled = not widget.Enabled
end)