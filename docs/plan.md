# PicoDX 実装計画

## v1 スコープ

描画ループ＋キーボード入力。画像読み込み・音声・Sprite は v2 以降。

## API

```ruby
Window.init("canvas")      # canvas 要素 ID を渡す
Window.bgcolor = [0, 0, 0]
Window.width / Window.height

Window.loop do             # rAF ベースの描画ループ
  Window.draw(x, y, image)           # Image オブジェクトを描画
  Window.draw_box(x1,y1,x2,y2,color) # 矩形アウトライン
  Window.draw_box_fill(...)           # 塗り矩形
  Window.draw_font(x, y, str, color)  # テキスト

  Input.key_down?(K_LEFT)   # 押しっぱなし
  Input.key_push?(K_SPACE)  # 押した瞬間
end

Image.new(w, h, color)     # 単色イメージ（v1 は load なし）

# 色は [R, G, B] or [R, G, B, A]
# キー定数: K_A〜K_Z, K_LEFT/RIGHT/UP/DOWN, K_SPACE, K_ESCAPE, K_RETURN
```

## ループ実装

`Window.loop` は `while true` ループで `JS.global.__picodx_nextFrame().await` を毎フレーム呼ぶ。
`__picodx_nextFrame` は `Window.init` で `JS.eval` により1行注入する
（`requestAnimationFrame { block }` コールバック方式は `addEventListener` と競合して動作しない）。
`Input` のキー状態は `addEventListener('keydown/keyup')` で管理。

## ファイル構成

```
lib/picodx/
  image.rb          Image クラス
  input.rb          Input クラス
  key_constants.rb  K_* 定数
  window.rb         Window クラス
  z_init.rb         include PicoDX（定数を top-level に展開）
examples/bounce/
  index.html
  game.rb           ボール跳ね返りデモ
```

ビルド: `npm run build` → `lib/picodx/**/*.rb` を結合して `lib/picodx.rb` に出力。

## デモ

ボールが画面端で跳ね返るゲーム。バウンス数をテキスト表示。
