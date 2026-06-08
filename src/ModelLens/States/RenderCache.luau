local RenderCache = {};

local cache : {
  [Object] : {
    viewportFrameContainer : Frame,
    capture : EditableImage,
    exportCapture : EditableImage,
  }
} = {};

function RenderCache.cache(object, data)
  cache[object] = data;
end

function RenderCache.setCapture(object, capture)
  local objectCache = RenderCache.getObjectCache(object);
  if not objectCache then
    return;
  end

  objectCache.capture = capture;
end

function RenderCache.clear(object)
  cache[object] = nil;
end

function RenderCache.getObjectCache(object)
  return cache[object];
end

function RenderCache.getCache()
  return cache;
end

return RenderCache;