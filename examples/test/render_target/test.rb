Window.init("game")

JS.document.getElementById('run').addEventListener('click') do |_e|
  results = []

  # --- RenderTarget.new ---
  rt = RenderTarget.new(100, 60, [20, 40, 80])
  results << assert_equal(100,          rt.width,    "RenderTarget.new width")
  results << assert_equal(60,           rt.height,   "RenderTarget.new height")
  results << assert_equal([20, 40, 80], rt.bgcolor,  "RenderTarget.new bgcolor")
  results << assert_equal(0,            rt.ox,       "RenderTarget.new ox default 0")
  results << assert_equal(0,            rt.oy,       "RenderTarget.new oy default 0")
  results << assert_equal(false,        rt.disposed?, "RenderTarget.new disposed? is false")

  # --- attr setters ---
  rt.bgcolor = [10, 20, 30]; rt.ox = 5; rt.oy = 3
  results << assert_equal([10, 20, 30], rt.bgcolor, "RenderTarget#bgcolor= setter")
  results << assert_equal(5, rt.ox, "RenderTarget#ox= setter")
  results << assert_equal(3, rt.oy, "RenderTarget#oy= setter")

  # --- RenderTarget#draw_box_fill + to_image → Window.draw ---
  rt2 = RenderTarget.new(80, 50, [0, 0, 0])
  rt2.draw_box_fill(10, 10, 70, 40, [0, 200, 0])
  rt2.draw_box_fill(0,  0,  10,  10, [255, 0, 0])
  img = rt2.to_image
  results << assert_equal(80, img.width,  "RenderTarget#to_image width")
  results << assert_equal(50, img.height, "RenderTarget#to_image height")
  Window.draw(0, 0, img)
  results << assert_pixel("game", 40, 25, 0,   200, 0, "RenderTarget: green fill visible via Window.draw")
  results << assert_pixel("game",  5,  5, 255,   0, 0, "RenderTarget: red corner pixel preserved")

  # --- update is no-op; draws accumulate ---
  rt3 = RenderTarget.new(60, 30, [0, 0, 0])
  rt3.draw_pixel(10, 10, [255, 0, 255])
  rt3.update
  rt3.draw_pixel(20, 10, [0, 255, 255])
  img3 = rt3.to_image
  Window.draw(100, 0, img3)
  results << assert_pixel("game", 110, 10, 255, 0,   255, "RenderTarget: first pixel persists after update")
  results << assert_pixel("game", 120, 10, 0,   255, 255, "RenderTarget: second pixel also present")

  # --- RenderTarget#dispose ---
  rt4 = RenderTarget.new(10, 10, [0, 0, 0])
  rt4.dispose
  results << assert_equal(true, rt4.disposed?, "RenderTarget#dispose sets disposed? true")

  # --- RenderTarget#resize ---
  rt5 = RenderTarget.new(40, 40, [0, 0, 0])
  rt5.resize(80, 60)
  results << assert_equal(80, rt5.width,  "RenderTarget#resize updates width")
  results << assert_equal(60, rt5.height, "RenderTarget#resize updates height")

  # --- Sprite with RenderTarget as target ---
  rt6 = RenderTarget.new(50, 50, [0, 0, 0])
  chip_img = Image.new(20, 20, [180, 90, 0])
  sp = Sprite.new(25, 25, chip_img)
  sp.target = rt6
  sp.draw
  rt6_img = rt6.to_image
  Window.draw(170, 0, rt6_img)
  # center=(10,10) → top-left at (15,15) in rt6; center at (25,25)
  # On Window: (170+25, 0+25) = (195, 25)
  results << assert_pixel("game", 195, 25, 180, 90, 0, "Sprite with RenderTarget target draws to target")

  # -------------------------------------------------------
  # Window.draw_tile
  # -------------------------------------------------------
  chips = [
    Image.new(16, 16, [255, 0,   0  ]),   # 0 red
    Image.new(16, 16, [0,   255, 0  ]),   # 1 green
    Image.new(16, 16, [0,   0,   255]),   # 2 blue
    Image.new(16, 16, [255, 255, 0  ])    # 3 yellow
  ]
  map = [
    [0, 1, 2, 3],
    [3, 2, 1, 0]
  ]
  Window.draw_tile(0, 100, map, chips, 0, 0, 4, 2)
  results << assert_pixel("game",  8, 108, 255, 0,   0,   "draw_tile row0 col0: red")
  results << assert_pixel("game", 24, 108, 0,   255, 0,   "draw_tile row0 col1: green")
  results << assert_pixel("game", 40, 108, 0,   0,   255, "draw_tile row0 col2: blue")
  results << assert_pixel("game", 56, 108, 255, 255, 0,   "draw_tile row0 col3: yellow")
  results << assert_pixel("game",  8, 124, 255, 255, 0,   "draw_tile row1 col0: yellow")
  results << assert_pixel("game", 24, 124, 0,   0,   255, "draw_tile row1 col1: blue")

  # Scrolled 1 tile horizontally (16px): first visible column shifts to index 1 (green)
  Window.draw_tile(0, 150, map, chips, 16, 0, 3, 2)
  results << assert_pixel("game",  8, 158, 0, 255, 0,   "draw_tile scrolled 1 tile: first visible is green")
  results << assert_pixel("game", 24, 158, 0, 0,   255, "draw_tile scrolled: second is blue")

  # Scrolled half a tile (8px offset): sub-tile pixel offset
  Window.draw_tile(0, 185, map, chips, 8, 0, 4, 1)
  # offset_x=8, tw=16 → tile_ox=0, px_ox=8
  # col0: map[0][0]=0 (red), dx=0*16-8=-8 → tile drawn at x=-8; pixel at x=0 is within tile (0-(-8)=8px in)
  results << assert_pixel("game", 0, 193, 255, 0, 0, "draw_tile sub-tile offset: red tile still visible at x=0")

  # 2D chips array (Image.load_tiles format: [[row0], [row1], ...])
  Window.draw_tile(200, 100, map, [chips], 0, 0, 4, 2)
  results << assert_pixel("game", 208, 108, 255, 0, 0, "draw_tile with 2D chips (flattened correctly)")

  # RenderTarget.draw_tile via Drawable
  rt_tile = RenderTarget.new(80, 40, [0, 0, 0])
  rt_tile.draw_tile(0, 0, map, chips, 0, 0, 4, 2)
  img_tile = rt_tile.to_image
  Window.draw(300, 100, img_tile)
  results << assert_pixel("game", 308, 108, 255, 0, 0, "RenderTarget.draw_tile: red tile at origin")

  show_results(results)
end
