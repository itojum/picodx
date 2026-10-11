# Test pages

Browser test pages for PicoDX. Start the dev server from the repository root and open `http://localhost:3000/test/`:

```bash
npm run serve
```

Each page loads the freshly built `lib/picodx.rb`, so run `npm run serve` (or `npm run build`) again after changing `lib/picodx/`.

## Automated pages

| Page | What it checks |
|------|----------------|
| `window/` | Window drawing, `draw_scale` / `draw_rot` / `draw_ex` coordinates, z order, blending, off-screen skipping, re-entrant `Window.loop` |
| `window-loop-exit/` | Leaving `Window.loop` with `break` / `return` / exceptions |
| `window-auto-init/` | Connecting to `#game` without `Window.init`, keeping settings made before connecting |
| `window-auto-init-canvas/` | Connecting to the first `<canvas>` when there is no `#game` |
| `image/` | Image drawing, pixel access, `slice_tiles`, `to_a`, `compare`, `change_hls`, load cache |
| `image-load-context/` | `Image.load` / `Image.load_tiles` from top level, `initialize` and `Window.loop` |
| `sprite/` | Sprite attributes, drawing, `offset_sync`, collision (rect / circle / point, `collision_sync`, unset collision) |
| `render_target/` | RenderTarget drawing, `ox` / `oy`, `resize`, `draw_tile` |
| `font/` | Font, `draw_font` / `draw_font_ex` |
| `constants/` | Key and `C_*` color constants |
| `input-default/` | Arrow / Space / Tab do not scroll the page, `Input.prevent_default`, switching canvases |
| `input-mouse/` | Mouse coordinates on a CSS-scaled canvas, no context menu on right click |
| `sound/` | Sound API (plays a short beep at the end) |

The results are shown as PASS / FAIL below the canvas, with expected and actual values for each failure.

## Manual pages

These pages are checked by hand:

| Page | What to do |
|------|------------|
| `input/` | Hold / tap keys and move the mouse; watch `key_down?` / `key_push?` / `key_release?` and the mouse state |
| `repeat/` | Press 1–4 to switch `Input.set_repeat` presets, then hold Space and watch the repeat count |
| `sound-keydown/` | Enter plays a beep, Space stops it, Esc quits the loop |

## Writing tests

- Each page has an `index.html` (canvas, **Run Tests** button and `#test-output`) and a `test.rb`, and loads [`helpers.rb`](helpers.rb).
- `helpers.rb` provides `assert_equal`, `assert_near` (numbers with a tolerance), `assert_pixel` / `assert_pixel_near` (read a canvas pixel, optionally with a tolerance for blended colors) and `show_results`.
- Draw calls inside `Window.loop` are queued and flushed at the end of the frame (for z order), so check pixels after leaving the loop with `break`.
- Add new pages to [`index.html`](index.html) and to the tables above.
