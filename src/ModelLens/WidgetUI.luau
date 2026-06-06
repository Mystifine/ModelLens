local UserInputService = game:GetService("UserInputService");
local ValueService = require(script.Parent.ValueService);

local PRESET_SETTINGS = require(script.Parent.PresetSettings)

-- Widget Settings
local FRAME_SIZE_X, FRAME_SIZE_Y = 400, 300;
local MIN_FRAME_SIZE_X, MIN_FRAME_SIZE_Y = 300, 200;
local widgetInfo = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float,true,false,FRAME_SIZE_X,FRAME_SIZE_Y,MIN_FRAME_SIZE_X,MIN_FRAME_SIZE_Y)

-- Top Menu Selection Settings
local menuOptions = {"Camera", "Effects"};
local selectedMenuValue = ValueService.stringValue(menuOptions[1]);
local UNSELECTED_COLOR = Color3.fromRGB(50,50,50);
local SELECTED_COLOR = Color3.fromRGB(76, 103, 255)

-- Current Camera Settings
local DEFAULT_CAMERA_CFRAME = CFrame.new(0,1000,0);
local cameraSettings = {
  objectRotationX = ValueService.numberValue(0);
  objectRotationY = ValueService.numberValue(0);
  fieldOfView = ValueService.numberValue(70),
  brightness = ValueService.numberValue(100),
  cameraOffsetX = ValueService.numberValue(0),
  cameraOffsetY = ValueService.numberValue(0),
  cameraOffsetZ = ValueService.numberValue(0),
}

local effectSettings = {

};

local renderCamera = Instance.new("Camera");
local function updateCameraSettings()
  -- Need to update renderCamera
  renderCamera.FieldOfView = cameraSettings.fieldOfView.Value;
  renderCamera.CFrame = DEFAULT_CAMERA_CFRAME * CFrame.new(cameraSettings.cameraOffsetX.Value, cameraSettings.cameraOffsetY.Value, cameraSettings.cameraOffsetZ.Value);
  
  -- Need to update all viewports

end

local WidgetUI = {};

function WidgetUI.viewportFrame(object : BasePart | Model)
  local frame = Instance.new("Frame");
  frame.Size = UDim2.new(0,100,0,140,0);
  frame.BackgroundColor3 = UNSELECTED_COLOR;
  
end

