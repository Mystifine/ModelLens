local InstanceExtensionsService = game:GetService("InstanceExtensionsService")
local UserInputService = game:GetService("UserInputService");
local ValueService = require(script.Parent.ValueService);

local PRESET_SETTINGS = require(script.Parent.PresetSettings)
local SelectionService = require(script.Parent.SelectionService)

-- Widget Settings
local FRAME_SIZE_X, FRAME_SIZE_Y = 400, 300;
local MIN_FRAME_SIZE_X, MIN_FRAME_SIZE_Y = 300, 200;
local widgetInfo = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float,true,false,FRAME_SIZE_X,FRAME_SIZE_Y,MIN_FRAME_SIZE_X,MIN_FRAME_SIZE_Y)

-- Top Menu Selection Settings
local menuOptions = {"Camera", "Effects"};
local selectedMenuValue = ValueService.stringValue(menuOptions[1]);
local UNSELECTED_COLOR = Color3.fromRGB(50,50,50);
local SELECTED_COLOR = Color3.fromRGB(76, 103, 255)

-- For dragging
local isDragging = false;
local mouseX, mouseY = 0, 0;

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

local cachedRenders = {};
function WidgetUI.createViewportFrame(object : BasePart | Model)
  local viewportFrameContainer = Instance.new("Frame");
  viewportFrameContainer.Size = UDim2.new(0,120,0,135,0);
  viewportFrameContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30);
  viewportFrameContainer.BackgroundTransparency = 0;
  viewportFrameContainer.BorderSizePixel = 0;

  local uiCorner = Instance.new("UICorner");
  uiCorner.Parent = viewportFrameContainer;
  
  local viewportFrame = Instance.new("ViewportFrame");
  viewportFrame.Size = UDim2.fromOffset(110, 110);
  viewportFrame.Position = UDim2.new(0.5,0,0,5);
  viewportFrame.AnchorPoint = Vector2.new(0.5,0);
  viewportFrame.BackgroundColor3 = Color3.fromRGB(0,0,0);
  viewportFrame.CurrentCamera = renderCamera;
  viewportFrame.Parent = viewportFrameContainer;

  local uiCorner2 = Instance.new("UICorner");
  uiCorner2.Parent = viewportFrame;
  
  local textLabel = Instance.new("TextLabel");
  textLabel.BackgroundTransparency = 1;
  textLabel.AnchorPoint = Vector2.new(0,1);
  textLabel.Size = UDim2.new(1,0,0,20);
  textLabel.Position = UDim2.new(0,0,1,0);
  textLabel.TextColor3 = Color3.fromRGB(255,255,255);
  textLabel.Text = object.Name;
  textLabel.Parent = viewportFrameContainer;

  cachedRenders[object] = viewportFrameContainer;

  return viewportFrameContainer;
end

