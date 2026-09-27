# DXRuby 互換ポリシー

picodx は DXRuby 1.4.6 の API を Canvas 2D / Web API で写像することを目標とする。
ただし API を 2 つの階層に分類し、それぞれ異なる方針で扱う。

## 階層 1: 互換必須

Canvas 2D または Web API で写像可能な API。実装する、または実装予定。

## 階層 2: プラットフォーム非該当

Canvas 2D では実装不能な API。呼び出すと `NotImplementedError` が発生する。
互換率の分母からも除外する。

### シェーダ系

| API | 理由 |
|-----|------|
| `Shader` クラス全体 | HLSL シェーダは Canvas 2D 非対応 |
| `Shader::Core` クラス | 同上 |
| `Window.draw_shader` | 同上 |
| `RenderTarget#draw_shader` | 同上 |
| `Sprite#shader=` | 同上 |

> **将来方針**: WebGL バックエンドを導入すれば一部対応可能だが、現時点では非対応宣言とする。

### デスクトップ / Win32 系

| API | 理由 |
|-----|------|
| `Window.hWnd` | Windows ウィンドウハンドル（ブラウザに概念なし） |
| `Window.full_screen?` / `full_screen=` | OS フルスクリーン制御（ブラウザ非対応） |
| `Window.windowed?` / `windowed=` | 同上 |
| `Window.get_screen_modes` / `get_current_mode` | OS の画面モード取得 |
| `Window.load_icon` | Win32 アイコン設定 |
| `Window.open_filename` / `save_filename` / `folder_dialog` | Win32 ダイアログ |
| `RenderTarget#discard` / `decide` | DirectX テクスチャ管理 |
| `RenderTarget#min_filter=` / `mag_filter=` | DirectX テクスチャフィルタ |
