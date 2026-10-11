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

## Browser default actions

While the game canvas has focus, arrow keys, Space, Tab, PageUp / PageDown, Home / End
and Backspace do not scroll the page or move focus (`preventDefault`). The canvas is
made focusable and focused on `Window.init`, and clicking it focuses it again. Keys
pressed while other page controls (links, buttons, text inputs) have focus, and
shortcuts with Ctrl / Meta / Alt, are left alone.

```ruby
Input.prevent_default = false  # let the browser handle those keys again
Input.prevent_default          # => true (default)
```
