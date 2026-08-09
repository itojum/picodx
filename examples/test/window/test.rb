Window.init("game")

JS.document.getElementById('run').addEventListener('click') do |_e|
  results = []

  results << assert_equal(400, Window.width,  "Window.width after init")
  results << assert_equal(220, Window.height, "Window.height after init")

  # Window.fps: default 60, read/write
  results << assert_equal(60,   Window.fps,  "Window.fps default is 60")
  Window.fps = 30
  results << assert_equal(30,   Window.fps,  "Window.fps= sets target FPS")
  Window.fps = 60

  # Window.real_fps: default 0.0 before loop runs
  results << assert_equal(0.0, Window.real_fps, "Window.real_fps default is 0.0")

  # Window.running_time: 0 before loop starts
  results << assert_equal(0, Window.running_time, "Window.running_time is 0 before loop")

  # Window.ox / Window.oy: default 0, read/write
  results << assert_equal(0, Window.ox, "Window.ox default is 0")
  results << assert_equal(0, Window.oy, "Window.oy default is 0")
  Window.ox = 100
  Window.oy = 50
  results << assert_equal(100, Window.ox, "Window.ox= sets offset")
  results << assert_equal(50,  Window.oy, "Window.oy= sets offset")
  Window.ox = 0
  Window.oy = 0

  # Window.caption read/write
  Window.caption = "Test Title"
  results << assert_equal("Test Title", Window.caption, "Window.caption= sets document.title")
  Window.caption = "PicoDX — Window Test"

  # Window.bgcolor getter (setter already tested implicitly via init)
  results << assert_equal([0, 0, 0], Window.bgcolor, "Window.bgcolor default is black")
  Window.bgcolor = [255, 0, 128]
  results << assert_equal([255, 0, 128], Window.bgcolor, "Window.bgcolor getter reflects setter")
  Window.bgcolor = [0, 0, 0]

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

  # Window.draw_scale with cx/cy: anchor=(5,5) center of 10x10 image, scale=2x
  # scaled 20x20; anchor maps to (350,140); top-left at (340,130)
  img_cx = Image.new(10, 10, [255, 128, 0])
  Window.draw_scale(350, 140, img_cx, 2.0, 2.0, 5, 5)
  results << assert_pixel("game", 350, 140, 255, 128, 0, "Window.draw_scale(cx,cy): anchor pixel is orange")
  results << assert_pixel("game", 339, 129, 0,   0,   0, "Window.draw_scale(cx,cy): outside anchor is black")

  # Window.draw_rot: rotated image — visual only (transform makes pixel math hard)
  # Window.draw_alpha: semi-transparent draw — visual only

  # --- Window.loop re-entrancy ---
  # Outer loop runs 1 frame; on that frame it calls an inner Window.loop
  # which also runs 1 frame, draws a cyan box, then breaks.
  # After the inner loop exits, the outer block breaks too.
  # Both loops use break to exit, which raises LocalJumpError via Proc#call.
  outer_ran = false
  inner_ran = false
  Window.loop do
    outer_ran = true
    Window.loop do
      inner_ran = true
      Window.draw_box_fill(200, 200, 230, 215, [0, 255, 255])
      break
    end
    break
  end
  results << (outer_ran ? "<span class='pass'>PASS</span> re-entrant Window.loop: outer block ran" :
                          "<span class='fail'>FAIL</span> re-entrant Window.loop: outer block did not run")
  results << (inner_ran ? "<span class='pass'>PASS</span> re-entrant Window.loop: inner block ran" :
                          "<span class='fail'>FAIL</span> re-entrant Window.loop: inner block did not run")
  results << assert_pixel("game", 215, 207, 0, 255, 255, "re-entrant Window.loop: inner block drew cyan")

  # Visual checks
  Window.draw_font(10, 80,  "draw_font: this text should be visible", [255, 255, 255])
  Window.draw_box( 10, 115, 350, 165, [255, 220, 0])
  Window.draw_font(10, 172, "draw_box: yellow outline above should be visible", [180, 180, 180], 12)

  show_results(results)
end
