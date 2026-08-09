Window.init("game")

JS.document.getElementById('run').addEventListener('click') do |_e|
  results = []

  # --- Font constants ---
  results << assert_equal(400, Font::NORMAL, "Font::NORMAL == 400")
  results << assert_equal(700, Font::BOLD,   "Font::BOLD == 700")

  # --- Font.new defaults ---
  f = Font.new(24)
  results << assert_equal(24,           f.size,     "Font.new(24).size")
  results << assert_equal("",           f.fontname, "Font.new(24).fontname defaults to empty")
  results << assert_equal(false,        f.italic,   "Font.new(24).italic defaults to false")
  results << assert_equal(Font::NORMAL, f.weight,   "Font.new(24).weight defaults to NORMAL")

  # --- Font.new with options ---
  fb = Font.new(16, "Arial", italic: true, weight: Font::BOLD)
  results << assert_equal(16,         fb.size,     "Font.new with options: size")
  results << assert_equal("Arial",    fb.fontname, "Font.new with options: fontname")
  results << assert_equal(true,       fb.italic,   "Font.new with options: italic")
  results << assert_equal(Font::BOLD, fb.weight,   "Font.new with options: weight")

  # fontname / name alias
  results << assert_equal(fb.fontname, fb.name, "Font#name is alias for fontname")

  # --- Font#_css_font ---
  plain = Font.new(20)
  results << assert_equal("400 20px monospace", plain._css_font, "Font#_css_font default")

  named = Font.new(14, "Helvetica")
  results << assert_equal("400 14px Helvetica, monospace", named._css_font, "Font#_css_font with named font")

  italic_bold = Font.new(18, "", italic: true, weight: Font::BOLD)
  results << assert_equal("italic 700 18px monospace", italic_bold._css_font, "Font#_css_font italic bold")

  # --- Font#get_width ---
  fw = Font.new(16)
  w_short = fw.get_width("Hi")
  w_long  = fw.get_width("Hello, World!")
  results << (w_short > 0 ? "<span class='pass'>PASS</span> Font#get_width returns positive (#{w_short}px)" :
                            "<span class='fail'>FAIL</span> Font#get_width returned #{w_short}, expected > 0")
  results << (w_long > w_short ? "<span class='pass'>PASS</span> Font#get_width: longer string is wider (#{w_long} > #{w_short})" :
                                 "<span class='fail'>FAIL</span> longer string not wider: #{w_long} vs #{w_short}")

  # --- Font.default ---
  Font.default = Font.new(16)
  results << assert_equal(16, Font.default.size, "Font.default returns Font with size 16")
  Font.default = Font.new(12, "monospace")
  results << assert_equal(12, Font.default.size, "Font.default= sets a new default")

  # --- Window.draw_font with Font object (new API) ---
  Window.draw_box_fill(0, 0, 480, 30, [0, 0, 0])
  fnt = Font.new(20)
  Window.draw_font(10, 5, "Font test", fnt, [255, 255, 255])
  # Sample x positions in the text row — expect at least one non-black pixel
  white_found = false
  px = 10
  while px <= 150
    v = JS.eval("document.getElementById('game').getContext('2d').getImageData(#{px},15,1,1).data[0]").to_i
    white_found = true if v > 0
    px += 1
  end
  results << (white_found ? "<span class='pass'>PASS</span> Window.draw_font(Font) renders white text" :
                            "<span class='fail'>FAIL</span> Window.draw_font(Font) produced no visible text")

  # --- Window.draw_font with Font + hash color ---
  Window.draw_box_fill(0, 35, 480, 65, [0, 0, 0])
  Window.draw_font(10, 40, "Hash color", fnt, { color: [255, 0, 0], z: 1 })
  red_found = false
  px = 10
  while px <= 130
    r = JS.eval("document.getElementById('game').getContext('2d').getImageData(#{px},50,1,1).data[0]").to_i
    g = JS.eval("document.getElementById('game').getContext('2d').getImageData(#{px},50,1,1).data[1]").to_i
    red_found = true if r > 100 && g < 50
    px += 1
  end
  results << (red_found ? "<span class='pass'>PASS</span> Window.draw_font(Font, hash) renders in red" :
                          "<span class='fail'>FAIL</span> Window.draw_font(Font, hash) color not detected")

  # --- Legacy Window.draw_font(x, y, str, color, size) ---
  Window.draw_box_fill(0, 70, 480, 100, [0, 0, 0])
  Window.draw_font(10, 75, "Legacy API", [0, 255, 0], 16)
  green_found = false
  px = 10
  while px <= 120
    v = JS.eval("document.getElementById('game').getContext('2d').getImageData(#{px},85,1,1).data[1]").to_i
    green_found = true if v > 0
    px += 1
  end
  results << (green_found ? "<span class='pass'>PASS</span> Window.draw_font legacy (color, size) still works" :
                            "<span class='fail'>FAIL</span> Window.draw_font legacy API broke")

  # --- Image#draw_font ---
  img = Image.new(200, 30, [0, 0, 0])
  img_font = Font.new(18)
  img.draw_font(5, 5, "Image text", img_font, [255, 255, 0])
  Window.draw(0, 105, img)
  yellow_found = false
  px = 5
  while px <= 150
    r = JS.eval("document.getElementById('game').getContext('2d').getImageData(#{px},118,1,1).data[0]").to_i
    g = JS.eval("document.getElementById('game').getContext('2d').getImageData(#{px},118,1,1).data[1]").to_i
    yellow_found = true if r > 100 && g > 100
    px += 1
  end
  results << (yellow_found ? "<span class='pass'>PASS</span> Image#draw_font renders yellow text onto image" :
                             "<span class='fail'>FAIL</span> Image#draw_font produced no visible text")

  # Visual labels
  Window.draw_font(0, 140, "Window.draw_font new API (white above)", [120, 120, 120], 11)
  Window.draw_font(0, 153, "Window.draw_font hash color (red above)", [120, 120, 120], 11)
  Window.draw_font(0, 166, "Window.draw_font legacy (green above)", [120, 120, 120], 11)
  Window.draw_font(0, 179, "Image#draw_font (yellow on image above)", [120, 120, 120], 11)

  show_results(results)
end
