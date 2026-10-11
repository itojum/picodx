# No Window.init on this page. Settings made before the first draw /
# Window.loop must survive the automatic connection.
Window.width   = 240
Window.bgcolor = [0, 0, 128]
Window.fps     = 30

JS.document.getElementById('run').addEventListener('click') do |_e|
  results = []

  results << assert_equal(200, JS.document.getElementById("game")[:width].to_i, "before connecting: #game keeps its HTML width")

  Window.loop do
    Window.draw_box_fill(10, 10, 30, 30, [255, 0, 0])
    break
  end

  results << assert_equal(240, Window.width,  "auto init: Window.width= set before connecting is applied")
  results << assert_equal(120, Window.height, "auto init: Window.height read from #game")
  results << assert_equal(240, JS.document.getElementById("game")[:width].to_i,  "auto init: #game DOM width updated")
  results << assert_equal(100, JS.document.getElementById("other")[:width].to_i, "auto init: first canvas (#other) untouched")
  results << assert_equal(30,  Window.fps, "auto init: Window.fps= set before connecting is kept")
  results << assert_equal([0, 0, 128], Window.bgcolor, "auto init: Window.bgcolor= set before connecting is kept")
  results << assert_pixel("game", 20, 20, 255, 0, 0, "auto init: Window.loop draws on #game")
  results << assert_pixel("game", 100, 100, 0, 0, 128, "auto init: background uses bgcolor set before connecting")

  show_results(results)
end
