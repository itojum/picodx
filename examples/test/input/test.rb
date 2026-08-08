Window.init("game")
Window.bgcolor = [20, 20, 40]

ALPHA_KEYS = ('A'..'Z').map { |c| "Key#{c}" }

last_pushed = "(none)"
push_flash  = 0

Window.loop do
  held = []
  held << "LEFT"   if Input.key_down?(K_LEFT)
  held << "RIGHT"  if Input.key_down?(K_RIGHT)
  held << "UP"     if Input.key_down?(K_UP)
  held << "DOWN"   if Input.key_down?(K_DOWN)
  held << "SPACE"  if Input.key_down?(K_SPACE)
  held << "ESCAPE" if Input.key_down?(K_ESCAPE)
  held << "RETURN" if Input.key_down?(K_RETURN)
  ('A'..'Z').each { |c| held << c if Input.key_down?("Key#{c}") }

  ([K_LEFT, K_RIGHT, K_UP, K_DOWN, K_SPACE, K_ESCAPE, K_RETURN] + ALPHA_KEYS).each do |k|
    if Input.key_push?(k)
      last_pushed = k
      push_flash  = 8
    end
  end

  push_flash -= 1 if push_flash > 0

  if push_flash > 0
    Window.draw_box_fill(0, 0, 640, 24, [0, 80, 220])
    Window.draw_font(12, 4, "key_push! (one-shot)", [255, 255, 255], 14)
  end

  Window.draw_font(20, 40,  "key_down? (held):", [160, 160, 160])
  Window.draw_font(20, 62,  held.empty? ? "(none)" : held.join(" + "), [255, 220, 80])

  Window.draw_font(20, 110, "key_push? last pressed:", [160, 160, 160])
  Window.draw_font(20, 132, last_pushed, [80, 210, 255])

  Window.draw_font(20, 195, "Hold key  -> key_down? shows name while held", [80, 80, 80], 13)
  Window.draw_font(20, 212, "Tap key   -> blue bar flashes ONCE, last_pushed updates", [80, 80, 80], 13)
  Window.draw_font(20, 229, "Hold key  -> blue bar does NOT keep flashing (one-shot confirmed)", [80, 80, 80], 13)
  Window.draw_font(20, 265, "Keys: Arrows / Space / Escape / Enter / A-Z", [60, 60, 60], 13)
end