function WidgetUI.createSlider(labelText, min, max, valueObject, callback)
  local sliderContainerFrame = Instance.new("Frame");
  sliderContainerFrame.Size = UDim2.new(1,0,0,30);
  sliderContainerFrame.BackgroundTransparency = 1;

  local uiListLayout = Instance.new("UIListLayout");
  uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center;
  uiListLayout.FillDirection = Enum.FillDirection.Horizontal;
  uiListLayout.Padding = UDim.new(0,0);
  uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder;
  uiListLayout.Parent = sliderContainerFrame;

  local uiPadding = Instance.new("UIPadding");
  uiPadding.PaddingLeft = UDim.new(0,6);
  uiPadding.Parent = sliderContainerFrame;

  local settingLabel = WidgetUI.pageRowSettingLabel(labelText);
  settingLabel.LayoutOrder = 0;
  settingLabel.Parent = sliderContainerFrame;

  local valueLabel = Instance.new("TextLabel");
  valueLabel.Text = tostring(valueObject.Value);
  valueLabel.Size = UDim2.new(0,30,0.8,0);
  valueLabel.TextXAlignment = Enum.TextXAlignment.Right;
  valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255);
  valueLabel.BackgroundTransparency = 1;
  valueLabel.LayoutOrder = 2;
  valueLabel.Parent = sliderContainerFrame;
  
  local sliderFrame = Instance.new("Frame");
  sliderFrame.Size = UDim2.new(1, -uiPadding.PaddingLeft.Offset - settingLabel.AbsoluteSize.X - valueLabel.AbsoluteSize.X, 1, 0);
  sliderFrame.BackgroundTransparency = 1;
  sliderFrame.LayoutOrder = 1;
  sliderFrame.Parent = sliderContainerFrame;

  -- The slider background line
  local track = Instance.new("Frame");
  track.Size = UDim2.new(0.975, 0, 0, 6);
  track.AnchorPoint = Vector2.new(0,0.5);
  track.Position = UDim2.new(0, 0, 0.5, 0);
  track.BackgroundColor3 = Color3.fromRGB(80, 80, 80);
  track.BorderSizePixel = 0;
  track.Parent = sliderFrame;

  -- The visual fill bar
  local fill = Instance.new("Frame");
  fill.Size = UDim2.new((valueObject.Value - min) / (max - min), 0, 1, 0);
  fill.BackgroundColor3 = Color3.fromRGB(0, 162, 255); -- Studio Blue
  fill.BorderSizePixel = 0;
  fill.Parent = track;

  local fillUICorner = Instance.new("UICorner"); 
  fillUICorner.CornerRadius = UDim.new(0, 3); 
  fillUICorner.Parent = fill;

  local trackUICorner = Instance.new("UICorner"); 
  trackUICorner.CornerRadius = UDim.new(0, 3); 
  trackUICorner.Parent = track;

  -- The draggable knob
  local knob = Instance.new("TextButton");
  knob.Size = UDim2.new(0, 14, 0, 14);
  knob.AnchorPoint = Vector2.new(0, 0.5);
  knob.Position = UDim2.new(fill.Size.X.Scale, -7, 0.5, 0);
  knob.BackgroundColor3 = Color3.fromRGB(200, 200, 200);
  knob.Text = "";
  knob.Parent = track;

  local knobUICorner = Instance.new("UICorner"); 
  knobUICorner.CornerRadius = UDim.new(1, 0); 
  knobUICorner.Parent = knob;

  -- Dragging Logic
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
    valueLabel.Text = tostring(roundedValue);

    -- Send the value back to your main script to apply camera changes!
    if callback then
      callback(roundedValue);
    end
  end

  -- Start Dragging
  knob.MouseButton1Down:Connect(function()
    isDragging = true;
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255); -- Light up on hover/click
  
    while isDragging do
      updateSlider(Vector2.new(mouseX, mouseY));
      task.wait();
    end
  end);

  sliderContainerFrame.MouseMoved:Connect(function(x, y)
    mouseX = x;
    mouseY = y;
  end)

  -- Stop Dragging
  knob.MouseButton1Up:Connect(function()
    isDragging = false;
    knob.BackgroundColor3 = Color3.fromRGB(200, 200, 200);
  end);

  return sliderContainerFrame;
end

function WidgetUI.pageRowSettingLabel(text : string)
  local textLabel = Instance.new("TextLabel");
  textLabel.TextColor3 = Color3.fromRGB(255,255,255);
  textLabel.Text = text;
  textLabel.BackgroundTransparency = 1;
  textLabel.LayoutOrder = -1;
  textLabel.TextXAlignment = Enum.TextXAlignment.Left;
  textLabel.Size = UDim2.new(0,90,0.8,0);
  return textLabel;
end

function WidgetUI.menuButton(text : string)
  local button = Instance.new("TextButton");
  button.Name = text;
  button.Size = UDim2.new(0, 100, 0.7, 0);
  button.Text = text;
  button.TextColor3 = Color3.fromRGB(255,255,255);
  button.BackgroundColor3 = UNSELECTED_COLOR;
  button.TextStrokeTransparency = 1;

  local uiCorner = Instance.new("UICorner");
  uiCorner.Parent = button;

  return button;
end

function WidgetUI.clearPageFrame(pageFrame : Frame)
  for _, child in pageFrame:GetChildren() do
    child:Destroy();
  end
end

