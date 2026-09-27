Window.init("game")

JS.document.getElementById('run').addEventListener('click') do |_e|
  results = []

  # --- draw_add ---
  bg = Image.new(60, 40, [100, 0, 0])
  overlay = Image.new(60, 40, [0, 100, 0])
  Window.draw(0, 0, bg)
  Window.draw_add(0, 0, overlay)
  # Additive: red(100,0,0) + green(0,100,0) = (100,100,0) yellow-ish
  r = JS.eval("document.getElementById('game').getContext('2d').getImageData(30,20,1,1).data[0]").to_i
  g = JS.eval("document.getElementById('game').getContext('2d').getImageData(30,20,1,1).data[1]").to_i
  results << (r > 50 && g > 50 ? "<span class='pass'>PASS</span> draw_add: red+green → both channels lit (#{r},#{g})" :
                                  "<span class='fail'>FAIL</span> draw_add: expected both channels > 50, got (#{r},#{g})")

  # draw_add does NOT raise
  begin
    img_add = Image.new(10, 10, [200, 0, 0])
    Window.draw_add(0, 0, img_add)
    results << "<span class='pass'>PASS</span> draw_add does not raise"
  rescue => e
    results << "<span class='fail'>FAIL</span> draw_add raised: #{e.message}"
  end

  # --- draw_sub ---
  begin
    img_sub = Image.new(10, 10, [50, 50, 50])
    Window.draw_sub(70, 0, img_sub)
    results << "<span class='pass'>PASS</span> draw_sub does not raise"
  rescue => e
    results << "<span class='fail'>FAIL</span> draw_sub raised: #{e.message}"
  end

  # --- draw_morph (basic: no-op quad = straight rectangle) ---
  src = Image.new(40, 40, [0, 0, 200])
  begin
    Window.draw_morph(80, 0, 120, 0, 120, 40, 80, 40, src)
    results << "<span class='pass'>PASS</span> draw_morph does not raise"
  rescue => e
    results << "<span class='fail'>FAIL</span> draw_morph raised: #{e.message}"
  end
  # check center pixel of the drawn blue rect
  b = JS.eval("document.getElementById('game').getContext('2d').getImageData(100,20,1,1).data[2]").to_i
  results << (b > 100 ? "<span class='pass'>PASS</span> draw_morph: blue rect drawn at (100,20): b=#{b}" :
                        "<span class='fail'>FAIL</span> draw_morph: expected blue at (100,20), got b=#{b}")

  # --- draw_morph (skewed quad — visual only) ---
  red_img = Image.new(40, 40, [200, 50, 50])
  Window.draw_morph(140, 5, 180, 0, 175, 40, 135, 38, red_img)
  results << "<span class='pass'>PASS</span> draw_morph skewed: no crash (inspect canvas)"

  # --- Shader raises NotImplementedError ---
  begin
    Shader.new("dummy")
    results << "<span class='fail'>FAIL</span> Shader.new should raise NotImplementedError"
  rescue NotImplementedError => e
    results << "<span class='pass'>PASS</span> Shader.new raises NotImplementedError"
  rescue => e
    results << "<span class='fail'>FAIL</span> Shader.new raised wrong error: #{e.class}"
  end

  begin
    Window.draw_shader(nil)
    results << "<span class='fail'>FAIL</span> Window.draw_shader should raise NotImplementedError"
  rescue NotImplementedError
    results << "<span class='pass'>PASS</span> Window.draw_shader raises NotImplementedError"
  end

  show_results(results)
end
