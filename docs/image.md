# Image

`Image` is a simple value object that holds a size and a color.
It is passed to `Window.draw` to render a filled rectangle.

```ruby
img = Image.new(width, height)             # defaults to black [0, 0, 0]
img = Image.new(width, height, [r, g, b])
img = Image.new(width, height, [r, g, b, a])  # a in 0–255

img.width   # => Integer
img.height  # => Integer
img.color   # => [r, g, b] or [r, g, b, a]
```
