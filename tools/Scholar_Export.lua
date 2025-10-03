-- Scholar Sprite & Palette Export tool for Aseprite
-- Based on scripts By Paul "Spectre" Harthen, https://www.pandapus.com/

--To add the script to Aseprite:
--  File --> Scripts --> Open Scripts Folder
--  Copy this script into the folder
--  File --> Scripts --> Rescan Scripts Folder

-- To use, just select the script from File-->Scripts
-- It will export anagrams.spr and anagrams.pal to the /assets folder

local sprite = app.activeSprite

-- Validation: Sprite presence and colour mode
if sprite == nil then
  app.alert("No sprite loaded.")
  return
end

if sprite.colorMode ~= ColorMode.INDEXED then
  app.alert("Sprite must be in indexed colour mode.")
  return
end


local tileSize = 16
local colorDepth = 256

-- Validate dimensions
if (sprite.width % tileSize) ~= 0 or (sprite.height % tileSize) ~= 0 then
  app.alert("Sprite dimensions must be multiples of " .. tileSize .. ".")
  return
end

-- Validate palette size based on what selected
local paletteSize = #sprite.palettes[1]
if colorDepth == 16 and paletteSize ~= 16 then
  app.alert("Palette must contain exactly 16 colours for 4-bit export. Current palette has " .. paletteSize .. " colours.")
  return
elseif colorDepth == 256 and paletteSize ~= 256 then
  app.alert("Palette must contain exactly 256 colours for 8-bit export. Current palette has " .. paletteSize .. " colours.")
  return
end

-- Calculate maximum number of tiles
local maxTiles = (sprite.width // tileSize) * (sprite.height // tileSize)


local tileCount = 64

-- Validate tile count
if tileCount == nil or tileCount <= 0 then
  app.alert("Number to Export must be greater than 0.")
  return
elseif tileCount > maxTiles then
  app.alert("Number to Export exceeds maximum possible tiles (" .. maxTiles .. ").")
  return
end

-- Export tiles
local function writeTile(img, x, y, size, file, depth)
  for cy = 0, size - 1 do
    if depth == 256 then
      -- 8-bit: write each pixel as one byte
      for cx = 0, size - 1 do
        local px = img:getPixel(cx + x, cy + y)
        file:write(string.char(px))
      end
    else
      -- 4-bit: pack two pixels into one byte
      local cx = 0
      while cx < size do
        local px1 = img:getPixel(cx + x, cy + y) & 0x0F
        local px2 = 0
        if cx + 1 < size then
          px2 = img:getPixel(cx + x + 1, cy + y) & 0x0F
        end
        local packed = (px1 << 4) | px2
        file:write(string.char(packed))
        cx = cx + 2
      end
    end
  end
end

-- Export all tiles from current frame, up to tileLimit
local function exportCurrentFrame(file, size, depth, tileLimit)
  local img = Image(sprite.spec)
  img:drawSprite(sprite, app.activeFrame)

  local tilesWritten = 0
  for y = 0, sprite.height - 1, size do
    for x = 0, sprite.width - 1, size do
      if tilesWritten >= tileLimit then return end
      writeTile(img, x, y, size, file, depth)
      tilesWritten = tilesWritten + 1
    end
  end
end

local f = io.open("/Users/markbailey/work/Next/projects/Assembler/Anagrams/assets/anagrams.spr", "wb")
exportCurrentFrame(f, tileSize, colorDepth, tileCount)
f:close()

--- Palette Export

  -- Convert RGB to 3-bit
  local function convertTo3Bit(value)
    return math.floor(value / 36.43 + 0.5)
  end
  
  -- Pack colour into 9-bit format (rrrgggbbb)
  local function packColor(color)
    local r = convertTo3Bit(color.red)
    local g = convertTo3Bit(color.green)
    local b = convertTo3Bit(color.blue)
    local byte1 = (r << 5) | (g << 2) | (b >> 1)
    local byte2 = b & 1
    return byte1, byte2
  end

  local palette = sprite.palettes[1]
  local paletteSize = #palette
  local startIndex = 0
  local exportCount = paletteSize
  local offset = 0
  if paletteSize ~= 16 and paletteSize ~= 256 then
    app.alert("Palette must contain exactly 16 or 256 colours.")
    return
  end

  if paletteSize == 256 and offset > 0 then
    startIndex = (offset - 1) * 16
    exportCount = 16
  end

  local f = io.open("/Users/markbailey/work/Next/projects/Assembler/Anagrams/assets/anagrams.pal", "wb")
  if not f then
    app.alert("Failed to open file for writing:\n")
    return
  end

  for i = 0, exportCount - 1 do
    local index = startIndex + i
    local color = palette:getColor(index)
    local b1, b2 = packColor(color)
    f:write(string.char(b1))
    f:write(string.char(b2))
  end

  f:close()


