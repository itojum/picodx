Window.init("game")

JS.document.getElementById('run').addEventListener('click') do |_e|
  results = []

  # --- Row 1 (y=0): fill / box_fill / circle_fill ---

  # Image.new + Window.draw
  Window.draw(0, 0, Image.new(60, 40, [255, 0, 0]))
  results << assert_pixel("game", 30, 20, 255, 0, 0, "Image.new([255,0,0]) → Window.draw renders red")

  # Image#fill
  img_fill = Image.new(60, 40, [0, 0, 0])
  img_fill.fill([0, 255, 0])
  Window.draw(65, 0, img_fill)
  results << assert_pixel("game", 95, 20, 0, 255, 0, "Image#fill renders green")

  # Image#box_fill
  img_boxf = Image.new(60, 40, [20, 20, 20])
  img_boxf.box_fill(5, 5, 55, 35, [0, 0, 255])
  Window.draw(130, 0, img_boxf)
  results << assert_pixel("game", 160, 20, 0, 0, 255, "Image#box_fill inside is blue")
  results << assert_pixel("game", 132, 2,  20, 20, 20, "Image#box_fill outside corner is dark")

  # Image#circle_fill
  img_circ = Image.new(60, 60, [10, 10, 10])
  img_circ.circle_fill(30, 30, 22, [255, 128, 0])
  Window.draw(195, 0, img_circ)
  results << assert_pixel("game", 225, 30, 255, 128, 0, "Image#circle_fill center is orange")
  results << assert_pixel("game", 197, 2,  10, 10, 10, "Image#circle_fill corner outside is dark")

  # --- Row 2 (y=65): line / box / circle / triangle ---

  # Image#line
  img_line = Image.new(60, 40, [0, 0, 0])
  img_line.line(0, 20, 60, 20, [255, 255, 0])
  Window.draw(0, 65, img_line)
  results << assert_pixel("game", 30, 85, 255, 255, 0, "Image#line midpoint is yellow")

  # Image#box (outline)
  img_box = Image.new(60, 40, [0, 0, 0])
  img_box.box(5, 5, 55, 35, [255, 0, 255])
  Window.draw(65, 65, img_box)
  results << assert_pixel("game", 95, 70, 255, 0, 255, "Image#box top edge is magenta")
  results << assert_pixel("game", 95, 85, 0,   0,   0, "Image#box interior is black")

  # Image#circle (outline, visual only – antialiasing makes exact check fragile)
  img_circ2 = Image.new(60, 60, [0, 0, 0])
  img_circ2.circle(30, 30, 22, [0, 255, 255])
  Window.draw(130, 65, img_circ2)

  # Image#triangle_fill
  img_tri = Image.new(60, 60, [0, 0, 0])
  img_tri.triangle_fill(30, 5, 55, 55, 5, 55, [200, 200, 0])
  Window.draw(195, 65, img_tri)
  results << assert_pixel("game", 225, 103, 200, 200, 0, "Image#triangle_fill centroid is yellow-ish")

  # --- Pixel access ---

  # Image#[]= and Image#[]
  img_px = Image.new(10, 10, [0, 0, 0])
  img_px[5, 5] = [77, 88, 99]
  px = img_px[5, 5]
  results << assert_equal(77, px[0], "Image#[]= and [] r")
  results << assert_equal(88, px[1], "Image#[]= and [] g")
  results << assert_equal(99, px[2], "Image#[]= and [] b")

  # --- Row 3 (y=135): slice / dup / Image#draw ---

  # Image#slice
  src = Image.new(60, 40, [255, 0, 0])
  src.box_fill(10, 10, 50, 30, [0, 220, 0])
  sliced = src.slice(10, 10, 40, 20)
  results << assert_equal(40, sliced.width,  "Image#slice width")
  results << assert_equal(20, sliced.height, "Image#slice height")
  Window.draw(0, 135, sliced)
  results << assert_pixel("game", 20, 145, 0, 220, 0, "Image#slice content is green")

  # Image#dup
  orig = Image.new(60, 40, [0, 0, 200])
  copy = orig.dup
  results << assert_equal(60, copy.width,  "Image#dup width")
  results << assert_equal(40, copy.height, "Image#dup height")
  Window.draw(50, 135, copy)
  results << assert_pixel("game", 80, 155, 0, 0, 200, "Image#dup content is blue")

  # Image#draw (blit one image onto another)
  base  = Image.new(60, 40, [30, 30, 30])
  stamp = Image.new(20, 20, [255, 0, 100])
  base.draw(20, 10, stamp)
  Window.draw(120, 135, base)
  results << assert_pixel("game", 150, 155,   255, 0, 100, "Image#draw stamp inside base")
  results << assert_pixel("game", 122, 137,   30, 30, 30,  "Image#draw base outside stamp is dark")

  # --- Image.load ---
  gear = Image.load("/test/image/image.png")
  results << assert_equal(256, gear.width,  "Image.load width")
  results << assert_equal(256, gear.height, "Image.load height")
  Window.draw_scale(260, 0, gear, 0.625, 0.625)
  Window.draw_font(262, 143, "Image.load (visual)", [140, 140, 140], 10)

  # --- Visual labels ---
  Window.draw_font(0,  60, "new / fill / box_fill / circle_fill", [140, 140, 140], 10)
  Window.draw_font(0, 128, "line / box / circle / triangle_fill", [140, 140, 140], 10)
  Window.draw_font(0, 190, "slice / dup / Image#draw   ([]= / [] tested via assert_equal)", [140, 140, 140], 10)

  show_results(results)
end
