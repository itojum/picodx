Window.init("game")

COUNT  = 500
FRAMES = 20

def now_ms
  JS.eval("performance.now()").to_f
end

def bench(label, lines)
  yield # warm-up
  t0 = now_ms
  FRAMES.times { yield }
  ms = (now_ms - t0) / FRAMES
  lines << "#{label}: #{(ms * 100).round / 100.0} ms/frame"
end

JS.document.getElementById('run').addEventListener('click') do |_e|
  lines = ["#{COUNT} objects, #{FRAMES} frames each", ""]
  img = Image.new(16, 16, [255, 255, 128, 0])

  on_screen  = []
  off_screen = []
  COUNT.times do |i|
    on_screen  << [(i * 37) % 620, (i * 53) % 460]
    off_screen << [700 + (i * 37) % 620, (i * 53) % 460]
  end

  bench("draw_ex (no transform, on screen)", lines) do
    on_screen.each { |p| Window.draw_ex(p[0], p[1], img) }
  end
  bench("draw_ex (alpha 255 / blend :alpha, on screen)", lines) do
    on_screen.each { |p| Window.draw_ex(p[0], p[1], img, { alpha: 255, blend: :alpha }) }
  end
  bench("draw_ex (angle 30, scale 1.5, on screen)", lines) do
    on_screen.each { |p| Window.draw_ex(p[0], p[1], img, { angle: 30, scale_x: 1.5, scale_y: 1.5 }) }
  end
  bench("draw_ex (no transform, off screen)", lines) do
    off_screen.each { |p| Window.draw_ex(p[0], p[1], img) }
  end
  bench("draw_ex (angle 30, off screen)", lines) do
    off_screen.each { |p| Window.draw_ex(p[0], p[1], img, { angle: 30 }) }
  end

  sprites = on_screen.map { |p| Sprite.new(p[0], p[1], img) }
  bench("Sprite.draw (#{COUNT} sprites)", lines) do
    Sprite.draw(sprites)
  end

  shots   = sprites[0, 50]
  bench("Sprite.check (50 x #{COUNT}, image collision)", lines) do
    Sprite.check(shots, sprites)
  end
  boxed = on_screen.map { |p| s = Sprite.new(p[0], p[1], img); s.collision = [0, 0, 16, 16]; s }
  bench("Sprite.check (50 x #{COUNT}, rect collision)", lines) do
    Sprite.check(boxed[0, 50], boxed)
  end

  JS.document.getElementById('test-output')[:innerText] = lines.join("\n")
end
