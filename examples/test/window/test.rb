Window.init("game")

JS.document.getElementById('run').addEventListener('click') do |_e|
  results = []

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

  # Window.draw_line: draws a red horizontal line — check a midpoint pixel
  Window.draw_line(10, 185, 100, 185, [255, 0, 0])
  results << assert_pixel("game", 55, 185, 255, 0, 0, "Window.draw_line: midpoint pixel is red")

  # Window.draw_pixel: sets exactly one pixel
  Window.draw_pixel(5, 195, [0, 255, 0])
  results << assert_pixel("game", 5, 195, 0, 255, 0, "Window.draw_pixel: pixel is green")

  # Window.draw_circle_fill: filled circle — check center pixel
  Window.draw_circle_fill(180, 185, 12, [0, 0, 255])
  results << assert_pixel("game", 180, 185, 0, 0, 255, "Window.draw_circle_fill: center pixel is blue")

  # Window.draw_scale: scaled image — check pixel inside scaled area
  img2x = Image.new(10, 10, [255, 128, 0])
  Window.draw_scale(250, 178, img2x, 2.0, 2.0)
  results << assert_pixel("game", 255, 183, 255, 128, 0, "Window.draw_scale: pixel inside scaled area is orange")

  # Window.draw_rot: rotated image — visual only (transform makes pixel math hard)
  # Window.draw_alpha: semi-transparent draw — visual only

  # Visual checks
  Window.draw_font(10, 80,  "draw_font: this text should be visible", [255, 255, 255])
  Window.draw_box( 10, 115, 350, 165, [255, 220, 0])
  Window.draw_font(10, 172, "draw_box: yellow outline above should be visible", [180, 180, 180], 12)

  show_results(results)
end
