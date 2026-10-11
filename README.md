# picodx

A minimal 2D game library for [PicoRuby.wasm](https://github.com/picoruby/picoruby/tree/master/mrbgems/picoruby-wasm), modelled after [DXRuby](https://mirichi.github.io/dxruby-doc/index.html)'s API — pure Ruby, no C extensions, distributed via npm.

The goal is to run DXRuby games in the browser with as few changes to the game code as possible.

## Quick start

```html
<canvas id="game" width="640" height="480"></canvas>
<!-- Pin a version (e.g. picodx@1.0.0) for anything you publish -->
<script type="text/ruby" src="https://cdn.jsdelivr.net/npm/picodx@latest/lib/picodx.rb"></script>
<script type="text/ruby">
  Window.bgcolor = [20, 20, 40]

  ball = Image.new(24, 24, [255, 80, 80])
  x, y = 300, 200

  Window.loop do
    x += 4
    Window.draw(x, y, ball)
    Window.draw_font(8, 8, "Hello PicoDX!", [255, 255, 255])
  end
</script>
<script src="https://cdn.jsdelivr.net/npm/@picoruby/wasm-wasi@latest/dist/init.iife.js"></script>
```

`Window.init("canvas-id")` is optional: on the first draw or `Window.loop`, PicoDX connects to `<canvas id="game">`, or to the first `<canvas>` on the page.

Colors are `[r, g, b]` or `[a, r, g, b]` (DXRuby order), and the `C_*` constants are ARGB as in DXRuby.

## Documentation

- [Window](docs/window.md) — game loop, drawing, z order, blending
- [Image](docs/image.md) — image object, pixel access, tiles
- [Input](docs/input.md) — keyboard / mouse input and key constants

Sprite, Font, Sound and RenderTarget follow the DXRuby API; see the [DXRuby reference](https://mirichi.github.io/dxruby-doc/index.html) until their pages are added.

## Differences from DXRuby

PicoDX draws with the browser's Canvas 2D, so a few things behave differently:

- **Rotated collision:** with `collision_sync`, a rotated rectangle's hit area is approximated by its axis-aligned bounding box.
- **Semi-transparent pixels:** Canvas stores pixels premultiplied by alpha, so R / G / B read back from semi-transparent pixels (`Image#[]`, `Image#to_a`) can differ slightly from what was written.
- **Subtractive blending:** `draw_sub` / `blend: :sub` give DXRuby's colors, but the destination area becomes opaque ([details](docs/window.md#blending)).
- **`RenderTarget#update`** does nothing: drawing on a RenderTarget accumulates and is not cleared with `bgcolor` on each update.
- **Desktop-only and shader APIs** (`Window.full_screen=`, `Window.hWnd`, `Shader`, `draw_shader`, …) raise `NotImplementedError`.
- **Keyboard:** while the game canvas has focus, arrow keys / Space / Tab do not scroll the page. Set `Input.prevent_default = false` to turn this off ([details](docs/input.md#browser-default-actions)).

## Development

Requires Node.js (see `.node-version`) and Ruby (see `.ruby-version`).

```bash
npm run setup   # install dependencies
npm run build   # build lib/picodx.rb from lib/picodx/**/*.rb
npm run serve   # build and start the dev server at http://localhost:3000
```

### Examples

With the dev server running:

| Page | Description |
|------|-------------|
| [`/bounce/`](examples/bounce) | Ball bouncing demo. Arrow keys change the speed. |
| [`/compare/`](examples/compare) | Sprite position / hit area / z order. `compare.rb` also runs on DXRuby (`ruby -rdxruby compare.rb`), so the two screenshots can be compared side by side. |
| [`/bench/`](examples/bench) | Timings for `draw_ex`, `Sprite.draw` and `Sprite.check`. |

### Tests

Open `http://localhost:3000/test/` and click **Run Tests** on each page. See [examples/test/README.md](examples/test/README.md) for what each test page checks.

## Releasing

Releases are made with [release-please](https://github.com/googleapis/release-please) from [Conventional Commits](https://www.conventionalcommits.org/) (`feat:`, `fix:`, `feat!:` / `BREAKING CHANGE:` for breaking changes).

1. Run the **Release Please** workflow (Actions → Release Please → Run workflow). It opens or updates a release PR with the version bump and `CHANGELOG.md`.
2. Merge the release PR. This creates a GitHub Release.
3. The **Publish to npm** workflow runs on the release and publishes the package with provenance. It can also be run by hand with a version number.

## License

MIT
