Window.init("game")

JS.document.getElementById('run').addEventListener('click') do |_e|
  results = []

  # --- Image.create_from_array ---
  arr = [
    [255, 255, 0, 0],
    [255, 0, 255, 0]
  ]
  img_arr = Image.create_from_array(2, 1, arr)
  results << assert_equal(2, img_arr.width,  "Image.create_from_array: width")
  results << assert_equal(1, img_arr.height, "Image.create_from_array: height")
  px0 = img_arr[0, 0]
  results << assert_equal(255, px0[0], "create_from_array px[0] a=255")
  results << assert_equal(255, px0[1], "create_from_array px[0] r=255")
  results << assert_equal(0,   px0[2], "create_from_array px[0] g=0")
  results << assert_equal(0,   px0[3], "create_from_array px[0] b=0")
  px1 = img_arr[1, 0]
  results << assert_equal(0, px1[1], "create_from_array px[1] r=0")
  results << assert_equal(255, px1[2], "create_from_array px[1] g=255")

  # --- Image#dispose / disposed? ---
  img_d = Image.new(10, 10, [255, 0, 0])
  results << assert_equal(false, img_d.disposed?, "Image#disposed? false before dispose")
  img_d.dispose
  results << assert_equal(true, img_d.disposed?, "Image#disposed? true after dispose")

  # --- Image#set_color_key ---
  img_ck = Image.new(4, 4, [0, 255, 0])
  img_ck.box_fill(1, 1, 3, 3, [255, 0, 0])
  img_ck.set_color_key([0, 255, 0])
  px_ck = img_ck[0, 0]
  results << assert_equal(0, px_ck[0], "Image#set_color_key: matched pixel alpha=0")
  px_inner = img_ck[2, 2]
  results << (px_inner[0] > 0 ? "<span class='pass'>PASS</span> Image#set_color_key: non-matched pixel still opaque (#{px_inner.inspect})" :
                                 "<span class='fail'>FAIL</span> Image#set_color_key: non-matched pixel became transparent")

  # --- Image#copy_rect ---
  src_cr = Image.new(20, 20, [100, 100, 100])
  src_cr.box_fill(5, 5, 15, 15, [0, 0, 200])
  dst_cr = Image.new(20, 20, [50, 50, 50])
  dst_cr.copy_rect(0, 0, src_cr, 5, 5, 10, 10)
  px_copy = dst_cr[5, 5]
  results << (px_copy[3] > 100 ? "<span class='pass'>PASS</span> Image#copy_rect: blue pixels copied (b=#{px_copy[3]})" :
                                   "<span class='fail'>FAIL</span> Image#copy_rect: expected blue, got #{px_copy.inspect}")

  # --- Image#slice_tiles ---
  base_t = Image.new(40, 20, [0, 0, 0, 0])
  base_t.box_fill(0, 0, 20, 20, [200, 0, 0])
  base_t.box_fill(20, 0, 40, 20, [0, 200, 0])
  tiles = base_t.slice_tiles(2, 1)
  results << assert_equal(1, tiles.length,    "Image#slice_tiles: 1 row")
  results << assert_equal(2, tiles[0].length, "Image#slice_tiles: 2 cols")
  results << assert_equal(20, tiles[0][0].width,  "Image#slice_tiles: tile width")
  results << assert_equal(20, tiles[0][0].height, "Image#slice_tiles: tile height")

  # --- Font#dispose / disposed? ---
  fnt = Font.new(12)
  results << assert_equal(false, fnt.disposed?, "Font#disposed? false before dispose")
  fnt.dispose
  results << assert_equal(true, fnt.disposed?, "Font#disposed? true after dispose")

  # --- Sound#frequency / #pan getters ---
  snd = Sound.new("/test/sound/beep.wav")
  snd.pan = 0.5
  results << assert_equal(0.5, snd.pan, "Sound#pan getter")
  results << assert_equal(nil, snd.frequency, "Sound#frequency getter returns nil when not set")

  # --- Sprite#collision_enable ---
  sp = Sprite.new(0, 0, Image.new(10, 10))
  sp.collision = [0, 0, 10, 10]
  results << assert_equal(true, sp.collision_enable, "Sprite#collision_enable default true")
  sp.collision_enable = false
  results << assert_equal(false, sp.collision_enable, "Sprite#collision_enable= false")
  results << assert_equal([], sp.check([sp]), "Sprite#check returns [] when collision_enable=false")
  sp.collision_enable = true
  results << assert_equal([sp], sp.check([sp]), "Sprite#check works when collision_enable=true")

  # --- Sprite#param_hash ---
  sp2 = Sprite.new(10, 20, Image.new(5, 5))
  ph = sp2.param_hash
  results << assert_equal(10, ph[:x], "Sprite#param_hash :x")
  results << assert_equal(20, ph[:y], "Sprite#param_hash :y")
  results << assert_equal(0,  ph[:angle], "Sprite#param_hash :angle")

  # --- Window.created? ---
  results << assert_equal(true, Window.created?, "Window.created? returns true after init")

  # --- Window.active? (can't fully test, just check it doesn't raise) ---
  begin
    v = Window.active?
    results << (v == true || v == false ? "<span class='pass'>PASS</span> Window.active? returns bool (#{v})" :
                                           "<span class='fail'>FAIL</span> Window.active? returned #{v.inspect}")
  rescue => e
    results << "<span class='fail'>FAIL</span> Window.active? raised: #{e.message}"
  end

  # --- NotImplementedError stubs ---
  begin
    Window.full_screen?
    results << "<span class='fail'>FAIL</span> Window.full_screen? should raise"
  rescue NotImplementedError
    results << "<span class='pass'>PASS</span> Window.full_screen? raises NotImplementedError"
  end

  begin
    RenderTarget.new(10, 10).draw_shader(nil)
    results << "<span class='fail'>FAIL</span> RenderTarget#draw_shader should raise"
  rescue NotImplementedError
    results << "<span class='pass'>PASS</span> RenderTarget#draw_shader raises NotImplementedError"
  end

  begin
    Sprite.new.shader = nil
    results << "<span class='fail'>FAIL</span> Sprite#shader= should raise"
  rescue NotImplementedError
    results << "<span class='pass'>PASS</span> Sprite#shader= raises NotImplementedError"
  end

  show_results(results)
end
