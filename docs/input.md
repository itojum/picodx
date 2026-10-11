# Input

## Methods

```ruby
Input.key_down?(key)  # true while the key is held
Input.key_push?(key)  # true only on the first frame the key is pressed
```

Both methods are typically called inside `Window.loop`.

## Key constants

```ruby
K_LEFT, K_RIGHT, K_UP, K_DOWN
K_SPACE, K_ESCAPE, K_RETURN
K_A, K_B, ..., K_Z
```

These are `KeyboardEvent.code` strings (e.g. `K_LEFT == "ArrowLeft"`).

## Mouse

```ruby
Input.mouse_x  # canvas pixels, even when the canvas is resized with CSS / Window.scale=
Input.mouse_y
```

Right clicks on the canvas do not open the browser's context menu.
