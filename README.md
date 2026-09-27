# picodx

A minimal 2D game library for [PicoRuby.wasm](https://github.com/picoruby/picoruby/tree/master/mrbgems/picoruby-wasm) — pure Ruby, no C extensions, distributed via npm.

## Quick start

```html
<canvas id="game" width="640" height="480"></canvas>
<!-- Replace @0.1.0 with the published version -->
<script type="text/ruby" src="https://cdn.jsdelivr.net/npm/picodx@0.1.0/lib/picodx.rb"></script>
<script type="text/ruby">
  Window.init("game")
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

## Documentation

- [Window](docs/window.md) — game loop and drawing
- [Image](docs/image.md) — image object
- [Input](docs/input.md) — keyboard input and key constants

## Development

```bash
npm run setup   # install dependencies
npm run build   # build lib/picodx.rb from lib/picodx/**/*.rb
npm run serve   # build and start dev server at http://localhost:3000
```

### Manual testing

Start the dev server with `npm run serve`, then open `http://localhost:3000/examples/test/`.

| Page | What to verify |
|------|----------------|
| `image/` | Image constructor, width / height / color — click **Run Tests** |
| `key_constants/` | K_LEFT, K_RIGHT, … — click **Run Tests** |
| `window/` | draw, draw_box_fill (pixel assertions) + draw_font / draw_box (visual) — click **Run Tests** |
| `input/` | Hold / tap keys and observe key_down? and key_push? behaviour |

## Publishing

```bash
npm login
npm publish --dry-run
npm publish
```

## 非対応API（Canvas 2D では実装不能）

以下のAPIはDXRubyに存在しますが、PicoDXのCanvas 2Dバックエンドでは実装できないため、呼び出すと `NotImplementedError` が発生します。互換率の算出時はこれらを分母から除外します。

### シェーダ系（HLSL / DirectX 依存）
- `Shader` クラス全体（`Shader::Core` を含む）
- `Window.draw_shader`
- `RenderTarget#draw_shader`
- `Sprite#shader=`

### Win32 / デスクトップ専用
- `Window.hWnd` — Win32 ウィンドウハンドル
- `Window.full_screen?=` / `Window.windowed?=` — フルスクリーン切替
- `Window.get_screen_modes` / `Window.get_current_modes` — 画面解像度列挙
- `Window.load_icon` — ウィンドウアイコン設定
- `Window.open_filename` / `Window.save_filename` / `Window.folder_dialog` — ファイルダイアログ
- `Window.x=` / `Window.y=` — ウィンドウ位置（ブラウザに対応概念なし）

## License

MIT
