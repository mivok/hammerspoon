local buttonWidth = 96
local buttonHeight = 96

-- Shared canvas for streamdeck button images
local sharedCanvas = hs.canvas.new{ w = buttonWidth, h = buttonHeight }

-- Colors for use with streamdeck buttons
local colors = hs.drawing.color.lists()
local defaultTextColor = colors['Crayons']['Silver']
local defaultTextFont = ".AppleSystemUIFont"

-- Given a series of elements, return a button image
function streamdeck_imageFromElements(elements)
  sharedCanvas:replaceElements(elements)
  return sharedCanvas:imageFromCanvas()
end

-- Return a canvas element for a button label
-- Used as part of the other button image functions
function streamdeck_imageLabel(label, options)
  local options = options or {}
  local label = label or ""
  textColor = options['textColor'] or defaultTextColor
  font = options['labelFont'] or defaultTextFont
  labelFontSize = options['labelFontSize'] or 14

  return {
    type = "text",
    frame = { x = 0, y = 0, w = buttonWidth, h = buttonHeight },
    text = hs.styledtext.new(label, {
      font = { name = font, size = labelFontSize },
      paragraphStyle = {
        alignment = "center",
      },
      color = textColor,
    }),
  }
end

function streamdeck_blankImage()
  return streamdeck_imageFromElements({
    type = 'rectangle',
    action = 'skip',
  })
end

-- Create a frame for an image, taking into account scaling and offset options
function streamdeck_scaledFrame(options)
  local options = options or {}
  scale = options['scale'] or 1.0
  xoffset = options['xoffset'] or 0
  -- Set a default y offset to have the image clear any label that's displayed
  yoffset = options['yoffset'] or 8

  return {
    x = xoffset + (buttonWidth - (buttonWidth * scale)) / 2,
    y = yoffset + (buttonHeight - (buttonHeight * scale)) / 2,
    w = buttonWidth * scale,
    h = buttonHeight * scale,
  }
end

-- Create an image from the given text
-- options is a table with textColor, backgroundColor, font, fontSize keys.
-- All optional.
function streamdeck_imageFromText(text, label, options)
  local options = options or {}
  textColor = options['textColor'] or defaultTextColor
  font = options['font'] or ".AppleSystemUIFont"
  fontSize = options['fontSize'] or 70
  return streamdeck_imageFromElements({
    {
      frame = streamdeck_scaledFrame(options),
      text = hs.styledtext.new(text, {
        font = { name = font, size = fontSize },
        paragraphStyle = { alignment = "center" },
        color = textColor,
      }),
      type = "text",
    },
    streamdeck_imageLabel(label, options),
  })
end

function streamdeck_imageWithLabel(path, label, options)
  return streamdeck_imageFromElements({
    {
      type = "image",
      frame = streamdeck_scaledFrame(options),
      image = hs.image.imageFromPath(hs.configdir .. "/images/" .. path),
      -- imageScaling = "scaleToFit",
    },
    streamdeck_imageLabel(label, options)
  })
end
