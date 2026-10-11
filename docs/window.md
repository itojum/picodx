# Window

`Window` is the entry point for the game loop and all drawing operations.

## Setup

```ruby
Window.init("canvas-id")   # connect to <canvas id="canvas-id"> (optional)
Window.bgcolor = [r, g, b] # background color, cleared each frame
Window.bgcolor             # => [r, g, b]
Window.width               # canvas width in pixels
Window.height              # canvas height in pixels
Window.width  = 640        # resize the canvas (can be called before connecting)
Window.height = 480
```

`Window.init` can be omitted. On the first draw, `Window.loop`, or `Window.width` /
`Window.height` read, PicoDX connects to `<canvas id="game">`, or to the first
`<canvas>` on the page if there is no `#game`. Settings made before connecting
(`width=`, `height=`, `bgcolor=`, `fps=`, `scale=`, …) are kept.

## Game loop

```ruby
Window.loop do
  # called every animation frame (requestAnimationFrame)
end
```

## Frame rate

```ruby
Window.fps          # => Integer (target FPS, default 60)
Window.fps = 30     # throttle to 30 FPS
Window.real_fps     # => Float (actual FPS measured from last frame)
Window.running_time # => Integer (ms elapsed since Window.loop started)
```

## Viewport offset

```ruby
Window.ox = 100   # shift all draw calls right by 100 px
Window.oy = 50    # shift all draw calls down by 50 px
Window.ox         # => Integer
Window.oy         # => Integer
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

Colors are `[r, g, b]` or `[a, r, g, b]` (DXRuby order) with `a` in 0–255.
