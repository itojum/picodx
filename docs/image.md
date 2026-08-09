# Image

`Image` is an OffscreenCanvas-backed object. Every `Image` has an internal canvas that drawing methods write to; `Window.draw` renders it via `drawImage`.

## Constructor

```ruby
img = Image.new(width, height)              # filled with black [0,0,0]
img = Image.new(width, height, [r, g, b])
img = Image.new(width, height, [r, g, b, a])  # a: 0–255

img.width   # => Integer
img.height  # => Integer
img.color   # => the color passed to new (constructor snapshot)
img.canvas  # => OffscreenCanvas (for internal use / Window.draw)
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
img[x, y]          # => [r, g, b, a]  (0–255 each)
img[x, y] = color  # color = [r, g, b] or [r, g, b, a]
```

## Copy / slice

```ruby
img.slice(x, y, w, h)  # => new Image (sub-region)
img.dup                 # => new Image (full copy)
img.clone               # alias for dup
```
