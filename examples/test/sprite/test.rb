Window.init("game")

JS.document.getElementById('run').addEventListener('click') do |_e|
  results = []

  img = Image.new(30, 20, [255, 0, 0])

  # --- Sprite.new attribute defaults ---
  sp = Sprite.new(50, 80, img)
  results << assert_equal(50.0, sp.x,       "Sprite.new x")
  results << assert_equal(80.0, sp.y,       "Sprite.new y")
  results << assert_equal(0,    sp.z,       "Sprite.new z default 0")
  results << assert_equal(0,    sp.angle,   "Sprite.new angle default 0")
  results << assert_equal(1.0,  sp.scale_x, "Sprite.new scale_x default 1.0")
  results << assert_equal(1.0,  sp.scale_y, "Sprite.new scale_y default 1.0")
  results << assert_equal(255,  sp.alpha,   "Sprite.new alpha default 255")
  results << assert_equal(:alpha, sp.blend,   "Sprite.new blend default :alpha")
  results << assert_equal(true,   sp.visible,  "Sprite.new visible default true")
  results << assert_equal(false,  sp.vanished?, "Sprite.new vanished? is false")
  results << (sp.image.equal?(img) ? "<span class='pass'>PASS</span> Sprite.new image attr" :
                                     "<span class='fail'>FAIL</span> Sprite.new image attr")

  # --- attr setters ---
  sp.x = 100; sp.y = 60
  results << assert_equal(100, sp.x, "Sprite#x= setter")
  results << assert_equal(60,  sp.y, "Sprite#y= setter")

  # --- Sprite#draw renders image at (x, y) with center origin ---
  # image 30×20, center=(15,10), drawn via draw_ex(100,60,image,{cx:15,cy:10})
  # → drawImage at (100-15, 60-10)=(85,50); center pixel = (100,60)
  sp.draw
  results << assert_pixel("game", 100, 60, 255, 0, 0, "Sprite#draw: center pixel is red")
  results << assert_pixel("game", 84,  49, 0,   0, 0, "Sprite#draw: just outside top-left is black")

  # --- visible=false skips draw ---
  sp2 = Sprite.new(200, 80, Image.new(20, 20, [0, 255, 0]))
  sp2.visible = false
  sp2.draw
  results << assert_pixel("game", 200, 80, 0, 0, 0, "Sprite#draw skips when visible=false")

  # --- vanish / vanished? ---
  sp3 = Sprite.new(250, 80, Image.new(20, 20, [0, 0, 255]))
  sp3.vanish
  results << assert_equal(true, sp3.vanished?, "Sprite#vanish sets vanished? to true")
  sp3.draw
  results << assert_pixel("game", 250, 80, 0, 0, 0, "vanished sprite is not drawn")

  # --- Collision detection: Sprite#check (overlapping) ---
  a = Sprite.new(10, 10, nil); a.collision = [0, 0, 30, 30]
  b = Sprite.new(20, 20, nil); b.collision = [0, 0, 30, 30]
  hits = a.check(b)
  results << (hits.include?(b) ? "<span class='pass'>PASS</span> Sprite#check detects overlap" :
                                 "<span class='fail'>FAIL</span> Sprite#check missed overlapping sprite")

  # --- Non-overlapping ---
  c = Sprite.new(100, 100, nil); c.collision = [0, 0, 20, 20]
  results << (a.check(c).empty? ? "<span class='pass'>PASS</span> Sprite#check empty for non-overlapping" :
                                  "<span class='fail'>FAIL</span> Sprite#check falsely detected collision")

  # --- Sprite#=== ---
  results << (a === b ? "<span class='pass'>PASS</span> Sprite#=== true for overlapping" :
                        "<span class='fail'>FAIL</span> Sprite#=== false for overlapping")
  results << (!(a === c) ? "<span class='pass'>PASS</span> Sprite#=== false for non-overlapping" :
                           "<span class='fail'>FAIL</span> Sprite#=== true for non-overlapping")

  # --- nil collision skips check ---
  d = Sprite.new(15, 15, nil)
  results << (a.check(d).empty? ? "<span class='pass'>PASS</span> Sprite#check skips nil collision" :
                                  "<span class='fail'>FAIL</span> Sprite#check wrong result for nil collision")

  # --- Sprite#check with array ---
  hits_arr = a.check([b, c, d])
  results << assert_equal(1, hits_arr.length, "Sprite#check(array) returns only colliding sprites")
  results << (hits_arr[0].equal?(b) ? "<span class='pass'>PASS</span> Sprite#check(array) correct sprite" :
                                      "<span class='fail'>FAIL</span> Sprite#check(array) wrong sprite")

  # --- Sprite.draw(array): sorted by z ---
  red_img  = Image.new(40, 40, [255, 0, 0])
  blue_img = Image.new(40, 40, [0, 0, 255])
  sp_red  = Sprite.new(320, 80, red_img)
  sp_blue = Sprite.new(320, 80, blue_img)
  sp_red.z  = 1
  sp_blue.z = 2
  Sprite.draw([sp_red, sp_blue])
  # center=(20,20) → pixel at (320,80) should be blue (higher z on top)
  results << assert_pixel("game", 320, 80, 0, 0, 255, "Sprite.draw(array): higher z drawn on top")

  # Reverse order: blue(z=1) drawn before red(z=2), red wins
  sp_red2  = Sprite.new(380, 80, red_img)
  sp_blue2 = Sprite.new(380, 80, blue_img)
  sp_red2.z  = 2
  sp_blue2.z = 1
  Sprite.draw([sp_red2, sp_blue2])
  results << assert_pixel("game", 380, 80, 255, 0, 0, "Sprite.draw(array): z=2 red drawn on top of z=1 blue")

  # --- Circle vs Circle ---
  cc_a = Sprite.new(0, 0, nil);   cc_a.collision = [0, 0, 20]
  cc_b = Sprite.new(10, 10, nil); cc_b.collision = [0, 0, 20]
  results << (cc_a === cc_b ? "<span class='pass'>PASS</span> circle vs circle: overlapping" :
                              "<span class='fail'>FAIL</span> circle vs circle: should overlap")
  cc_c = Sprite.new(50, 0, nil);  cc_c.collision = [0, 0, 10]
  cc_d = Sprite.new(0, 0, nil);   cc_d.collision = [0, 0, 10]
  results << (!(cc_c === cc_d) ? "<span class='pass'>PASS</span> circle vs circle: non-overlapping" :
                                 "<span class='fail'>FAIL</span> circle vs circle: should not overlap")

  # --- Circle vs Rect ---
  cr_circ = Sprite.new(0, 0, nil);  cr_circ.collision = [15, 15, 10]
  cr_rect = Sprite.new(0, 0, nil);  cr_rect.collision = [0, 0, 30, 30]
  results << (cr_circ === cr_rect ? "<span class='pass'>PASS</span> circle vs rect: overlapping" :
                                    "<span class='fail'>FAIL</span> circle vs rect: should overlap")
  cr_far = Sprite.new(0, 0, nil);  cr_far.collision = [50, 50, 5]
  results << (!(cr_far === cr_rect) ? "<span class='pass'>PASS</span> circle vs rect: non-overlapping" :
                                      "<span class='fail'>FAIL</span> circle vs rect: should not overlap")

  # --- Point vs Rect ---
  pr_pt  = Sprite.new(0, 0, nil); pr_pt.collision  = [15, 15]
  pr_rect = Sprite.new(0, 0, nil); pr_rect.collision = [0, 0, 30, 30]
  results << (pr_pt === pr_rect ? "<span class='pass'>PASS</span> point vs rect: inside" :
                                  "<span class='fail'>FAIL</span> point vs rect: should be inside")
  pr_out = Sprite.new(0, 0, nil); pr_out.collision = [50, 50]
  results << (!(pr_out === pr_rect) ? "<span class='pass'>PASS</span> point vs rect: outside" :
                                      "<span class='fail'>FAIL</span> point vs rect: should be outside")

  # --- Point vs Circle ---
  pc_pt   = Sprite.new(0, 0, nil); pc_pt.collision  = [5, 5]
  pc_circ = Sprite.new(0, 0, nil); pc_circ.collision = [0, 0, 20]
  results << (pc_pt === pc_circ ? "<span class='pass'>PASS</span> point vs circle: inside" :
                                  "<span class='fail'>FAIL</span> point vs circle: should be inside")
  pc_far = Sprite.new(0, 0, nil); pc_far.collision = [30, 0]
  results << (!(pc_far === pc_circ) ? "<span class='pass'>PASS</span> point vs circle: outside" :
                                      "<span class='fail'>FAIL</span> point vs circle: should be outside")

  # --- Point vs Point ---
  pp1 = Sprite.new(0, 0, nil); pp1.collision = [5, 5]
  pp2 = Sprite.new(0, 0, nil); pp2.collision = [5, 5]
  pp3 = Sprite.new(0, 0, nil); pp3.collision = [10, 5]
  results << (pp1 === pp2 ? "<span class='pass'>PASS</span> point vs point: same" :
                            "<span class='fail'>FAIL</span> point vs point: same should collide")
  results << (!(pp1 === pp3) ? "<span class='pass'>PASS</span> point vs point: different" :
                               "<span class='fail'>FAIL</span> point vs point: different should not collide")

  # --- Sprite.clean(array) ---
  live = Sprite.new(0, 0, nil)
  dead = Sprite.new(0, 0, nil)
  dead.vanish
  arr = [live, dead, nil, live]
  Sprite.clean(arr)
  results << assert_equal(2, arr.length, "Sprite.clean removes vanished and nil")
  all_live = true
  arr.each { |s| all_live = false unless s.equal?(live) }
  results << (all_live ? "<span class='pass'>PASS</span> Sprite.clean keeps only live sprites" :
                         "<span class='fail'>FAIL</span> Sprite.clean kept wrong sprites")

  show_results(results)
end
