# Changelog

## [2.1.0](https://github.com/itojum/picodx/compare/picodx-v2.0.0...picodx-v2.1.0) (2026-10-12)


### Features

* **cli:** require をたどって 1 ファイルにまとめる picodx bundle を追加 ([5845f9b](https://github.com/itojum/picodx/commit/5845f9b4ff3dca898a73f9a83dfc41994f1c52e0))
* **cli:** require をたどって 1 ファイルにまとめる picodx bundle を追加 ([adedb7c](https://github.com/itojum/picodx/commit/adedb7c5f9a69be90d580f9fbfccf563d52b5389))

## [2.0.0](https://github.com/itojum/picodx/compare/picodx-v1.0.0...picodx-v2.0.0) (2026-10-12)


### ⚠ BREAKING CHANGES

* **constants:** C_ 定数が 3 要素の [R, G, B] から 4 要素の [A, R, G, B] に変わった。描画結果は変わらないが、要素を直接 参照しているコード（C_RED[0] など）は添字がずれる。
* **image:** Image.load_tiles と Image#slice_tiles の戻り値が 2 次元配列 [[row0...], [row1...]] から 1 次元配列 [tile0, tile1, ...] に 変わった。tiles[row][col] は tiles[row * x_count + col] に書き換える。
* **drawable:** draw_scale / draw_rot / draw_ex の (x, y) が 変形の中心ではなく、変形前の画像の左上を表すようになった。 draw_ex の cx / cy を省略したときの中心は画像中央になる。

### Features

* **constants:** C_ 定数を DXRuby と同じ ARGB 4 要素にする ([66be2ea](https://github.com/itojum/picodx/commit/66be2eae18eb696e5bd6c87cd23de3ea0ea013e2)), closes [#92](https://github.com/itojum/picodx/issues/92)
* **drawable:** draw_scale / draw_rot / draw_ex の座標系を DXRuby に合わせる ([ccc5d91](https://github.com/itojum/picodx/commit/ccc5d91cb98c57089ed695b0aec84aefb5bb9a18)), closes [#87](https://github.com/itojum/picodx/issues/87)
* **drawable:** 描画メソッド末尾の位置引数で z を受け付ける ([eaec625](https://github.com/itojum/picodx/commit/eaec625e5e13b71978c6307d2a4afb117b1e9625))
* **drawable:** 描画メソッド末尾の位置引数で z を受け付ける ([055b4ff](https://github.com/itojum/picodx/commit/055b4ffacd4b26ec75d6b7d1c51745aebd78d231)), closes [#91](https://github.com/itojum/picodx/issues/91)
* **image:** Image.load_tiles / Image#slice_tiles を 1 次元配列で返す ([b1f2095](https://github.com/itojum/picodx/commit/b1f20959697f7d48ea866214984a64ab9a9b3790)), closes [#90](https://github.com/itojum/picodx/issues/90)
* **input:** ゲームのキー入力でページがスクロールしないようにする ([b94740a](https://github.com/itojum/picodx/commit/b94740a044f9ef7201df44db5693dc132bce6c7b))
* **input:** ゲームのキー入力でページがスクロールしないようにする ([e57eb21](https://github.com/itojum/picodx/commit/e57eb21784747668bae9a353092598be238684a2)), closes [#95](https://github.com/itojum/picodx/issues/95)
* **input:** 右クリックメニューを抑止し、マウス座標を canvas の内部解像度に換算する ([02984e9](https://github.com/itojum/picodx/commit/02984e94a031c3acf79e76b62d058cef1c259420))
* **input:** 右クリックメニューを抑止し、マウス座標を canvas の内部解像度に換算する ([0915fcb](https://github.com/itojum/picodx/commit/0915fcb3fd7768bc889339ca9eb23ad8b9d22286)), closes [#96](https://github.com/itojum/picodx/issues/96)
* **sprite:** collision 未設定なら画像全体を判定範囲にする ([9d18694](https://github.com/itojum/picodx/commit/9d1869410b895e4aaa8f2a344dc11669a6767d82))
* **sprite:** collision 未設定なら画像全体を判定範囲にする ([6e4fc93](https://github.com/itojum/picodx/commit/6e4fc93b8abb9741988d3cabb0ee0e6ea336825a)), closes [#89](https://github.com/itojum/picodx/issues/89)
* **sprite:** Sprite の描画位置を offset_sync に合わせる ([1245110](https://github.com/itojum/picodx/commit/12451100d366a3846aaab146df0beee39bbbafe2))
* **sprite:** Sprite の描画位置を offset_sync に合わせる ([e6a415a](https://github.com/itojum/picodx/commit/e6a415a890f9caca74d7774b57f235ba9e92ff50)), closes [#88](https://github.com/itojum/picodx/issues/88)
* **window:** Window.init を省略できるようにする ([1009752](https://github.com/itojum/picodx/commit/100975272e996bd507b22c75076128a66f0da988))
* **window:** Window.init を省略できるようにする ([51a75ef](https://github.com/itojum/picodx/commit/51a75ef32d5064498c43cfd87b137366d0499207)), closes [#93](https://github.com/itojum/picodx/issues/93)


### Bug Fixes

* **drawable:** blend: :sub / draw_sub を正しい減算合成にする ([864251f](https://github.com/itojum/picodx/commit/864251fd0b85e96f2b85361929b3198c3b6002f5))
* **drawable:** blend: :sub / draw_sub を正しい減算合成にする ([a538ac3](https://github.com/itojum/picodx/commit/a538ac3e05eefc5fed52b431da38ca52ee721a6f)), closes [#102](https://github.com/itojum/picodx/issues/102)
* **drawable:** 減算の反転範囲を描画先のピクセル境界に合わせ、ドキュメントを追加 ([0b7ac4d](https://github.com/itojum/picodx/commit/0b7ac4d9789a22ec104947cb3b7d40338f80f1b6))
* **image:** change_hls の色相を HLS 色空間で回す ([f0d6aa2](https://github.com/itojum/picodx/commit/f0d6aa20307ae316afe94fec3f137258c30b5236))
* **image:** change_hls の色相を HLS 色空間で回す ([96f1db4](https://github.com/itojum/picodx/commit/96f1db422d9c62c499ca5bbe71e358f46102d805)), closes [#122](https://github.com/itojum/picodx/issues/122)
* **input:** canvas を切り替えた後は古い canvas のマウス入力を無視する ([c839ed5](https://github.com/itojum/picodx/commit/c839ed549d9d5e011dbece985a379bac41a4f17f))
* **input:** preserve page control keyboard behavior ([f54a2ed](https://github.com/itojum/picodx/commit/f54a2ed2a454a60f0197194c7e1ea54efa6a6a94))
* **input:** 初期化時に canvas にフォーカスし、テストを canvas フォーカス前提に更新 ([f28260f](https://github.com/itojum/picodx/commit/f28260f0b89f5e28106d6179491ece25b61373c8)), closes [#95](https://github.com/itojum/picodx/issues/95)
* **render_target:** ox / oy を描画に反映し、resize 後に背景色で塗る ([5044ca2](https://github.com/itojum/picodx/commit/5044ca27dda06ead9ffacfe7323eaa35c0556a5e))
* **render_target:** ox / oy を描画に反映し、resize 後に背景色で塗る ([3d1081b](https://github.com/itojum/picodx/commit/3d1081b62634eb698b86583418d45288a2ba6531)), closes [#101](https://github.com/itojum/picodx/issues/101)
* **window:** canvas のサイズ変更後に平行移動と補間設定を掛け直す ([5a39e1c](https://github.com/itojum/picodx/commit/5a39e1ce628d31a88d3be8913767a8dd54f5832e))
* **window:** Window.loop を抜けたときにループの状態を戻す ([08ea489](https://github.com/itojum/picodx/commit/08ea489136bb9e98914efd7ea39279b21bbf3ac6))
* **window:** Window.loop を抜けたときにループの状態を戻す ([e9a0260](https://github.com/itojum/picodx/commit/e9a02607284125cd20ebd8ab1aeee6370de61533)), closes [#99](https://github.com/itojum/picodx/issues/99)
* **window:** 画面外判定に ctx へ実際に掛かっている平行移動量を使う ([d94cf1a](https://github.com/itojum/picodx/commit/d94cf1ade2ae80d55a8567b0281961dc1b3a2cdb))


### Performance Improvements

* **drawable:** draw_ex の高速化と画面外の描画スキップ ([d6b4264](https://github.com/itojum/picodx/commit/d6b42642ed2e124ff6199764fefe61d1a532738a))
* **drawable:** draw_ex の高速化と画面外の描画スキップ ([d9a5e35](https://github.com/itojum/picodx/commit/d9a5e35a17acec2d72c2d8718de43d612614242d)), closes [#97](https://github.com/itojum/picodx/issues/97)
* **sprite:** 衝突判定を軽量化する ([ffac734](https://github.com/itojum/picodx/commit/ffac7347702de74ce5fb3b5249cee125644b58e7))
* **sprite:** 衝突判定を軽量化する ([198b5ea](https://github.com/itojum/picodx/commit/198b5eaebd36d52532b1496827898fdfbb364cc6)), closes [#100](https://github.com/itojum/picodx/issues/100)

## [1.0.0](https://github.com/itojum/picodx/compare/picodx-v0.2.0...picodx-v1.0.0) (2026-09-27)


### ⚠ BREAKING CHANGES

* **color:** 4-element color arrays are now interpreted as [A,R,G,B] instead of [R,G,B,A] to match DXRuby 1.4.6 behaviour. 3-element [R,G,B] arrays are unaffected.

### Features

* Canvas 2D 非対応APIに NotImplementedError スタブを追加 ([#43](https://github.com/itojum/picodx/issues/43)) ([5a55367](https://github.com/itojum/picodx/commit/5a55367179db7662171210d822f30addf91423a7))
* Canvas 2D 非対応APIに NotImplementedError スタブを追加 ([#43](https://github.com/itojum/picodx/issues/43)) ([7703299](https://github.com/itojum/picodx/commit/77032999b87609c46b130763e157fe36147a844a))
* draw_add / draw_sub / draw_morph を追加 ([#44](https://github.com/itojum/picodx/issues/44)) ([db1e74b](https://github.com/itojum/picodx/commit/db1e74b555158ee9f85a84fc36f9131888c6953f))
* draw_add / draw_sub / draw_morph を追加 ([#44](https://github.com/itojum/picodx/issues/44)) ([94047b8](https://github.com/itojum/picodx/commit/94047b82cd5ce85230a037f974895eb7dfe39bec))
* **image:** cache Image.load results by filename ([33a93ad](https://github.com/itojum/picodx/commit/33a93ada2d11a9c329799e2a64f420e23016bb19))
* **image:** cache Image.load results by filename ([f6d382a](https://github.com/itojum/picodx/commit/f6d382ac1b797174ff4829b8a3b9ad656c1706e0)), closes [#55](https://github.com/itojum/picodx/issues/55)
* **sprite:** collision_sync を実装（scale/angle を当たり判定に反映） ([a142612](https://github.com/itojum/picodx/commit/a142612eaec76828f99ef821841ce0f8d28f713f))
* **sprite:** collision_sync を実装（scale/angle を当たり判定に反映） ([ed0c8fb](https://github.com/itojum/picodx/commit/ed0c8fb4982b36e0fd58e41b1db322b9c88d2636))
* **window:** add Window.width= and Window.height= setters ([360954f](https://github.com/itojum/picodx/commit/360954fd155f181857fcdc712b19adab0ee14be7))
* **window:** add Window.width= and Window.height= setters ([ab51759](https://github.com/itojum/picodx/commit/ab51759c009004839763d8bf5c699f6fa4c34ba3))
* **window:** implement z-ordered draw queue ([c721c4d](https://github.com/itojum/picodx/commit/c721c4dc2bba4fffe19b53fdd29dbb633d05715a))
* **window:** implement z-ordered draw queue ([a196173](https://github.com/itojum/picodx/commit/a1961735d2c65baf0836f9edd5389459227edd5a)), closes [#48](https://github.com/itojum/picodx/issues/48)
* ゲームパッド対応（Gamepad API / pad_* メソッド） ([#45](https://github.com/itojum/picodx/issues/45)) ([9b82221](https://github.com/itojum/picodx/commit/9b822211c629d197d25831d2278094fa1acaeaed))
* ゲームパッド対応（Gamepad API / pad_* メソッド） ([#45](https://github.com/itojum/picodx/issues/45)) ([718c636](https://github.com/itojum/picodx/commit/718c636ae58f7e1221bf693acc872e04e928f301))


### Bug Fixes

* **color:** change 4-element color order to [A,R,G,B] for DXRuby compat ([9d01d1d](https://github.com/itojum/picodx/commit/9d01d1d68dc12783afb4a6cea241986f61bcab29))
* **color:** change 4-element color order to [A,R,G,B] for DXRuby compat ([03b6428](https://github.com/itojum/picodx/commit/03b64288afa15110b0d3099defbc0980b6a4b6cd)), closes [#47](https://github.com/itojum/picodx/issues/47)
* **draw_morph:** OffscreenCanvasキャッシュとアルファブレンド修正 ([28a4b55](https://github.com/itojum/picodx/commit/28a4b55f0aed12001e6fa9103e12ec30ddae3517))
* **drawable:** default center_x/center_y to image center in draw_scale/draw_rot ([cdb3a8d](https://github.com/itojum/picodx/commit/cdb3a8dac85b07861fab12562e147efdc953b195))
* **drawable:** default center_x/center_y to image center in draw_scale/draw_rot ([d9d8a40](https://github.com/itojum/picodx/commit/d9d8a40947f3b88d2219f9014a8826b7bada8671)), closes [#49](https://github.com/itojum/picodx/issues/49)
* **font:** preserve explicit weight values ([1435241](https://github.com/itojum/picodx/commit/14352412c8bf47cfdb9b39ec386dc6888872b1ff))
* **image:** clearRect before fillRect in Image#[]= to preserve alpha ([6272f2a](https://github.com/itojum/picodx/commit/6272f2a3357f4240424e6de83ff54a5aa7fc47c0))
* **input:** keydown / mousedown で AudioContext を resume する ([#54](https://github.com/itojum/picodx/issues/54)) ([4124336](https://github.com/itojum/picodx/commit/4124336fb2a389a1bbe405d10fff22e234cb220d))
* **input:** keydown/mousedown で AudioContext を resume して Sound が鳴らない問題を修正 ([d8455d9](https://github.com/itojum/picodx/commit/d8455d9d8db8a8dcaac0889ba78fa265e146049f))
* **input:** ゲームパッド切断時の状態クリアと論理インデックス統一 ([d870277](https://github.com/itojum/picodx/commit/d870277ec7432c70d8ce59ce7a658ccc57cb6e26))
* **merge:** resolve remaining conflicts and follow-up issues ([4bef733](https://github.com/itojum/picodx/commit/4bef733be72fc81cddcee6ce4b19e729a0c8e599))
* **sprite:** return defaults from getters so subclasses work without super ([7c5c6e5](https://github.com/itojum/picodx/commit/7c5c6e5a4f9e35a839f14a5ab7e2948f370b6efd))
* **sprite:** return defaults from getters so subclasses work without super ([5aea8e4](https://github.com/itojum/picodx/commit/5aea8e4727b449e30c085772d6a08fd388b57541)), closes [#51](https://github.com/itojum/picodx/issues/51)
* **window:** keep draw queue nil outside loop; flush in ensure ([6b38e9d](https://github.com/itojum/picodx/commit/6b38e9d68e7279824d77feda432b86c9f4f68c7a))
* **window:** return break/return value from nested Window.loop ([64c946d](https://github.com/itojum/picodx/commit/64c946de338a9ea5befb39c3feb2f27754461933))
* **window:** return break/return value from nested Window.loop ([ca8d95a](https://github.com/itojum/picodx/commit/ca8d95a57395a533c6310e6e10760b5297eb2bb0)), closes [#52](https://github.com/itojum/picodx/issues/52)
* **window:** save/restore draw queue for nested loops; run z-order tests inside loop ([2f1e972](https://github.com/itojum/picodx/commit/2f1e972033c1b7f3a5f8aa74d5668c575347a615))
* **window:** scope presets to the active canvas ([f376802](https://github.com/itojum/picodx/commit/f376802becb2da561af187c7ea75728b4f8fc80c))
* **window:** separate pre-init preset from post-init canvas dimensions ([1ca4665](https://github.com/itojum/picodx/commit/1ca4665af919fbd33789045e9011e69e472c5c72))
* **window:** track dimension presets independently ([1a9db0d](https://github.com/itojum/picodx/commit/1a9db0db5ba9fab7ef9376f0f6b4f30c0dc7f443))
* 無効なRubyメソッド名・構文を修正 ([81f7ac2](https://github.com/itojum/picodx/commit/81f7ac2ed000e8cb4db8be6f91b242554b2dedbb))

## [0.2.0](https://github.com/itojum/picodx/compare/picodx-v0.1.2...picodx-v0.2.0) (2026-09-27)


### Features

* add built-in color constants (C_BLACK, C_WHITE, C_RED, ...) ([530618f](https://github.com/itojum/picodx/commit/530618fac5e282b9f4c31dc96989a7332b5ae6cd))
* add built-in color constants (C_BLACK, C_WHITE, C_RED, ...) ([b94a584](https://github.com/itojum/picodx/commit/b94a5848be469eeb642f7df665dac79f0a77a0b0)), closes [#15](https://github.com/itojum/picodx/issues/15)
* **build:** add prepublish concat step for PicoRuby WASM compatibility ([adabdf3](https://github.com/itojum/picodx/commit/adabdf37ff411a90533e8a1f03feae7fb095beb9))
* **drawable:** extract Drawable mixin, refactor Window to use it ([44f4b51](https://github.com/itojum/picodx/commit/44f4b51a695b4826737ef6fe998849689ca9884c))
* **font:** implement Font class and Image#draw_font ([8f53eeb](https://github.com/itojum/picodx/commit/8f53eeb41b06232f08d62c9d986aa8b3397979af))
* **font:** implement Font#get_height ([89645bb](https://github.com/itojum/picodx/commit/89645bb8bbd960a2d49727127971c9f85a58178d))
* **font:** implement Font#get_height ([d69dc09](https://github.com/itojum/picodx/commit/d69dc092548723bc9e97c8adffd507c7d3778d0d))
* **image:** Canvas-backed Image with full v0.3 API ([d7c92df](https://github.com/itojum/picodx/commit/d7c92df8913cc1a61cdb81be45490b935d8c867a))
* **image:** implement Canvas-backed Image with drawing, pixel, and load APIs (v0.3) ([d1c6be1](https://github.com/itojum/picodx/commit/d1c6be109ab6ee78cdffcd13b03084a649e22f47))
* **image:** implement Image#draw_font_ex and Window.draw_font_ex ([a6ca7e6](https://github.com/itojum/picodx/commit/a6ca7e6ce9f3e8d012d09d3ddc506dd917aea40c))
* **image:** implement Image#draw_font_ex and Window.draw_font_ex ([6ec5283](https://github.com/itojum/picodx/commit/6ec52836de6d6b65aab3279a96922ae4d4c6d797)), closes [#13](https://github.com/itojum/picodx/issues/13)
* **image:** implement Image#to_a, Image#compare, Image#change_hue ([9bea6b9](https://github.com/itojum/picodx/commit/9bea6b948bb2ae05198b1c3b40635a068abd5e54))
* **image:** implement Image#to_a, Image#compare, Image#change_hue ([3a6ce11](https://github.com/itojum/picodx/commit/3a6ce11fa1041fdf096dfe334b94503014d0dadb))
* implement PicoDX v1 drawing loop and keyboard input ([77a5f48](https://github.com/itojum/picodx/commit/77a5f4896ec985ea636258515f5605023bbed736))
* implement Sprite, Font, Sound, RenderTarget, and draw_tile (v0.4) ([8f41b4e](https://github.com/itojum/picodx/commit/8f41b4e8899d8501f6430943a2a3e92f817ed1e1))
* **input:** add digit, numpad, modifier, and navigation key constants ([c0b6aed](https://github.com/itojum/picodx/commit/c0b6aed007412a640d9c9842d08327078f9eb72b))
* **input:** add digit, numpad, modifier, and navigation key constants ([71d1a09](https://github.com/itojum/picodx/commit/71d1a098db0c6c82a12db80e6eed55e842399360)), closes [#10](https://github.com/itojum/picodx/issues/10)
* **input:** add x/y axis, key_release?, and mouse support ([246d484](https://github.com/itojum/picodx/commit/246d484374fcfb10c57538d91dada451e71a3658))
* **input:** add x/y axis, key_release?, and mouse support ([85c39e9](https://github.com/itojum/picodx/commit/85c39e9b518aaa107988776882690445c44d7bec))
* **input:** implement Input.set_repeat and Input.set_key_repeat ([355cd50](https://github.com/itojum/picodx/commit/355cd502916e7c4dbc76b3e7c28c3eb04f63934c))
* **input:** implement Input.set_repeat and Input.set_key_repeat ([2385b97](https://github.com/itojum/picodx/commit/2385b97d71a5877447a178de2bf7d612dee1266a)), closes [#12](https://github.com/itojum/picodx/issues/12)
* **render-target:** implement RenderTarget backed by OffscreenCanvas ([0f51f21](https://github.com/itojum/picodx/commit/0f51f217843ee8f40117746d971ce5c48d6351c7))
* **server:** serve from examples/ via WEBrick with mounted routes ([1893e8a](https://github.com/itojum/picodx/commit/1893e8aa65a46a2057fabb9dcee192b9154ddea4))
* **sound:** add Sound#volume reader ([61fbdba](https://github.com/itojum/picodx/commit/61fbdba94bdad3263c4138082f8b2d33b9e30cac))
* **sound:** add Sound#volume reader ([77edf12](https://github.com/itojum/picodx/commit/77edf128878a8f5e803906944c236b3d862ee332))
* **sound:** implement Sound class via Web Audio API ([289fee1](https://github.com/itojum/picodx/commit/289fee154e185d289d3ca39748ddba6fa74884a8))
* **sprite:** add circle and point collision detection ([0ccc9e7](https://github.com/itojum/picodx/commit/0ccc9e73c3c807158068c72e78f1a31a8535d202))
* **sprite:** add circle and point collision detection ([f83339c](https://github.com/itojum/picodx/commit/f83339ce36f480f98c37b6b8a1ecf50b86b8ad81))
* **sprite:** implement offset_sync to align collision with center_x/center_y ([7294312](https://github.com/itojum/picodx/commit/729431200819ae144dcb6c2bc73aad8e2447f1d2))
* **sprite:** implement offset_sync to align collision with center_x/center_y ([dd9fa15](https://github.com/itojum/picodx/commit/dd9fa15f1fb482fbef3602c7fda303b3879d6d4c))
* **sprite:** implement Sprite class with collision detection ([1348587](https://github.com/itojum/picodx/commit/1348587199562d5b414384fe0c9c6bf53be869f8))
* **window:** add fps, real_fps, running_time, ox/oy, and bgcolor getter ([0607786](https://github.com/itojum/picodx/commit/0607786339e6d9b03ed208f4ce8c8dfc404abb66))
* **window:** add fps, real_fps, running_time, ox/oy, and bgcolor getter ([1beb771](https://github.com/itojum/picodx/commit/1beb771a192989dfe61d9aa6cc43cdcf7631465c))
* **window:** implement additional draw methods ([7ab1338](https://github.com/itojum/picodx/commit/7ab133865cd5483b47f2d5514b652690fde94e08))
* **window:** implement additional draw methods ([9fc0a02](https://github.com/itojum/picodx/commit/9fc0a0246708c5851b2015854149afb0b660d5ec)), closes [#3](https://github.com/itojum/picodx/issues/3)
* **window:** implement Window.caption= ([30d67d8](https://github.com/itojum/picodx/commit/30d67d83bf5a1f56b045ae8a1f20718e3dd1ca53))
* **window:** implement Window.caption= ([60f43fe](https://github.com/itojum/picodx/commit/60f43fed3589124b39c743804f4175285a3d506f)), closes [#16](https://github.com/itojum/picodx/issues/16)
* **window:** support re-entrant Window.loop for DXRuby compatibility ([4c3d1af](https://github.com/itojum/picodx/commit/4c3d1af69303148bb8b9634fbb21718ae34c1dae))
* **window:** support re-entrant Window.loop for DXRuby compatibility ([60e442a](https://github.com/itojum/picodx/commit/60e442acc0e2b4a9fbc6920e7dc0004f30aa2133))


### Bug Fixes

* **ci:** update spec paths to match new directory structure ([70182b9](https://github.com/itojum/picodx/commit/70182b9c13745070310f8a91444b8750b70e9238))
* **drawable:** add cx/cy parameters to draw_scale ([a79deb4](https://github.com/itojum/picodx/commit/a79deb4be9dfc4c2053f46c3fa89514a23bee11b))
* **drawable:** add cx/cy parameters to draw_scale ([9265240](https://github.com/itojum/picodx/commit/9265240a917b8b970a0ee7262a72ad57e882379e))
* **image:** expose [@ctx](https://github.com/ctx) correctly via explicit _ctx method ([b01ae76](https://github.com/itojum/picodx/commit/b01ae76a6e80dfc462fce3b2e81711ad06dc6208))
* **test/input:** detect all A-Z keys, not just A and Z ([5af9dff](https://github.com/itojum/picodx/commit/5af9dff0f490c5566f8d5448bdd15c1e6d0bc027))
* **test:** use explicit index.html in links and init Window at load time ([48ac6a2](https://github.com/itojum/picodx/commit/48ac6a24b01a90c82db4ae9d362742254d5787e6))
* typo ([43e9d0f](https://github.com/itojum/picodx/commit/43e9d0f7f348d0e5d5416f8dd14c2b8a33035171))
* use npm pkg set to avoid version-unchanged error ([3b3a6de](https://github.com/itojum/picodx/commit/3b3a6deca1a7a4c9089d364debaab565fbd8f80f))
* **window:** restore canvas state after draw_font ([fc6c53e](https://github.com/itojum/picodx/commit/fc6c53ea469e45e05b16489933abcdd1921cc977))
