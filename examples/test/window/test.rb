# Pre-init setter test: call width=/height= before Window.init so the
# else-branch (preset path) is exercised and applied on first init.
Window.width  = 320
Window.height = 240
Window.init("game")

JS.document.getElementById('run').addEventListener('click') do |_e|
  results = []

  # Verify pre-init dimensions were applied by init
  canvas = JS.document.getElementById("game")
  results << assert_equal(320, Window.width,            "pre-init Window.width= applied by init")
  results << assert_equal(240, Window.height,           "pre-init Window.height= applied by init")
  results << assert_equal(320, canvas[:width].to_i,    "pre-init Window.width= applied to canvas DOM")
  results << assert_equal(240, canvas[:height].to_i,   "pre-init Window.height= applied to canvas DOM")

  # Reset to 400x220 for the rest of the tests
  Window.width  = 400
  Window.height = 220

  # Window.width= / Window.height=: setters update both instance variables and canvas DOM
  Window.width  = 500
  Window.height = 300
  results << assert_equal(500, Window.width,            "Window.width= updates instance variable")
  results << assert_equal(300, Window.height,           "Window.height= updates instance variable")
  results << assert_equal(500, canvas[:width].to_i,    "Window.width= updates canvas DOM width")
  results << assert_equal(300, canvas[:height].to_i,   "Window.height= updates canvas DOM height")
  Window.width  = 400
  Window.height = 220

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

  # Window.draw_box_fill: ARGB opaque
  Window.draw_box_fill(170, 10, 270, 60, [255, 0, 200, 0])
  results << assert_pixel("game", 220, 35, 0, 200, 0, "Window.draw_box_fill: ARGB opaque fill")

  # Window.draw_line: draws a red horizontal line — check a midpoint pixel
  Window.draw_line(10, 185, 100, 185, [255, 0, 0])
  results << assert_pixel("game", 55, 185, 255, 0, 0, "Window.draw_line: midpoint pixel is red")

  # Window.draw_pixel: sets exactly one pixel
  Window.draw_pixel(5, 195, [0, 255, 0])
  results << assert_pixel("game", 5, 195, 0, 255, 0, "Window.draw_pixel: pixel is green")

  # Window.draw_circle_fill: filled circle — check center pixel
  Window.draw_circle_fill(180, 185, 12, [0, 0, 255])
  results << assert_pixel("game", 180, 185, 0, 0, 255, "Window.draw_circle_fill: center pixel is blue")

  # Window.draw_scale: (x, y) is the unscaled top-left; default center is image center (5,5 for 10x10)
  # translate(255,183), scale(2,2), drawImage at (-5,-5) => top-left (245,173), size 20x20
  img2x = Image.new(10, 10, [255, 128, 0])
  Window.draw_scale(250, 178, img2x, 2.0, 2.0)
  results << assert_pixel("game", 250, 178, 255, 128, 0, "Window.draw_scale: unscaled top-left pixel is orange")
  results << assert_pixel("game", 245, 173, 255, 128, 0, "Window.draw_scale: scaled top-left corner is orange")
  results << assert_pixel("game", 244, 178, 0,   0,   0, "Window.draw_scale: left of scaled area is black")
  results << assert_pixel("game", 239, 167, 0,   0,   0, "Window.draw_scale: outside scaled area is black")

  # Window.draw_scale with cx/cy=(0,0): scales from the top-left, so (x, y) stays the top-left
  img_cx = Image.new(10, 10, [255, 128, 0])
  Window.draw_scale(340, 130, img_cx, 2.0, 2.0, 0, 0)
  results << assert_pixel("game", 340, 130, 255, 128, 0, "Window.draw_scale(cx=0,cy=0): top-left pixel is orange")
  results << assert_pixel("game", 359, 149, 255, 128, 0, "Window.draw_scale(cx=0,cy=0): bottom-right pixel is orange")
  results << assert_pixel("game", 339, 129, 0,   0,   0, "Window.draw_scale(cx=0,cy=0): outside top-left is black")

  # Window.draw_rot: 10x20 image rotated 90 degrees around its center (5,10)
  # center maps to (305,30); rotated footprint is 20x10 => (295..314, 25..34)
  img_rot = Image.new(10, 20, [0, 200, 200])
  Window.draw_rot(300, 20, img_rot, 90)
  results << assert_pixel("game", 296, 30, 0, 200, 200, "Window.draw_rot: rotated footprint extends left of x")
  results << assert_pixel("game", 305, 22, 0, 0,   0,   "Window.draw_rot: unrotated top edge is no longer covered")

  # Window.draw_ex: no transform => same as draw (top-left at (x, y))
  img_ex = Image.new(10, 10, [200, 0, 200])
  Window.draw_ex(360, 20, img_ex)
  results << assert_pixel("game", 360, 20, 200, 0, 200, "Window.draw_ex: top-left pixel at (x, y)")
  results << assert_pixel("game", 359, 19, 0,   0, 0,   "Window.draw_ex: outside top-left is black")

  # Window.draw_ex scale 2: default center is image center => footprint (355..374, 45..64)
  Window.draw_ex(360, 50, img_ex, { scale_x: 2, scale_y: 2 })
  results << assert_pixel("game", 355, 45, 200, 0, 200, "Window.draw_ex scale: scales around image center")
  results << assert_pixel("game", 354, 55, 0,   0, 0,   "Window.draw_ex scale: outside scaled area is black")

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

  # Window.init re-call: dimensions set via setter are preserved across re-init.
  # (True pre-init path — width= called before the very first init — is exercised
  # by the page-load sequence: canvas starts at 400x220 in HTML and init reads it.)
  Window.width  = 800
  Window.height = 600
  Window.init("game")
  results << assert_equal(800, Window.width,                                        "re-init preserves width set before init")
  results << assert_equal(600, Window.height,                                       "re-init preserves height set before init")
  results << assert_equal(800, JS.document.getElementById("game")[:width].to_i,    "re-init canvas DOM width correct")
  results << assert_equal(600, JS.document.getElementById("game")[:height].to_i,   "re-init canvas DOM height correct")
  Window.width  = 400
  Window.height = 220
  Window.init("game")

  # Stale-preset regression: dimensions set on one canvas must NOT bleed into
  # a subsequent Window.init with a different canvas (game2 is 200x100).
  Window.init("game")
  Window.width  = 800
  Window.height = 600
  Window.init("game2")
  results << assert_equal(200, Window.width,                                          "switching canvas: old preset width not applied to game2")
  results << assert_equal(100, Window.height,                                         "switching canvas: old preset height not applied to game2")
  results << assert_equal(200, JS.document.getElementById("game2")[:width].to_i,     "switching canvas: game2 DOM width is its own 200")
  results << assert_equal(100, JS.document.getElementById("game2")[:height].to_i,    "switching canvas: game2 DOM height is its own 100")
  Window.init("game")

  # Window.loop re-entrancy with break value ---
  # The inner loop exits via `break value` and the return value of Window.loop
  # should be that value (not nil).
  break_val = Window.loop do
    Window.loop do
      break 42
    end
    break
  end
  results << assert_equal(42, break_val, "re-entrant Window.loop: break value is returned")

  # Window.loop re-entrancy with return value ---
  # The inner loop is called from a helper method. The block uses `return` to
  # exit the method, carrying a value. Window.loop should propagate the
  # LocalJumpError's exit_value so the caller receives the value.
  def select_value
    Window.loop do
      Window.loop do
        return 99
      end
      break
    end
  end
  ret_val = select_value
  results << assert_equal(99, ret_val, "re-entrant Window.loop: return value is propagated")

  # Visual checks
  Window.draw_font(10, 80,  "draw_font: this text should be visible", [255, 255, 255])
  Window.draw_box( 10, 115, 350, 165, [255, 220, 0])
  Window.draw_font(10, 172, "draw_box: yellow outline above should be visible", [180, 180, 180], 12)

  # --- z-order tests: must run inside Window.loop so _flush_draw_queue is called ---
  Window.loop do
    # higher z drawn on top regardless of call order
    Window.draw_box_fill(10, 100, 50, 120, [255, 0, 0], z: 0)
    Window.draw_box_fill(10, 100, 50, 120, [0, 0, 255], z: 1)

    # reversed call order: lower z called last but still renders below
    Window.draw_box_fill(60, 100, 100, 120, [0, 128, 0], z: 1)
    Window.draw_box_fill(60, 100, 100, 120, [255, 0, 0], z: 0)

    # same z preserves call order (cyan overwrites magenta)
    Window.draw_box_fill(110, 100, 150, 120, [255, 0, 255], z: 0)
    Window.draw_box_fill(110, 100, 150, 120, [0, 255, 255], z: 0)

    # positional z (DXRuby signature): later call with lower z renders below
    z_top = Image.new(20, 20, [0, 0, 255])
    z_bot = Image.new(20, 20, [255, 0, 0])
    Window.draw(160, 100, z_top, 1)
    Window.draw(160, 100, z_bot, 0)
    Window.draw_box_fill(190, 100, 210, 120, [0, 0, 255], 1)
    Window.draw_box_fill(190, 100, 210, 120, [255, 0, 0], 0)
    Window.draw_scale(220, 100, z_top, 1, 1, nil, nil, 1)
    Window.draw(220, 100, z_bot, 0)
    Window.draw_alpha(250, 100, z_top, 255, 1)
    Window.draw(250, 100, z_bot, 0)
    # positional z wins over z: keyword
    Window.draw(280, 100, z_top, 2, z: 0)
    Window.draw(280, 100, z_bot, 1)
    break
  end
  results << assert_pixel("game", 170, 110, 0, 0, 255, "positional z: Window.draw(x, y, image, z)")
  results << assert_pixel("game", 200, 110, 0, 0, 255, "positional z: Window.draw_box_fill(..., color, z)")
  results << assert_pixel("game", 225, 105, 0, 0, 255, "positional z: Window.draw_scale(..., cx, cy, z)")
  results << assert_pixel("game", 260, 110, 0, 0, 255, "positional z: Window.draw_alpha(..., alpha, z)")
  results << assert_pixel("game", 290, 110, 0, 0, 255, "positional z: takes precedence over z: keyword")
  results << assert_pixel("game", 30,  110, 0,   0,   255, "z-order: higher-z (blue z:1) is drawn on top of lower-z (red z:0)")
  results << assert_pixel("game", 80,  110, 0,   128, 0,   "z-order: lower-z (red z:0) does not overwrite higher-z (green z:1)")
  results << assert_pixel("game", 130, 110, 0,   255, 255, "z-order: same z preserves call order (cyan overwrites magenta)")

  show_results(results)
end