function WidgetUI.createSlider(widget, labelText, min, max, defaultValue, callback)
    local sliderFrame = Instance.new("Frame");
    sliderFrame.Size = UDim2.new(1, -20, 0, 50);
    sliderFrame.BackgroundTransparency = 1;

    -- Label to show the title and current value
    local label = Instance.new("TextLabel");
    label.Size = UDim2.new(1, 0, 0, 20);
    label.Text = labelText .. ": " .. tostring(defaultValue);
    label.TextColor3 = Color3.fromRGB(220, 220, 220);
    label.Font = Enum.Font.SourceSansSemibold;
    label.TextSize = 14;
    label.TextXAlignment = Enum.TextXAlignment.Left;
    label.BackgroundTransparency = 1;
    label.Parent = sliderFrame;

    -- The slider background line
    local track = Instance.new("Frame");
    track.Size = UDim2.new(1, 0, 0, 6);
    track.Position = UDim2.new(0, 0, 0, 30);
    track.BackgroundColor3 = Color3.fromRGB(80, 80, 80);
    track.BorderSizePixel = 0;
    track.Parent = sliderFrame;

    -- The visual fill bar
    local fill = Instance.new("Frame");
    fill.Size = UDim2.new((defaultValue - min) / (max - min), 0, 1, 0);
    fill.BackgroundColor3 = Color3.fromRGB(0, 162, 255); -- Studio Blue
    fill.BorderSizePixel = 0;
    fill.Parent = track;

    -- The draggable knob
    local knob = Instance.new("TextButton");
    knob.Size = UDim2.new(0, 14, 0, 14);
    knob.AnchorPoint = Vector2.new(0, 0.5);
    knob.Position = UDim2.new(fill.Size.X.Scale, -7, 0.5, 0);
    knob.BackgroundColor3 = Color3.fromRGB(200, 200, 200);
    knob.Text = "";
    knob.Parent = track;

    -- Rounding out our elements to make them look sleek
    local trackUICorner = Instance.new("UICorner"); trackUICorner.CornerRadius = UDim.new(0, 3); trackUICorner.Parent = track;
    local fillUICorner = Instance.new("UICorner"); fillUICorner.CornerRadius = UDim.new(0, 3); fillUICorner.Parent = fill;
    local knobUICorner = Instance.new("UICorner"); knobUICorner.CornerRadius = UDim.new(1, 0); knobUICorner.Parent = knob;

    -- Dragging Logic
    local isDragging = false;

    local function updateSlider(inputPosition)
      -- Find where the mouse is relative to the slider bar track
      local trackPosition = track.AbsolutePosition;
      local trackSize = track.AbsoluteSize;
      
      local relativeX = inputPosition.X - trackPosition.X;
      local percentage = math.clamp(relativeX / trackSize.X, 0, 1);
      
      -- Map percentage to our real min/max value boundaries
      local rawValue = min + (max - min) * percentage;
      -- Round it off neatly to 1 decimal place (or remove 'string.format' if you want pure integers)
      local roundedValue = tonumber(string.format("%.1f", rawValue));

      -- Update UI visuals
      fill.Size = UDim2.new(percentage, 0, 1, 0);
      knob.Position = UDim2.new(percentage, -7, 0.5, 0);
      label.Text = labelText .. ": " .. tostring(roundedValue);

      -- Send the value back to your main script to apply camera changes!
      if callback then
        callback(roundedValue);
      end
    end

    -- Start Dragging
    knob.InputBegan:Connect(function(input)
      if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = true;
        knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255); -- Light up on hover/click
      end
    end);

    -- Monitor mouse movement anywhere on the user's screen while dragging is active
    UserInputService.InputChanged:Connect(function(input)
      if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        updateSlider(input.Position);
      end
    end);

    -- Stop Dragging
    UserInputService.InputEnded:Connect(function(input)
      if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = false;
        knob.BackgroundColor3 = Color3.fromRGB(200, 200, 200);
      end
    end);

    return sliderFrame;
end

function WidgetUI.menuPageSettingLabel(text : string)
  local textLabel = Instance.new("TextLabel");
  textLabel.TextColor3 = Color3.fromRGB(255,255,255);
  textLabel.Text = text;
  textLabel.BackgroundTransparency = 1;
  textLabel.LayoutOrder = -1;
  textLabel.Size = UDim2.new(0,50,0.8,0);
  return textLabel;
end

function WidgetUI.menuButton(text : string)
  local button = Instance.new("TextButton");
  button.Name = text;
  button.Size = UDim2.new(0, 100, 0.8, 0);
  button.Text = text;
  button.TextColor3 = Color3.fromRGB(255,255,255);
  button.BackgroundColor3 = UNSELECTED_COLOR;
  button.TextStrokeTransparency = 1;

  local uiCorner = Instance.new("UICorner");
  uiCorner.Parent = button;

  return button;
end

function WidgetUI.clearMenuPage(menuPage : Frame)
  for _, child in menuPage:GetChildren() do
    if child:IsA("UIAspectRatioConstraint") then continue end;
    child:Destroy();
  end
end

