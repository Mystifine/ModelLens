# ModelLens

A Roblox Studio plugin for capturing and exporting high-quality PNG thumbnails of 3D models — without leaving Studio.

Select your models, adjust the camera, hit Capture, then Export. Done.

**[Get ModelLens on the Roblox Creator Store](https://create.roblox.com/store/asset/138348131240071/ModelLens)**

---

## Features

**Camera control**
- Orbit, tilt, pan, zoom, and FOV controls
- Preset angles: Front, Back, Left, Right, Top, Bottom, 3/4, Iso, and their alternates
- Save and load custom camera/effect profiles

**Capture**
- High-resolution captures at native screen resolution, downscaled to 1024×1024
- Transparent background support via dual grey/white capture with per-pixel alpha reconstruction
- Solid backgrounds: Black, Grey, Green (chroma key)
- Batch capture multiple models in sequence

**Effects**
- Outline stroke with adjustable thickness and color
- Flat ambient lighting mode for unbiased icon renders
- Adjustable brightness and ambient light

**Export**
- Exports as MeshParts with texture applied, ready for OBJ export
- Exports laid out in a grid in Workspace for easy selection

---

## Installation

1. Get the plugin from the [Roblox Creator Store](https://create.roblox.com/store/asset/138348131240071/ModelLens)
2. Or install manually: download the `.rbxmx` file, place it in your local plugins folder, and restart Studio
   - Windows: `%localappdata%\Roblox\Plugins`
   - Mac: `~/Documents/Roblox/Plugins`

---

## How to use

### Capturing images

1. Select one or more `BasePart` or `Model` instances in the Explorer
2. Thumbnails appear in the ModelLens panel automatically
3. Adjust camera settings using the sliders or click a preset angle
4. Switch to the **Effects** tab to set background color, stroke color, and stroke thickness
5. Press **Capture** — the screen will flash briefly as each object is rendered at full resolution
6. Press **Export** — a `ModelLensExports` folder appears in Workspace containing one `MeshPart` per object with the texture applied

### Exporting as PNG

1. Select the `ModelLensExports` folder in the Explorer
2. Right-click → **Export Selection** → save as OBJ (group them to mass export)
3. Discard non-PNG files

### Camera presets

Click any preset button in the Camera tab to snap to that angle. The available presets are:

| Preset | Description |
|--------|-------------|
| Front | Straight on from the front |
| Back | Straight on from the back |
| Left | From the left side |
| Right | From the right side |
| Top | Looking straight down |
| Bottom | Looking straight up |
| 3/4 | Classic three-quarter view |
| Iso | True isometric (35.26° elevation) |
| 3/4 Alt | Three-quarter from the opposite diagonal |
| Iso Alt | Isometric from the opposite diagonal |

### Saving profiles

1. Go to the **Camera** or **Effects** tab and configure your settings
2. Press **Save Preset** — enter a name and save
3. Saved profiles appear in the profiles list and can be loaded or deleted at any time
4. Profiles persist across Studio sessions

---

## Tips

- **Transparent backgrounds** capture twice (black/grey + white) to reconstruct alpha — expect a brief double flash per object
- **Stroke only works with transparent** backgrounds for full geometry accuracy; solid backgrounds use color-based edge detection
- **Complex models** with many descendants take longer to capture — the plugin waits proportionally more frames before shooting
- **Screen resolution matters** — captures at native resolution before downscaling to 1024×1024, so a larger monitor gives sharper results
- For the sharpest possible output, resize the Studio window to approximately 1024×1024 before capturing to eliminate any downscaling (You can create a custom device by going to studio Test/Device Emulator/Manage Devices) or if lazy set to 1920x1080.

---

## Limitations

- `EditableImage` is capped at 1024×1024 — this is a Roblox engine limit
- The screen flashes during capture — this is unavoidable with the current Roblox capture API
- Photosensitive users should be aware of the screen flashing during transparent captures
- `Highlight` instances do not render inside `ViewportFrame` — stroke effects are applied via pixel processing at export time
- Requires the **Mesh and Image APIs** to be enabled in game settings for `EditableImage` support

---

## Technical overview

ModelLens uses a fullscreen `ViewportFrame` parented to `CoreGui` for each capture. For transparent backgrounds, it shoots twice against grey (128, 128, 128) and white (255, 255, 255) backgrounds, then reconstructs alpha per-pixel using the formula:

```
alpha = 1 - 2 * (white - grey)
color = (grey_sample - 0.5 * (1 - alpha)) / alpha
```

Stroke is applied as a post-process on the `EditableImage` pixel buffer — scanning for background-adjacent pixels and writing the stroke color. For transparent captures, stroke is applied to both the grey and white captures before alpha reconstruction so it survives the compositing step.

Screenshots are cropped to a square at the center of the screen and downscaled to 1024×1024 using `DrawImageTransformed`.

---

## Credits

- Inspired by [EgoMoose's Photobooth Plugin](https://egomoose.itch.io/rbx-photobooth-plugin)
- Also inspired by [Multi Photobooth](https://create.roblox.com/store/asset/136160532154714/Multi-Photobooth)

---

## License

MIT