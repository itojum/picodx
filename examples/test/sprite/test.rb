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

  # --- Sprite#draw renders image with its top-left at (x, y) (offset_sync = false) ---
  # image 30×20 occupies (100..129, 60..79); its center pixel is (115, 70)
  sp.draw
  results << assert_pixel("game", 115, 70, 255, 0, 0, "Sprite#draw: center pixel is red")
  results << assert_pixel("game", 100, 60, 255, 0, 0, "Sprite#draw: top-left pixel at (x, y) is red")
  results << assert_pixel("game", 99,  59, 0,   0, 0, "Sprite#draw: just outside top-left is black")

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

  # --- nil collision without image skips check ---
  d = Sprite.new(15, 15, nil)
  results << (a.check(d).empty? ? "<span class='pass'>PASS</span> Sprite#check skips nil collision without image" :
                                  "<span class='fail'>FAIL</span> Sprite#check wrong result for nil collision without image")

  # --- nil collision with image uses the whole image ---
  # 30×20 image at (35,35) → (35,35)-(65,55); a is (10,10)-(40,40) → overlap
  e = Sprite.new(35, 35, img)
  results << (a === e ? "<span class='pass'>PASS</span> nil collision with image: whole image is the hit area" :
                        "<span class='fail'>FAIL</span> nil collision with image: should collide with whole image")
  f = Sprite.new(41, 41, img)
  results << (!(a === f) ? "<span class='pass'>PASS</span> nil collision with image: no hit outside the image" :
                           "<span class='fail'>FAIL</span> nil collision with image: should not collide outside the image")
  e2 = Sprite.new(60, 40, img)
  results << (e.check([e2, f]).length == 2 ? "<span class='pass'>PASS</span> nil collision on both sides: Sprite#check uses images" :
                                             "<span class='fail'>FAIL</span> nil collision on both sides: Sprite#check should use images")
  results << assert_equal(nil, e.collision, "nil collision with image: collision getter stays nil")

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

  # --- Rect vs Circle ---
  results << (cr_rect === cr_circ ? "<span class='pass'>PASS</span> rect vs circle: overlapping" :
                                    "<span class='fail'>FAIL</span> rect vs circle: should overlap")
  results << (!(cr_rect === cr_far) ? "<span class='pass'>PASS</span> rect vs circle: non-overlapping" :
                                      "<span class='fail'>FAIL</span> rect vs circle: should not overlap")

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

  # --- Sprite#offset_sync ---
  # Default is false
  os_def = Sprite.new(0, 0, nil)
  results << assert_equal(false, os_def.offset_sync, "Sprite#offset_sync default is false")

  # offset_sync=true: collision shifted by -center_x/-center_y
  # Sprite at (100,100), center=(50,50), collision [0,0,10,10]
  # → effective rect (50,50)-(60,60)
  os_a = Sprite.new(100, 100, nil)
  os_a.center_x    = 50
  os_a.center_y    = 50
  os_a.offset_sync = true
  os_a.collision   = [0, 0, 10, 10]

  # Sprite at (55,55), no offset, collision [0,0,10,10] → rect (55,55)-(65,65)
  os_b = Sprite.new(55, 55, nil)
  os_b.collision = [0, 0, 10, 10]

  results << (os_a === os_b ? "<span class='pass'>PASS</span> offset_sync=true: collision shifts to overlap" :
                              "<span class='fail'>FAIL</span> offset_sync=true: should overlap after shift")

  # Without offset_sync the same sprite at (100,100) does NOT reach (55,55)-(65,65)
  os_c = Sprite.new(100, 100, nil)
  os_c.center_x    = 50
  os_c.center_y    = 50
  os_c.offset_sync = false
  os_c.collision   = [0, 0, 10, 10]

  results << (!(os_c === os_b) ? "<span class='pass'>PASS</span> offset_sync=false: no shift, no overlap" :
                                 "<span class='fail'>FAIL</span> offset_sync=false: should not overlap without shift")

  # offset_sync=true without center_x/center_y: collision uses the image center
  # 20x20 image at (100,100) → collision rect (90,90)-(110,110)
  os_img = Image.new(20, 20, [0, 255, 0])
  os_d = Sprite.new(100, 100, os_img)
  os_d.offset_sync = true
  os_d.collision   = [0, 0, 20, 20]
  os_e = Sprite.new(85, 85, nil)
  os_e.collision   = [0, 0, 6, 6]
  results << (os_d === os_e ? "<span class='pass'>PASS</span> offset_sync=true: default center is image center for collision" :
                              "<span class='fail'>FAIL</span> offset_sync=true: collision should shift by image center")

  # offset_sync=true: draw puts the image center at (x, y)
  # 20x20 image at (420,150) → drawn at (410..429, 140..159)
  os_f = Sprite.new(420, 150, os_img)
  os_f.offset_sync = true
  os_f.draw
  results << assert_pixel("game", 410, 140, 0, 255, 0, "offset_sync=true: draw top-left is (x - cx, y - cy)")
  results << assert_pixel("game", 429, 159, 0, 255, 0, "offset_sync=true: draw bottom-right inside")
  results << assert_pixel("game", 430, 159, 0, 0,   0, "offset_sync=true: right of image is black")

  # offset_sync=true with explicit center: center (0, 0) → top-left at (x, y)
  os_g = Sprite.new(450, 150, os_img)
  os_g.center_x = 0
  os_g.center_y = 0
  os_g.offset_sync = true
  os_g.draw
  results << assert_pixel("game", 450, 150, 0, 255, 0, "offset_sync=true, center (0,0): top-left at (x, y)")
  results << assert_pixel("game", 449, 149, 0, 0,   0, "offset_sync=true, center (0,0): outside top-left is black")

  # --- Sprite#collision_sync uses sprite center as transform origin ---
  cs_a = Sprite.new(100, 100, nil)
  cs_a.center_x = 0
  cs_a.center_y = 0
  cs_a.angle = 90
  cs_a.collision = [20, 0, 40, 10]

  cs_b = Sprite.new(92, 125, nil)
  cs_b.collision = [0, 0, 5, 5]

  results << (cs_a === cs_b ? "<span class='pass'>PASS</span> collision_sync rotates rect around sprite center" :
                              "<span class='fail'>FAIL</span> collision_sync should rotate rect around sprite center")

  cs_c = Sprite.new(100, 100, nil)
  cs_c.center_x = 0
  cs_c.center_y = 0
  cs_c.angle = 90
  cs_c.collision = [30, 0, 5]

  cs_d = Sprite.new(97, 128, nil)
  cs_d.collision = [0, 0, 5]

  results << (cs_c === cs_d ? "<span class='pass'>PASS</span> collision_sync rotates circle center around sprite center" :
                              "<span class='fail'>FAIL</span> collision_sync should rotate circle center around sprite center")

  # --- Sprite.check (shapes computed once) agrees with pairwise === ---
  mix_img = Image.new(20, 12, [255, 0, 0])
  group_a = []
  group_b = []
  12.times do |i|
    a = Sprite.new(10 + (i * 37) % 200, 10 + (i * 23) % 120, mix_img)
    a.angle   = (i * 30) % 360
    a.scale_x = i.even? ? 1.5 : -1
    a.offset_sync = (i % 3 == 0)
    a.collision = [0, 0, 6] if i % 4 == 1
    group_a << a
    b = Sprite.new(15 + (i * 29) % 200, 5 + (i * 31) % 120, mix_img)
    b.scale_y = i.odd? ? 0.5 : -2
    b.collision = [5, 5] if i % 5 == 2
    b.collision_sync = false if i % 6 == 3
    group_b << b
  end
  group_b << nil
  dead = Sprite.new(50, 50, mix_img); dead.vanish; group_b << dead
  consistent = true
  pairs = 0
  Sprite.check(group_a, group_b).each do |a, hits|
    hits.each { |b| consistent = false unless a === b }
  end
  group_a.each do |a|
    expected = group_b.select { |b| b && a === b }
    actual   = a.check(group_b)
    pairs += expected.length
    consistent = false unless expected == actual
    found = Sprite.check([a], group_b)
    consistent = false unless (found.empty? ? [] : found[0][1]) == expected
  end
  results << (consistent && pairs > 0 ? "<span class='pass'>PASS</span> Sprite.check / Sprite#check agree with === (#{pairs} hits)" :
                                        "<span class='fail'>FAIL</span> Sprite.check / Sprite#check disagree with === (#{pairs} hits)")

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

  # --- Subclass without super in initialize ---
  class NoSuperSprite < Sprite
    def initialize(img)
      # intentionally does NOT call super
      @image = img
    end
  end

  ns = NoSuperSprite.new(img)
  results << assert_equal(0,     ns.x,           "no-super subclass: x default 0")
  results << assert_equal(0,     ns.y,           "no-super subclass: y default 0")
  results << assert_equal(0,     ns.z,           "no-super subclass: z default 0")
  results << assert_equal(0,     ns.angle,       "no-super subclass: angle default 0")
  results << assert_equal(1.0,   ns.scale_x,     "no-super subclass: scale_x default 1.0")
  results << assert_equal(1.0,   ns.scale_y,     "no-super subclass: scale_y default 1.0")
  results << assert_equal(255,   ns.alpha,       "no-super subclass: alpha default 255")
  results << assert_equal(:alpha, ns.blend,      "no-super subclass: blend default :alpha")
  results << assert_equal(true,  ns.visible,     "no-super subclass: visible default true")
  results << assert_equal(false, ns.vanished?,   "no-super subclass: vanished? default false")
  results << assert_equal(false, ns.offset_sync,    "no-super subclass: offset_sync default false")
  results << assert_equal(true,  ns.collision_sync, "no-super subclass: collision_sync default true")
  results << assert_equal(nil,   ns.collision,      "no-super subclass: collision default nil")

  # draw should not raise (image is set, defaults apply)
  ns.draw
  results << assert_pixel("game", 0, 0, 255, 0, 0, "no-super subclass: draw works with defaults (center pixel)")

  # vanish works
  ns.vanish
  results << assert_equal(true, ns.vanished?, "no-super subclass: vanish sets vanished? true")

  # collision detection works with no-super subclass
  ns_a = NoSuperSprite.new(nil)
  ns_b = NoSuperSprite.new(nil)
  ns_a.x = 0;  ns_a.y = 0;  ns_a.collision = [0, 0, 20, 20]
  ns_b.x = 10; ns_b.y = 10; ns_b.collision = [0, 0, 20, 20]
  results << (ns_a === ns_b ? "<span class='pass'>PASS</span> no-super subclass: collision detection works" :
                              "<span class='fail'>FAIL</span> no-super subclass: collision detection failed")

  show_results(results)
end
