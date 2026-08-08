# Window

`Window` is the entry point for the game loop and all drawing operations.

## Setup

```ruby
Window.init("canvas-id")   # connect to <canvas id="canvas-id">
Window.bgcolor = [r, g, b] # background color, cleared each frame
Window.width               # canvas width in pixels
Window.height              # canvas height in pixels
```

## Game loop

```ruby
Window.loop do
  # called every animation frame (requestAnimationFrame)
end
```

## Drawing

All drawing calls are valid inside `Window.loop`.

```ruby
Window.draw(x, y, image)

Window.draw_box(x1, y1, x2, y2, color)       # outlined rectangle
Window.draw_box_fill(x1, y1, x2, y2, color)  # filled rectangle

Window.draw_font(x, y, str, color)            # 16px monospace
Window.draw_font(x, y, str, color, size)      # custom size
```

Colors are `[r, g, b]` or `[r, g, b, a]` with `a` in 0–255.
