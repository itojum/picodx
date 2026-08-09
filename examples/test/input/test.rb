Window.init("game")
Window.bgcolor = [20, 20, 40]

ALPHA_KEYS  = ('A'..'Z').map { |c| "Key#{c}" }
DIGIT_KEYS  = [K_0, K_1, K_2, K_3, K_4, K_5, K_6, K_7, K_8, K_9]
NUMPAD_KEYS = [K_NUMPAD0, K_NUMPAD1, K_NUMPAD2, K_NUMPAD3, K_NUMPAD4,
               K_NUMPAD5, K_NUMPAD6, K_NUMPAD7, K_NUMPAD8, K_NUMPAD9,
               K_DECIMAL, K_ADD, K_SUBTRACT, K_MULTIPLY, K_DIVIDE, K_NUMRETURN]
MOD_KEYS    = [K_LSHIFT, K_RSHIFT, K_LCONTROL, K_RCONTROL, K_LALT, K_RALT]
NAV_KEYS    = [K_TAB, K_BACK, K_DELETE, K_INSERT, K_HOME, K_END, K_PRIOR, K_NEXT]
ALL_KEYS    = [K_LEFT, K_RIGHT, K_UP, K_DOWN, K_SPACE, K_ESCAPE, K_RETURN] +
              ALPHA_KEYS + DIGIT_KEYS + NUMPAD_KEYS + MOD_KEYS + NAV_KEYS

last_pushed  = "(none)"
push_flash   = 0
last_release = "(none)"
release_flash = 0

Window.loop do
  # --- key_push? ---
  ALL_KEYS.each do |k|
    if Input.key_push?(k)
      last_pushed = k
      push_flash  = 8
    end
  end
  push_flash -= 1 if push_flash > 0

  # --- key_release? ---
  ALL_KEYS.each do |k|
    if Input.key_release?(k)
      last_release  = k
      release_flash = 8
    end
  end
  release_flash -= 1 if release_flash > 0

  # --- key_down? (held) ---
  held = []
  held << "LEFT"   if Input.key_down?(K_LEFT)
  held << "RIGHT"  if Input.key_down?(K_RIGHT)
  held << "UP"     if Input.key_down?(K_UP)
  held << "DOWN"   if Input.key_down?(K_DOWN)
  held << "SPACE"  if Input.key_down?(K_SPACE)
  ('A'..'Z').each { |c| held << c if Input.key_down?("Key#{c}") }

  # --- draw ---
  if push_flash > 0
    Window.draw_box_fill(0, 0, 640, 24, [0, 80, 220])
    Window.draw_font(12, 4, "key_push? (one-shot)", [255, 255, 255], 14)
  end
  if release_flash > 0
    Window.draw_box_fill(0, 26, 640, 50, [180, 60, 0])
    Window.draw_font(12, 30, "key_release? (one-shot)", [255, 255, 255], 14)
  end

  Window.draw_font(20, 60,  "key_down? (held):", [160, 160, 160])
  Window.draw_font(20, 78,  held.empty? ? "(none)" : held.join(" + "), [255, 220, 80])

  Window.draw_font(20, 108, "key_push? last pressed:", [160, 160, 160])
  Window.draw_font(20, 126, last_pushed, [80, 210, 255])

  Window.draw_font(20, 156, "key_release? last released:", [160, 160, 160])
  Window.draw_font(20, 174, last_release, [255, 120, 80])

  # --- x / y axis ---
  ax = Input.x
  ay = Input.y
  Window.draw_font(20, 210, "Input.x / Input.y (arrow keys or WASD):", [160, 160, 160])
  Window.draw_font(20, 228, "x=#{ax}  y=#{ay}", [120, 255, 120])

  # --- mouse ---
  Window.draw_font(20, 268, "Mouse position:", [160, 160, 160])
  Window.draw_font(20, 286, "x=#{Input.mouse_x}  y=#{Input.mouse_y}", [200, 200, 255])

  btns = []
  btns << "LEFT"   if Input.mouse_down?(M_LBUTTON)
  btns << "RIGHT"  if Input.mouse_down?(M_RBUTTON)
  btns << "MIDDLE" if Input.mouse_down?(M_MBUTTON)
  Window.draw_font(20, 316, "Mouse buttons held: #{btns.empty? ? '(none)' : btns.join(', ')}", [200, 200, 255])
  Window.draw_font(20, 334, "mouse_wheel_pos: #{Input.mouse_wheel_pos}", [200, 200, 255])

  # --- hints ---
  Window.draw_font(20, 374, "Hold key      -> key_down? shows name", [60, 60, 60], 13)
  Window.draw_font(20, 390, "Tap key       -> blue bar flashes once (push)", [60, 60, 60], 13)
  Window.draw_font(20, 406, "Release key   -> orange bar flashes once (release)", [60, 60, 60], 13)
  Window.draw_font(20, 422, "Arrows/WASD   -> x/y axis changes", [60, 60, 60], 13)
  Window.draw_font(20, 438, "Mouse move    -> coordinates update", [60, 60, 60], 13)
  Window.draw_font(20, 454, "Mouse click   -> button state updates", [60, 60, 60], 13)
  Window.draw_font(20, 470, "Scroll wheel  -> mouse_wheel_pos accumulates", [60, 60, 60], 13)
end
