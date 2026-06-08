local AssetService = game:GetService("AssetService");
local CaptureService = game:GetService('CaptureService');
local RunService = game:GetService("RunService");

local EffectProperties = require(script.Parent.Parent.States.EffectProperties);
local RenderCache = require(script.Parent.Parent.States.RenderCache);

local ColorSettings = require(script.Parent.Parent.Constants.ColorSettings);

local RENDER_SIZE = 1024;

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
  padding = padding or 1.1;
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

function ViewportFrameUtil.waitForViewportReady(viewportFrame : ViewportFrame)
  if viewportFrame.AbsoluteSize == Vector2.zero then
    viewportFrame:GetPropertyChangedSignal("AbsoluteSize"):Wait()
  end

  -- Count descendants to estimate render complexity
  local object = viewportFrame:FindFirstChildWhichIsA("BasePart") 
    or viewportFrame:FindFirstChildWhichIsA("Model")
  
  local descendantCount = 0
  if object then
    for _ in object:GetDescendants() do
      descendantCount += 1
    end
  end

  -- Scale frames: base 30, +1 per 1 descendants max at 600 frames which is 10 seconds
  local frameCount = math.clamp(30 + math.ceil(descendantCount / 1), 30, 600)

  for _ = 1, frameCount do
    RunService.Heartbeat:Wait()
  end
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

function ViewportFrameUtil._captureWithTransparency(newViewportFrame : ViewportFrame) : string
  newViewportFrame.BackgroundColor3 = Color3.fromRGB(128,128,128);
  ViewportFrameUtil.waitForViewportReady(newViewportFrame);
  local greyImage = ViewportFrameUtil._processScreenshot(ViewportFrameUtil._captureScreenShotAsync())

  newViewportFrame.BackgroundColor3 = Color3.fromRGB(255,255,255);
  ViewportFrameUtil.waitForViewportReady(newViewportFrame);
  local whiteImage = ViewportFrameUtil._processScreenshot(ViewportFrameUtil._captureScreenShotAsync());

  -- alpha reconstruction at RENDER_SIZE (both already cropped/scaled)
  local size = greyImage.Size
  local greyPixels = greyImage:ReadPixelsBuffer(Vector2.zero, size)
  local whitePixels = whiteImage:ReadPixelsBuffer(Vector2.zero, size)

  local outputImage = AssetService:CreateEditableImage({ Size = size })
  local outputBuffer = buffer.create(size.X * size.Y * 4)

  for i = 0, size.X * size.Y - 1 do
    local idx = i * 4

    local gR = buffer.readu8(greyPixels, idx)     / 255
    local gG = buffer.readu8(greyPixels, idx + 1) / 255
    local gB = buffer.readu8(greyPixels, idx + 2) / 255
    local wR = buffer.readu8(whitePixels, idx)     / 255
    local wG = buffer.readu8(whitePixels, idx + 1) / 255
    local wB = buffer.readu8(whitePixels, idx + 2) / 255

    -- alpha = 1 - 2*(white - grey)
    -- use average of channels for more stable alpha
    local alphaR = 1 - 2 * (wR - gR)
    local alphaG = 1 - 2 * (wG - gG)
    local alphaB = 1 - 2 * (wB - gB)
    local alpha = (alphaR + alphaG + alphaB) / 3

    local r, g, b
    if alpha > 0 then
      -- object_color = (grey - GREY*(1-alpha)) / alpha
      r = (gR - 0.5 * (1 - alpha)) / alpha
      g = (gG - 0.5 * (1 - alpha)) / alpha
      b = (gB - 0.5 * (1 - alpha)) / alpha
    else
      r, g, b = 0, 0, 0
    end

    buffer.writeu8(outputBuffer, idx,     math.round(math.clamp(r, 0, 1) * 255))
    buffer.writeu8(outputBuffer, idx + 1, math.round(math.clamp(g, 0, 1) * 255))
    buffer.writeu8(outputBuffer, idx + 2, math.round(math.clamp(b, 0, 1) * 255))
    buffer.writeu8(outputBuffer, idx + 3, math.round(math.clamp(alpha, 0, 1) * 255))
  end

  outputImage:WritePixelsBuffer(Vector2.zero, size, outputBuffer)
  return outputImage
end

function ViewportFrameUtil._processScreenshot(contentId : string)
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
      PivotPoint = Vector2.new(
        cropOrigin.X + cropSize / 2,
        cropOrigin.Y + cropSize / 2
      ),
    },
    Enum.ImageCombineType.Overwrite
  )
  return croppedImage;
end

