JS.document.getElementById('run').addEventListener('click') do |_e|
  results = []

  Window.init("game")
  results << assert_equal(400, Window.width,  "Window.width after init")
  results << assert_equal(220, Window.height, "Window.height after init")

  # Window.draw: fills a rect with the image color
  Window.draw(10, 10, Image.new(30, 30, [255, 0, 0]))
  results << assert_pixel("game", 25, 25, 255, 0, 0, "Window.draw: fills with image color")

  # Window.draw_box_fill: RGB
  Window.draw_box_fill(60, 10, 160, 60, [0, 128, 255])
  results << assert_pixel("game", 110, 35, 0, 128, 255, "Window.draw_box_fill: RGB fill")

  # Window.draw_box_fill: RGBA opaque
  Window.draw_box_fill(170, 10, 270, 60, [0, 200, 0, 255])
  results << assert_pixel("game", 220, 35, 0, 200, 0, "Window.draw_box_fill: RGBA opaque fill")

  # Visual checks
  Window.draw_font(10, 80,  "draw_font: this text should be visible", [255, 255, 255])
  Window.draw_box( 10, 115, 350, 165, [255, 220, 0])
  Window.draw_font(10, 172, "draw_box: yellow outline above should be visible", [180, 180, 180], 12)

  show_results(results)
end