function WidgetUI.loadMenuPage(menuPage : Frame)
  WidgetUI.clearMenuPage(menuPage);
  if selectedMenuValue.Value == "Camera" then
    local menuFrame = Instance.new("Frame");
    menuFrame.Size = UDim2.new(1,0,0,40);
    menuFrame.BackgroundTransparency = 1;
    menuFrame.BorderSizePixel = 0;
    menuFrame.BackgroundColor3 = Color3.fromRGB(10,10,10);
    menuFrame.Parent = menuPage;
    
    local uiListLayout = Instance.new("UIListLayout");
    uiListLayout.FillDirection = Enum.FillDirection.Horizontal;
    uiListLayout.Padding = UDim.new(0,6);
    uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder;
    uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center;
    uiListLayout.Parent = menuFrame;

    local uiPadding = Instance.new("UIPadding");
    uiPadding.PaddingLeft = UDim.new(0,6);
    uiPadding.Parent = menuFrame;

    local presetsLabel = WidgetUI.menuPageSettingLabel("Presets");
    presetsLabel.Parent = menuFrame;

    for i, presetData in PRESET_SETTINGS do
      local button = WidgetUI.menuButton(presetData.presetName);
      button.LayoutOrder = i;
      button.Size = UDim2.new(0, 70, 0.8, 0);
      button.Parent = menuFrame;

      button.Activated:Connect(function()
       
      end)
    end

  elseif selectedMenuValue.Value == "Effects" then
    print("hi")
  end
end

function WidgetUI.createMenu()
  local menuFrame = Instance.new("Frame");
  menuFrame.Size = UDim2.new(1,0,0,40);
  menuFrame.BackgroundTransparency = 0;
  menuFrame.BorderSizePixel = 0;
  menuFrame.BackgroundColor3 = Color3.fromRGB(10,10,10);
  
  local uiListLayout = Instance.new("UIListLayout");
  uiListLayout.FillDirection = Enum.FillDirection.Horizontal;
  uiListLayout.Padding = UDim.new(0,6);
  uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder;
  uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center;
  uiListLayout.Parent = menuFrame;

  local uiPadding = Instance.new("UIPadding");
  uiPadding.PaddingLeft = UDim.new(0,6);
  uiPadding.Parent = menuFrame;

  for i = 1, #menuOptions do
    local button = WidgetUI.menuButton(menuOptions[i]);
    button.LayoutOrder = i;
    button.BackgroundColor3 = menuOptions[i] == selectedMenuValue.Value and SELECTED_COLOR or UNSELECTED_COLOR;
    button.Parent = menuFrame;

    -- Activation
    button.Activated:Connect(function()
      selectedMenuValue.Value = menuOptions[i];
    end)

    -- Update the selection color
    selectedMenuValue:GetPropertyChangedSignal("Value"):Connect(function()
      if selectedMenuValue.Value == menuOptions[i] then
        button.BackgroundColor3 = SELECTED_COLOR;
      else
        button.BackgroundColor3 = UNSELECTED_COLOR;
      end
    end)
  end

  return menuFrame;
end

function WidgetUI.create(plugin)
  local widget = plugin:CreateDockWidgetPluginGuiAsync("ModelLensUI", widgetInfo)
  widget.Title = "ModelLens";
  widget.Enabled = true;

  local background = Instance.new("Frame")
  background.Size = UDim2.fromScale(1, 1);
  background.BackgroundColor3 = Color3.fromRGB(50,50,50)
  background.Parent = widget

  local uiListLayout = Instance.new("UIListLayout");
  uiListLayout.Parent = background;

  local menuFrame = WidgetUI.createMenu();
  menuFrame.Parent = background;

  local menuPage = Instance.new("Frame");
  menuPage.Size = UDim2.new(1,0,0,150);
  menuPage.BackgroundColor3 = Color3.fromRGB(30, 30, 30);
  menuPage.BorderSizePixel = 0;
  menuPage.Parent = background;
  WidgetUI.loadMenuPage(menuPage);
  selectedMenuValue:GetPropertyChangedSignal("Value"):Connect(function()
    WidgetUI.loadMenuPage(menuPage);
  end)

  renderCamera.Parent = widget;

  return widget;
end

return WidgetUI;