local AssetService = game:GetService("AssetService");
local CaptureService = game:GetService('CaptureService');
local RemoteDebuggerServer = game:GetService("RemoteDebuggerServer")

local ViewportFrameUtil = {};

function ViewportFrameUtil.getObjectBoundingRadius(object)
  if object:IsA("Model") then
    local cf, size = object:GetBoundingBox();
    return size.Magnitude / 2, cf.Position;
  elseif object:IsA("BasePart") then
    return object.Size.Magnitude / 2, object.Position;
  end
  return 10, Vector3.zero;
end

function ViewportFrameUtil.getAutoDistance(object, fovDegree, padding)
  padding = padding or 1.15;
  local radius, center = ViewportFrameUtil.getObjectBoundingRadius(object);
  local fovRad = math.rad(fovDegree) / 2;
  local distance = (radius / math.tan(fovRad)) * padding;
  return distance, center;
end

function ViewportFrameUtil.orbitCamera(center, distance, orbitX, orbitY, panX, panY)
  local az = math.rad(orbitX);
  local el = math.rad(orbitY);

  local x = distance * math.cos(el) * math.sin(az);
  local y = distance * math.sin(el);
  local z = distance * math.cos(el) * math.cos(az);

  local pivot = center + Vector3.new(panX,panY,0);

  return CFrame.lookAt(pivot + Vector3.new(x,y,z), pivot);
end

function ViewportFrameUtil._captureScreenShotAsync() : string
  local bindable = Instance.new("BindableEvent")
  local contentId

  CaptureService:CaptureScreenshot(function(id)
    contentId = id
    bindable:Fire()
  end)

  bindable.Event:Wait()
  bindable:Destroy()
  return contentId
end

function ViewportFrameUtil.captureViewport(viewportFrame : ViewportFrame, plugin : Plugin, output : Folder)
  local RENDER_SIZE = 1024;

  local screenGui = Instance.new("ScreenGui");
  screenGui.Name = "ModelLens_Capture";
  screenGui.IgnoreGuiInset = true;
  screenGui.DisplayOrder = 999;
  screenGui.Parent = game.CoreGui;

  local newViewportFrame = viewportFrame:Clone(); -- should contain all the old settings
  newViewportFrame.CurrentCamera = newViewportFrame:FindFirstChildOfClass("Camera"); -- comes from the render previously
  newViewportFrame.Size = UDim2.fromScale(1, 1);
  newViewportFrame.AnchorPoint = Vector2.new(0,0);
  newViewportFrame.Position = UDim2.fromScale(0, 0);
  newViewportFrame.BackgroundTransparency = 0;
  newViewportFrame.BackgroundColor3 = Color3.fromRGB(0,0,0);
  newViewportFrame.BorderSizePixel = 0;
  newViewportFrame.Parent = screenGui;

  task.wait(0.2); -- wait for render

  local ok ,err = pcall(function()
    local contentId = ViewportFrameUtil._captureScreenShotAsync();

    local fullImage = AssetService:CreateEditableImageAsync(
      Content.fromUri(contentId)
    )

    local screenSize = fullImage.Size;
    local cropSize = math.min(screenSize.X, screenSize.Y);
    local cropOrigin = Vector2.new(
      math.round( (screenSize.X - cropSize) / 2 ),
      math.round( (screenSize.Y - cropSize) / 2 )
    )

    local croppedImage = AssetService:CreateEditableImage({
      Size = Vector2.new(RENDER_SIZE, RENDER_SIZE);
    })

    --croppedImage:DrawImage(-cropOrigin, fullImage, Enum.ImageCombineType.Overwrite);

    local scale = RENDER_SIZE / cropSize
    croppedImage:DrawImageTransformed(
      Vector2.new(RENDER_SIZE / 2, RENDER_SIZE / 2),
      Vector2.new(scale, scale),
      0,
      fullImage,
      {
        Position = Vector2.new(
          cropOrigin.X + cropSize / 2,
          cropOrigin.Y + cropSize / 2
        ),
      },
      Enum.ImageCombineType.Overwrite
    )

    local meshPart = Instance.new("MeshPart");
    meshPart.Name = viewportFrame.Name;
    meshPart.Size = Vector3.new(RENDER_SIZE/100,RENDER_SIZE/100,0.01);
    meshPart.TextureContent = Content.fromObject(croppedImage);
    meshPart.Parent = output;
  end)
  
  screenGui:Destroy();
  if not ok then
    warn("ModelLens Capture Failed:", err);
  end
end

return ViewportFrameUtil;