function ViewportFrameUtil.applyStroke(image : EditableImage)
  local strokeColor = ColorSettings.StrokeColor[EffectProperties.strokeColor.Value];
  local backgroundColor = ColorSettings.BackgroundColor[EffectProperties.backgroundColor.Value];
  local thickness = math.floor(EffectProperties.strokeThickness.Value);

  if EffectProperties.backgroundColor.Value == "Transparent" then
    backgroundColor = nil;
  end

  local size = image.Size
  local pixels = image:ReadPixelsBuffer(Vector2.zero, size)
  local totalPixels = size.X * size.Y;
  local bufferSize = totalPixels * 4;

  if buffer.len(pixels) ~= bufferSize then
    warn("Buffer size mismatch:", buffer.len(pixels), "expected:", bufferSize)
    return
  end

  local outputBuffer = buffer.create(bufferSize)
  buffer.copy(outputBuffer, 0, pixels, 0, bufferSize)

  local sr = math.round(strokeColor.R * 255)
  local sg = math.round(strokeColor.G * 255)
  local sb = math.round(strokeColor.B * 255)

  -- pre-compute background RGB if provided
  local bgR, bgG, bgB
  if backgroundColor then
    bgR = math.round(backgroundColor.R * 255)
    bgG = math.round(backgroundColor.G * 255)
    bgB = math.round(backgroundColor.B * 255)
  end

  local TOLERANCE = 15  -- handles screenshot compression artifacts

  local function isBackground(idx)
    if backgroundColor == nil then
      local alpha = buffer.readu8(pixels, idx + 3);
      return alpha < TOLERANCE;
    end

    local pr = buffer.readu8(pixels, idx)
    local pg = buffer.readu8(pixels, idx + 1)
    local pb = buffer.readu8(pixels, idx + 2)

    return math.abs(pr - bgR) <= TOLERANCE
      and math.abs(pg - bgG) <= TOLERANCE
      and math.abs(pb - bgB) <= TOLERANCE
  end

  local edgeMask = buffer.create(totalPixels);

  for y = 0, size.Y - 1 do
    for x = 0, size.X - 1 do
      local idx = (y * size.X + x) * 4;
      if idx + 3 >= bufferSize then continue end;
      if not isBackground(idx) then continue end

      for dy = -thickness, thickness do
        for dx = -thickness, thickness do
          if dx*dx + dy*dy > thickness*thickness then continue end
          local nx = x + dx
          local ny = y + dy
          if nx < 0 or ny < 0 or nx >= size.X or ny >= size.Y then continue end
          local nIdx = (ny * size.X + nx) * 4;
          if nIdx + 3 >= bufferSize then continue end;
          if not isBackground((ny * size.X + nx) * 4) then
            buffer.writeu8(edgeMask, y * size.X + x,1);
            break
          end
        end
        if buffer.readu8(edgeMask, y *size.X + x) == 1 then break end
      end
    end
  end

  for i = 0, totalPixels - 1 do
    if buffer.readu8(edgeMask, i) == 1 then
      local idx = i * 4;
      buffer.writeu8(outputBuffer, idx,     sr)
      buffer.writeu8(outputBuffer, idx + 1, sg)
      buffer.writeu8(outputBuffer, idx + 2, sb)
      buffer.writeu8(outputBuffer, idx + 3, 255)
    end
  end

  image:WritePixelsBuffer(Vector2.zero, size, outputBuffer)
end

function ViewportFrameUtil.captureViewport(viewportFrame : ViewportFrame)

  local screenGui = Instance.new("ScreenGui");
  screenGui.Name = "ModelLens_Capture";
  screenGui.IgnoreGuiInset = true;
  screenGui.DisplayOrder = 999;
  screenGui.Parent = game.CoreGui;

  local newViewportFrame = viewportFrame:Clone(); -- should contain all the old settings
  newViewportFrame.CurrentCamera = newViewportFrame:FindFirstChildOfClass("Camera"); -- comes from the render previously
  newViewportFrame.Size = UDim2.fromScale(1, 1);
  newViewportFrame.AnchorPoint = Vector2.new(0,0);
  newViewportFrame.BackgroundColor3 = ColorSettings.BackgroundColor[EffectProperties.backgroundColor.Value];
  newViewportFrame.Position = UDim2.fromScale(0, 0);
  newViewportFrame.BackgroundTransparency = 0;
  newViewportFrame.BorderSizePixel = 0;
  newViewportFrame.Parent = screenGui;

  -- Destroy UICorner if it exists
  local uiCorner = newViewportFrame:FindFirstChildOfClass("UICorner");
  if uiCorner then
    uiCorner:Destroy();
  end

  ViewportFrameUtil.waitForViewportReady(newViewportFrame)
  local ok ,result = pcall(function()
    local transparent = EffectProperties.backgroundColor.Value == "Transparent";
    if transparent then
      return ViewportFrameUtil._captureWithTransparency(newViewportFrame);
    else
      local contentId = ViewportFrameUtil._captureScreenShotAsync();
      local croppedImage = ViewportFrameUtil._processScreenshot(contentId);
      return croppedImage;
    end
  end)
  
  screenGui:Destroy();
  if not ok then
    warn("ModelLens Capture Failed:", result);
    return nil;
  end
  return result;
end

function ViewportFrameUtil.cloneEditableImage(source : EditableImage)
  local newImage = AssetService:CreateEditableImage({ Size = source.Size })
  local pixels = source:ReadPixelsBuffer(Vector2.zero, source.Size)
  newImage:WritePixelsBuffer(Vector2.zero, source.Size, pixels)
  return newImage
end

function ViewportFrameUtil.exportCaptures(output : Folder)
  local renderCache = RenderCache.getCache();

  local meshPartSize = 10;
  local padding = 1;

  local center = Vector3.new(0,meshPartSize,0);
  local count = 0;
  for object, cacheData in renderCache do
    if not cacheData.capture then continue end;
    local ok, err = pcall(function()
      
      -- Making a copy to use as export
      cacheData.exportCapture = ViewportFrameUtil.cloneEditableImage(cacheData.capture);

      if EffectProperties.strokeThickness.Value > 0 then
        ViewportFrameUtil.applyStroke(cacheData.exportCapture);
      end

      local meshPart = Instance.new("MeshPart");
      meshPart.Name = string.format("%s_capture", object.Name);
      meshPart.Size = Vector3.new(meshPartSize,meshPartSize,0.01);
      meshPart.Position = center + Vector3.new((meshPartSize+padding) * count,0,0)
      meshPart.TextureContent = Content.fromObject(cacheData.exportCapture);
      meshPart.Parent = output;
    end)

    if not ok then
      warn("ModelLens Export Failed for", object.Name, ":", err);
    else
      count += 1;
    end
  end
end

return ViewportFrameUtil;