function WidgetUI.loadPageFrame(pageFrame : Frame)
  WidgetUI.clearPageFrame(pageFrame);

  local menuPageUIListLayout = Instance.new("UIListLayout");
  menuPageUIListLayout.FillDirection = Enum.FillDirection.Vertical;
  menuPageUIListLayout.Parent = pageFrame;

  if selectedMenuValue.Value == "Camera" then
    local presetsMenuFrame = Instance.new("Frame");
    presetsMenuFrame.Size = UDim2.new(1,0,0,40);
    presetsMenuFrame.BackgroundTransparency = 1;
    presetsMenuFrame.BorderSizePixel = 0;
    presetsMenuFrame.BackgroundColor3 = Color3.fromRGB(10,10,10);
    presetsMenuFrame.Parent = pageFrame;
    
    local uiListLayout = Instance.new("UIListLayout");
    uiListLayout.FillDirection = Enum.FillDirection.Horizontal;
    uiListLayout.Padding = UDim.new(0,6);
    uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder;
    uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center;
    uiListLayout.Parent = presetsMenuFrame;

    local uiPadding = Instance.new("UIPadding");
    uiPadding.PaddingLeft = UDim.new(0,6);
    uiPadding.Parent = presetsMenuFrame;

    local presetsLabel = WidgetUI.pageRowSettingLabel("Presets");
    presetsLabel.Parent = presetsMenuFrame;

    for i, presetData in PRESET_SETTINGS do
      local button = WidgetUI.menuButton(presetData.presetName);
      button.LayoutOrder = i;
      button.Size = UDim2.new(0, 70, 0.8, 0);
      button.Parent = presetsMenuFrame;

      button.Activated:Connect(function()
       
      end)
    end

    for camSetting, settingVal in cameraSettings do
      local newSlider = WidgetUI.createSlider(camSetting, 0, 180, settingVal, function(a0: number?)
        print("Updateing")
      end)
      newSlider.Parent = pageFrame;
    end
  elseif selectedMenuValue.Value == "Effects" then
    print("hi")
  end
end

function WidgetUI.createHeaderMenu()
  local headerMenuFrame = Instance.new("Frame");
  headerMenuFrame.Size = UDim2.new(1,0,0,40);
  headerMenuFrame.BackgroundTransparency = 0;
  headerMenuFrame.BorderSizePixel = 0;
  headerMenuFrame.BackgroundColor3 = Color3.fromRGB(10,10,10);
  
  local uiListLayout = Instance.new("UIListLayout");
  uiListLayout.FillDirection = Enum.FillDirection.Horizontal;
  uiListLayout.Padding = UDim.new(0,6);
  uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder;
  uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center;
  uiListLayout.Parent = headerMenuFrame;

  local uiPadding = Instance.new("UIPadding");
  uiPadding.PaddingLeft = UDim.new(0,6);
  uiPadding.Parent = headerMenuFrame;

  for i = 1, #menuOptions do
    local button = WidgetUI.menuButton(menuOptions[i]);
    button.LayoutOrder = i;
    button.BackgroundColor3 = menuOptions[i] == selectedMenuValue.Value and SELECTED_COLOR or UNSELECTED_COLOR;
    button.Parent = headerMenuFrame;

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

  return headerMenuFrame;
end

function WidgetUI.createBottomHeaderFrame()
  local bottomHeaderFrame = Instance.new("Frame");
  bottomHeaderFrame.BackgroundColor3 = Color3.fromRGB(20,20,20);
  bottomHeaderFrame.Size = UDim2.new(1,0,0,50);
  bottomHeaderFrame.AnchorPoint = Vector2.new(0,1);
  bottomHeaderFrame.BorderSizePixel = 0;
  bottomHeaderFrame.Position = UDim2.new(0,0,1,0);
  
  local uiListLayout = Instance.new("UIListLayout");
  uiListLayout.FillDirection = Enum.FillDirection.Horizontal;
  uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder;
  uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center;
  uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left;
  uiListLayout.Parent = bottomHeaderFrame;

  local uiPadding = Instance.new("UIPadding");
  uiPadding.PaddingLeft = UDim.new(0,6);
  uiPadding.Parent = bottomHeaderFrame;

  local exportButton = WidgetUI.menuButton("Export All");
  exportButton.Size = UDim2.new(0,150,exportButton.Size.Y.Scale,exportButton.Size.Y.Offset);
  exportButton.BackgroundColor3 = Color3.fromRGB(0, 168, 114);
  exportButton.LayoutOrder = 1;
  exportButton.Parent = bottomHeaderFrame;

  local outputLabel = Instance.new("TextLabel");
  outputLabel.Text = "Select parts/models and press export";
  outputLabel.BackgroundTransparency = 1;
  outputLabel.TextColor3 = Color3.fromRGB(255,255,255);
  outputLabel.Size = UDim2.new(1,-exportButton.AbsoluteSize.X - uiPadding.PaddingLeft.Offset,1,0);
  outputLabel.TextXAlignment = Enum.TextXAlignment.Left;
  outputLabel.LayoutOrder = 0;
  outputLabel.Parent = bottomHeaderFrame;

  return bottomHeaderFrame;
