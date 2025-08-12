-- ZX Spectrum Sprite Sheet Generator
-- By Paul "Spectre" Harthen

local dlg = Dialog("Anagrams Sprite Sheet")

-- Palette generation logic
local function createSpriteSheet()
  local data = dlg.data
  local spriteSize = tonumber(data.spriteSize)
  local gridX = tonumber(data.gridX)
  local gridY = tonumber(data.gridY)
  local numColors = tonumber(data.numColors)

  if not (spriteSize and gridX and gridY and numColors) then
    app.alert("Please enter valid numeric values!")
    return
  end

  if gridX <= 0 or gridY <= 0 then
    app.alert("Grid dimensions must be positive numbers!")
    return
  end

  local width = spriteSize * gridX
  local height = spriteSize * gridY

  local sprite = Sprite(width, height, ColorMode.INDEXED)
  local palette = sprite.palettes[1]
  palette:resize(numColors)

  -- ZX Spectrum 16-colour palette (non-bright + bright)
  local spectrum16 = {
    {0, 0, 0},       -- Black
    {0, 0, 205},     -- Blue
    {205, 0, 0},     -- Red
    {205, 0, 205},   -- Magenta
    {0, 205, 0},     -- Green
    {0, 205, 205},   -- Cyan
    {205, 205, 0},   -- Yellow
    {205, 205, 205}, -- White
    {0, 0, 0},       -- Bright Black (same as normal)
    {0, 0, 255},     -- Bright Blue
    {255, 0, 0},     -- Bright Red
    {255, 0, 255},   -- Bright Magenta
    {0, 255, 0},     -- Bright Green
    {0, 255, 255},   -- Bright Cyan
    {255, 255, 0},   -- Bright Yellow
    {255, 255, 255}, -- Bright White
  }

  if numColors == 16 then
    for i = 0, 15 do
      local c = spectrum16[i + 1]
      palette:setColor(i, Color{r = c[1], g = c[2], b = c[3]})
    end

  elseif numColors == 32 then
      palette:setColor(0, Color{r = 0x0, g = 0x0, b = 0x0})
      palette:setColor(1, Color{r = 0x0, g = 0x0, b = 0x49})
      palette:setColor(2, Color{r = 0xff, g = 0x0, b = 0x0})
      palette:setColor(3, Color{r = 0x0, g = 0x0, b = 0xff})
      palette:setColor(4, Color{r = 0xff, g = 0xff, b = 0xdb})
      palette:setColor(5, Color{r = 0xff, g = 0xff, b = 0xff})
      palette:setColor(6, Color{r = 0x0, g = 0x0, b = 0x0})
      palette:setColor(7, Color{r = 0x0, g = 0x0, b = 0x0})

      palette:setColor(8, Color{r = 0x0, g = 0x0, b = 0x0})
      palette:setColor(9, Color{r = 0x0, g = 0x0, b = 0x0})
      palette:setColor(10, Color{r = 0x0, g = 0x0, b = 0x0})
      palette:setColor(11, Color{r = 0x0, g = 0x0, b = 0x0})
      palette:setColor(12, Color{r = 0x0, g = 0x0, b = 0x0})
      palette:setColor(13, Color{r = 0x0, g = 0x0, b = 0x0})
      palette:setColor(14, Color{r = 0x0, g = 0x0, b = 0x0})
      palette:setColor(15, Color{r = 0x0, g = 0x0, b = 0x0})

      palette:setColor(16, Color{r = 0x0, g = 0x0, b = 0x0})
      palette:setColor(17, Color{r = 0x0, g = 0x0, b = 0x0})
      palette:setColor(18, Color{r = 0x0, g = 0x0, b = 0x0})
      palette:setColor(19, Color{r = 0x0, g = 0x0, b = 0x0})
      palette:setColor(20, Color{r = 0x0, g = 0x0, b = 0x0})
      palette:setColor(21, Color{r = 0x0, g = 0x0, b = 0x0})
      palette:setColor(22, Color{r = 0x0, g = 0x0, b = 0x0})
      palette:setColor(23, Color{r = 0x0, g = 0x0, b = 0x0})

      palette:setColor(24, Color{r = 0x0, g = 0x0, b = 0x0})
      palette:setColor(25, Color{r = 0x0, g = 0x0, b = 0x0})
      palette:setColor(26, Color{r = 0x0, g = 0x0, b = 0x0})
      palette:setColor(27, Color{r = 0x0, g = 0x0, b = 0x0})
      palette:setColor(28, Color{r = 0x0, g = 0x0, b = 0x0})
      palette:setColor(29, Color{r = 0x0, g = 0x0, b = 0x0})
      palette:setColor(30, Color{r = 0x0, g = 0x0, b = 0x0})
      palette:setColor(31, Color{r = 0xDB, g = 0x24, b = 0x6D})

  elseif numColors == 256 then
    -- ZX Spectrum Next 256-colour RRRGGGBB palette
    local steps = {0, 36, 73, 109, 146, 182, 219, 255}
    local blueSteps = {0, 85, 170, 255}
    local index = 0
    for r = 0, 7 do
      for g = 0, 7 do
        for b = 0, 3 do
          palette:setColor(index, Color{
            r = steps[r + 1],
            g = steps[g + 1],
            b = blueSteps[b + 1]
          })
          index = index + 1
        end
      end
    end

  elseif numColors == 512 then
    -- ZX Spectrum Next 512-colour RRRGGGBBB palette
    local steps = {0, 36, 73, 109, 146, 182, 219, 255}
    local index = 0
    for r = 0, 7 do
      for g = 0, 7 do
        for b = 0, 7 do
          if index < numColors then
            palette:setColor(index, Color{
              r = steps[r + 1],
              g = steps[g + 1],
              b = steps[b + 1]
            })
            index = index + 1
          end
        end
      end
    end

  else
    app.alert("Unsupported colour count: " .. numColors)
  end
end

-- Build the dialog
dlg:combobox{
  id = "spriteSize",
  label = "Sprite Size",
  options = { "8", "16" },
  option = "16"
}

dlg:number{
  id = "gridX",
  label = "Grid Size X",
  text = "8"
}

dlg:number{
  id = "gridY",
  label = "Grid Size Y",
  text = "8"
}

dlg:combobox{
  id = "numColors",
  label = "Number of Colours",
  options = { "16", "32", "256", "512" },
  option = "32"
}

dlg:button{
  id = "create",
  text = "Create",
  onclick = function()
    createSpriteSheet()
    dlg:close()
  end
}

dlg:button{
  id = "cancel",
  text = "Cancel",
  onclick = function()
    dlg:close()
  end
}

dlg:show()