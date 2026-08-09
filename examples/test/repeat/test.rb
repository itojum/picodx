Window.init("game")
Window.bgcolor = [20, 20, 40]

PRESETS = [
  [0,  0,  "set_repeat(0, 0)  — disabled (default)"],
  [15, 5,  "set_repeat(15, 5) — DXRuby default"],
  [10, 3,  "set_repeat(10, 3) — fast repeat"],
  [30, 1,  "set_repeat(30, 1) — long wait, every frame"],
]

preset_idx = 0
Input.set_repeat(*PRESETS[preset_idx][0..1])

push_count  = 0
hold_frames = 0
bar_width   = 0

Window.loop do
  # switch preset with 1-4
  PRESETS.each_with_index do |(ini, rep, _), i|
    if Input.key_push?("Digit#{i + 1}")
      preset_idx = i
      Input.set_repeat(ini, rep)
      push_count  = 0
      hold_frames = 0
    end
  end

  if Input.key_down?(K_SPACE)
    hold_frames += 1
    push_count  += 1 if Input.key_push?(K_SPACE)
  else
    hold_frames = 0
  end

  bar_width = [hold_frames * 2, 600].min

  ini, rep, label = PRESETS[preset_idx]

  Window.draw_font(20, 20,  "Press 1-4 to switch preset:", [160, 160, 160])
  PRESETS.each_with_index do |(_, _, l), i|
    color = i == preset_idx ? [80, 210, 255] : [80, 80, 80]
    Window.draw_font(20, 40 + i * 18, "#{i + 1}: #{l}", color, 13)
  end

  Window.draw_font(20, 130, "Active: #{label}", [255, 220, 80])
  Window.draw_font(20, 150, "  initial=#{ini}  interval=#{rep}", [200, 200, 200], 13)

  Window.draw_font(20, 185, "Hold SPACE — watch push_count climb with repeat:", [160, 160, 160])
  Window.draw_box_fill(20, 205, 20 + bar_width, 225, [40, 80, 40])
  Window.draw_font(20, 230, "hold_frames: #{hold_frames}", [120, 255, 120])
  Window.draw_font(20, 250, "push_count:  #{push_count}", [80, 210, 255])

  Window.draw_font(20, 295, "key_push? fires on first press, then after initial frames,", [60, 60, 60], 13)
  Window.draw_font(20, 311, "then every interval frames while held.", [60, 60, 60], 13)
  Window.draw_font(20, 327, "push_count stays 1 if repeat is disabled (0, 0).", [60, 60, 60], 13)
end
