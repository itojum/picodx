Window.init("game")

JS.document.getElementById('run').addEventListener('click') do |_e|
  results = []

  snd = Sound.new("/test/sound/beep.wav")

  # --- Initial state ---
  results << assert_equal(false, snd.playing?,  "Sound: playing? is false after load")
  results << assert_equal(false, snd.disposed?, "Sound: disposed? is false after load")

  # --- Setter API (no playback) ---
  snd.set_volume(200)
  results << "<span class='pass'>PASS</span> Sound#set_volume does not raise"

  snd.pan = 0.0
  results << "<span class='pass'>PASS</span> Sound#pan= does not raise"

  snd.loop_count = 1
  results << "<span class='pass'>PASS</span> Sound#loop_count= does not raise"

  snd.loop_start = 0.0
  results << "<span class='pass'>PASS</span> Sound#loop_start= does not raise"

  snd.loop_end = 0.0
  results << "<span class='pass'>PASS</span> Sound#loop_end= does not raise"

  snd.start = 0.0
  results << "<span class='pass'>PASS</span> Sound#start= does not raise"

  # --- play / stop ---
  snd.play
  results << assert_equal(true, snd.playing?, "Sound: playing? true after play")
  snd.stop
  results << assert_equal(false, snd.playing?, "Sound: playing? false after stop")

  # --- dispose ---
  snd.dispose
  results << assert_equal(true, snd.disposed?, "Sound#dispose sets disposed? true")
  snd.play
  results << assert_equal(false, snd.playing?, "Sound#play is no-op when disposed")

  show_results(results)

  # Audible check: load fresh, play once at full volume, let it finish naturally (0.5 s)
  beep = Sound.new("/test/sound/beep.wav")
  beep.set_volume(30)
  beep.pan = 0.0
  beep.play
end