end

function WidgetUI.updateViewportFrameRenders(viewportsScrollingFrame : ScrollingFrame, selections)
  -- Clear old viewports that are not selected
  for object, viewportFrame in cachedRenders do
    if not table.find(selections, object) then
      viewportFrame:Destroy();
      cachedRenders[object] = nil;
    end
  end

  -- Add missing viewports
  for _, object in selections do
    if not object:IsA("BasePart") and not object:IsA("Model") then continue end;
    if cachedRenders[object] then continue end;

    local newViewport = WidgetUI.createViewportFrame(object);
    newViewport.Parent = viewportsScrollingFrame;
  end
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
  uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder;
  uiListLayout.Parent = background;

  local headerMenuFrame = WidgetUI.createHeaderMenu();
  headerMenuFrame.LayoutOrder = 0;
  headerMenuFrame.Parent = background;

  local pageFrame = Instance.new("Frame");
  pageFrame.Size = UDim2.new(1,0,0,250);
  pageFrame.LayoutOrder = 1;
  pageFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30);
  pageFrame.BorderSizePixel = 0;
  pageFrame.Parent = background;
  
  WidgetUI.loadPageFrame(pageFrame);
  selectedMenuValue:GetPropertyChangedSignal("Value"):Connect(function()
    WidgetUI.loadPageFrame(pageFrame);
  end)

  -- To stop dragging
  UserInputService.InputEnded:Connect(function(input: InputObject, gpe : boolean)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
      isDragging = false;
    end
  end)

  local bottomHeaderFrame = WidgetUI.createBottomHeaderFrame();
  bottomHeaderFrame.LayoutOrder = 3;
  bottomHeaderFrame.Parent = background;

  local viewportsScrollingFrame = Instance.new("ScrollingFrame");
  viewportsScrollingFrame.LayoutOrder = 2;
  viewportsScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y;
  viewportsScrollingFrame.CanvasSize = UDim2.new(0,0,1,0);
  viewportsScrollingFrame.BorderSizePixel = 0;
  viewportsScrollingFrame.BackgroundTransparency = 1;
  viewportsScrollingFrame.ScrollBarThickness = 6;
  viewportsScrollingFrame.Size = UDim2.new(1,0,1,-pageFrame.AbsoluteSize.Y - headerMenuFrame.AbsoluteSize.Y - bottomHeaderFrame.AbsoluteSize.Y);
  viewportsScrollingFrame.Parent = background;

  local uiGridLayout = Instance.new("UIGridLayout");
  uiGridLayout.CellSize = UDim2.new(0,120,0,135);
  uiGridLayout.CellPadding = UDim2.new(0,4,0,4);
  uiGridLayout.Parent = viewportsScrollingFrame;

  local viewportsScrollingFramePadding = Instance.new("UIPadding");
  viewportsScrollingFramePadding.PaddingTop = UDim.new(0,6);
  viewportsScrollingFramePadding.Parent = viewportsScrollingFrame;

  SelectionService.SelectionChanged:Connect(function()
    local selections = SelectionService.getSelections();
    WidgetUI.updateViewportFrameRenders(viewportsScrollingFrame, selections)
  end)

  renderCamera.Parent = viewportsScrollingFramePadding;

  return widget;
end

return WidgetUI;