bgm = Sound.new("/test/sound/beep.wav")
bgm.set_volume(180)

status = "Press Enter to play sound (simulates camp game BGM trigger)"

Window.init("game")

Window.loop do
  Window.draw_font(10, 10, status, [200, 200, 200], 12)

  if Input.key_push?(K_RETURN)
    bgm.play
    status = "Enter pressed → Sound#play called"
  end

  if Input.key_push?(K_SPACE)
    bgm.stop
    status = "Space pressed → Sound#stop called"
  end

  if Input.key_push?(K_ESCAPE)
    break
  end
end
