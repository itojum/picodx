# PicoDX / DXRuby 見比べ用スクリプト
#
# 同じスクリプトを PicoDX（ブラウザ）と DXRuby（Windows）で動かし、
# スクリーンショットを並べて挙動の差を確認する。
#   PicoDX : npm run serve → http://localhost:3000/compare/
#   DXRuby : ruby -rdxruby compare.rb
#
# 白い十字は各 Sprite の (x, y)。点の格子は、その位置に置いた点の Sprite
# （collision = [0, 0]）が === で当たった場所＝実際の判定範囲を表す。

Window.width  = 640
Window.height = 480
Window.caption = "PicoDX / DXRuby compare"

FONT  = Font.new(14)
SMALL = Font.new(12)

def label(x, y, str)
  Window.draw_font(x, y, str, SMALL, :color => [255, 200, 200, 200])
end

def cross(x, y)
  Window.draw_line(x - 6, y, x + 6, y, [255, 255, 255, 255])
  Window.draw_line(x, y - 6, x, y + 6, [255, 255, 255, 255])
end

# 向きが分かるよう、左端と上端に色を付けた画像
def marked_image(w, h, color)
  img = Image.new(w, h, color)
  img.box_fill(0, 0, 7, h - 1, [255, 255, 255, 0])   # 左端: 黄
  img.box_fill(0, 0, w - 1, 3, [255, 0, 255, 255])   # 上端: 水色
  img
end

# Sprite の判定範囲を、点の Sprite を格子状に並べて調べる
def hit_points(sprite, x1, y1, x2, y2, step = 3)
  probe = Sprite.new(0, 0)
  probe.collision = [0, 0]
  points = []
  y = y1
  while y <= y2
    x = x1
    while x <= x2
      probe.x = x
      probe.y = y
      points << [x, y] if probe === sprite
      x += step
    end
    y += step
  end
  points
end

# --- 1 段目: offset_sync と描画位置 ---------------------------------------
img = marked_image(48, 32, [255, 200, 60, 60])

s_off = Sprite.new(70, 60, img)                      # offset_sync = false: (x, y) が左上
s_on  = Sprite.new(250, 76, img)                     # offset_sync = true: 中心が (x, y)
s_on.offset_sync = true
s_on0 = Sprite.new(400, 60, img)                     # offset_sync = true, 中心 (0, 0)
s_on0.offset_sync = true
s_on0.center_x = 0
s_on0.center_y = 0
row1 = [s_off, s_on, s_on0]

# --- 2 段目: collision_sync（拡縮・反転・回転と判定範囲） ------------------
img2 = marked_image(40, 24, [255, 60, 120, 220])
s_scale = Sprite.new(50, 190, img2);  s_scale.scale_x = 1.5; s_scale.scale_y = 1.5
s_flip  = Sprite.new(170, 190, img2); s_flip.scale_x = -1
s_rot90 = Sprite.new(290, 190, img2); s_rot90.angle = 90
s_rot30 = Sprite.new(410, 190, img2); s_rot30.angle = 30
s_nosync = Sprite.new(530, 190, img2); s_nosync.angle = 30; s_nosync.collision_sync = false
row2 = [s_scale, s_flip, s_rot90, s_rot30, s_nosync]
row2.each { |s| s.collision = [0, 0, 40, 24] }

# 判定範囲は最初に 1 回だけ調べる（毎フレームだと重いため）
hits = []
(row1 + row2).each do |s|
  hits.concat(hit_points(s, s.x - 40, s.y - 40, s.x + 80, s.y + 72))
end

# --- 3 段目: collision 未設定（画像全体が判定範囲） ------------------------
img3a = Image.new(60, 40, [255, 80, 160, 80])
img3b = Image.new(30, 30, [255, 200, 200, 200])
s_fixed  = Sprite.new(250, 330, img3a)
s_moving = Sprite.new(150, 335, img3b)
dx = 2

Window.loop do
  # 1 段目
  label(10, 10, "1. offset_sync: false / true / true + center (0,0)   (white cross = (x, y))")
  Sprite.draw(row1)
  row1.each { |s| cross(s.x, s.y) }

  # 2 段目
  label(10, 140, "2. collision_sync: scale 1.5 / scale_x -1 / angle 90 / angle 30 / angle 30 + sync off")
  Sprite.draw(row2)
  row2.each { |s| cross(s.x, s.y) }
  hits.each { |p| Window.draw_pixel(p[0], p[1], [255, 255, 255, 255]) }

  # 3 段目
  label(10, 300, "3. collision unset: the whole image is the hit area (turns red while touching)")
  s_moving.x += dx
  dx = -dx if s_moving.x < 120 || s_moving.x > 360
  hit = s_fixed === s_moving
  s_fixed.image = Image.new(60, 40, hit ? [255, 220, 40, 40] : [255, 80, 160, 80]) if hit != @last_hit
  @last_hit = hit
  Sprite.draw([s_fixed, s_moving])

  # 4 段目: z 順（呼び出し順と逆に重なる）
  label(10, 390, "4. z order: called red(z=2), green(z=1), blue(z=0) -> red on top")
  Window.draw_box_fill(40, 420, 120, 460, [255, 220, 40, 40], 2)
  Window.draw_box_fill(70, 410, 150, 450, [255, 40, 200, 40], 1)
  Window.draw_box_fill(100, 400, 180, 440, [255, 40, 80, 220], 0)
  Window.draw_font(220, 420, "font z=3 (on top of the box)", FONT, :color => [255, 255, 255, 255], :z => 3)
  Window.draw_box_fill(210, 415, 420, 440, [255, 90, 90, 90], 2)
end
