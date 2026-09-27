# Image

`Image` is an OffscreenCanvas-backed object. Every `Image` has an internal canvas that drawing methods write to; `Window.draw` renders it via `drawImage`.

## Constructor

```ruby
img = Image.new(width, height)              # filled with black [0,0,0]
img = Image.new(width, height, [r, g, b])
img = Image.new(width, height, [a, r, g, b])  # a: 0–255 (DXRuby order)

img.width   # => Integer
img.height  # => Integer
```

## Class methods

```ruby
Image.load(filename)                         # => Image  (awaits fetch)
Image.load_tiles(filename, x_count, y_count) # => [[Image, ...], ...]
```

`load` is asynchronous — call it before `Window.loop`.

## Drawing methods

```ruby
img.fill(color)
img.clear                                       # fully transparent
img.line(x1, y1, x2, y2, color)
img.box(x1, y1, x2, y2, color)                 # outline
img.box_fill(x1, y1, x2, y2, color)
img.circle(x, y, r, color)                     # outline
img.circle_fill(x, y, r, color)
img.triangle(x1, y1, x2, y2, x3, y3, color)   # outline
img.triangle_fill(x1, y1, x2, y2, x3, y3, color)
img.draw(x, y, other_image)                    # blit another Image onto this one
```

## Pixel access

```ruby
img[x, y]          # => [a, r, g, b]  (0–255 each, DXRuby order)
img[x, y] = color  # color = [r, g, b] or [a, r, g, b]
```

## Copy / slice

```ruby
img.slice(x, y, w, h)  # => new Image (sub-region)
img.dup                 # => new Image (full copy)
img.clone               # alias for dup
```

## Color adjustment

`Image#change_hls` is the supported API name; replace `change_hue(degree)` with `change_hls(degree, 0, 0)`.

```ruby
img.change_hls(hue, luminance, saturation)  # => new Image
img.change_hls(hue = 0, luminance = 0, saturation = 0)  # all adjustments are optional
```

- `hue` is added in degrees around the color wheel and normalized modulo 360.
- `luminance` and `saturation` are additive percentage-point adjustments.
  - `0` keeps the original value
  - positive values increase lightness / saturation
  - negative values decrease lightness / saturation
- `luminance` and `saturation` are clamped to the valid range after adjustment.
