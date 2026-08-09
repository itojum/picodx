Window.init("game")

JS.document.getElementById('run').addEventListener('click') do |_e|
  results = []

  # Sound.new loads audio asynchronously via fetch + decodeAudioData.
  # The button click satisfies the browser's user-gesture requirement for AudioContext.
  snd = Sound.new("/test/sound/silence.wav")

  # --- Initial state after load ---
  results << assert_equal(false, snd.playing?,  "Sound: playing? is false after load")
  results << assert_equal(false, snd.disposed?, "Sound: disposed? is false after load")

  # --- Setter API (no error expected) ---
  snd.set_volume(128)
  results << "<span class='pass'>PASS</span> Sound#set_volume(128) does not raise"

  snd.pan = 0.5
  results << "<span class='pass'>PASS</span> Sound#pan= does not raise"

  snd.loop_count = 0
  results << "<span class='pass'>PASS</span> Sound#loop_count= 0 (infinite) does not raise"

  snd.loop_count = 1
  results << "<span class='pass'>PASS</span> Sound#loop_count= 1 does not raise"

  snd.loop_start = 0.0
  results << "<span class='pass'>PASS</span> Sound#loop_start= does not raise"

  snd.loop_end = 0.0
  results << "<span class='pass'>PASS</span> Sound#loop_end= does not raise"

  snd.start = 0.0
  results << "<span class='pass'>PASS</span> Sound#start= does not raise"

  # --- play / playing? ---
  snd.play
  results << assert_equal(true, snd.playing?, "Sound: playing? is true after play")

  # --- stop / playing? ---
  snd.stop
  results << assert_equal(false, snd.playing?, "Sound: playing? is false after stop")

  # --- play → stop → play again (no crash) ---
  snd.play
  snd.stop
  snd.play
  results << assert_equal(true, snd.playing?, "Sound: play after stop works")
  snd.stop

  # --- dispose ---
  snd.dispose
  results << assert_equal(true, snd.disposed?, "Sound#dispose sets disposed? true")

  # disposed sound ignores play
  snd.play
  results << assert_equal(false, snd.playing?, "Sound#play is no-op when disposed")

  # --- Second sound: independent instance ---
  snd2 = Sound.new("/test/sound/silence.wav")
  snd2.frequency = 880.0
  results << "<span class='pass'>PASS</span> Sound#frequency= does not raise"
  snd2.play
  results << assert_equal(true,  snd2.playing?, "Second Sound instance plays independently")
  snd2.dispose
  results << assert_equal(false, snd2.playing?, "dispose stops playing second sound")

  show_results(results)
end
