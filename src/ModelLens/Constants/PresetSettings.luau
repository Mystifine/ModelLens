local PresetSettings = {
  {
    presetName = "Front",
    orbitX = 180,
    orbitY = 0,
  },
  {
    presetName = "Back",
    orbitX = 0,
    orbitY = 0,
  },
  {
    presetName = "Left",
    orbitX = 90,
    orbitY = 0,
  },
  {
    presetName = "Right",
    orbitX = -90,
    orbitY = 0,
  },
  {
    presetName = "Top",
    orbitX = 0,  -- not 90 to avoid gimbal lock at the pole
    orbitY = 89,
  },
  {
    presetName = "Bottom",
    orbitX = 0,
    orbitY = -89,
  },
  {
    presetName = "3/4",
    orbitX = 225,
    orbitY = 25,
  },
  {
    presetName = "Iso",
    orbitX = 225,  -- arctan(1/√2) ≈ 35.26°, the true isometric elevation
    orbitY = 35,
  },
  {
    presetName = "3/4 Alt",
    orbitX = 45,   -- 225 - 180
    orbitY = 25,
  },
  {
    presetName = "Iso Alt",
    orbitX = 45,   -- 225 - 180
    orbitY = 35,
  },
}

return PresetSettings