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

While PicoDX is running, arrow keys, Space, Tab, PageUp / PageDown, Home / End and
Backspace do not scroll the page or move focus (`preventDefault`). Key presses in
text inputs and shortcuts with Ctrl / Meta / Alt are left alone.

```ruby
Input.prevent_default = false  # let the browser handle those keys again
Input.prevent_default          # => true (default)
```
