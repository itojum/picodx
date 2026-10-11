# No Window.init and no #game on this page.
JS.document.getElementById('run').addEventListener('click') do |_e|
  results = []

  # Drawing outside Window.loop connects immediately
  Window.draw_box_fill(0, 0, 10, 10, [0, 255, 0])

  canvas = JS.document.querySelector("canvas")
  results << assert_equal("picodx-game", canvas[:id].to_s, "auto init: id is assigned to the first canvas")
  results << assert_equal(120, Window.width,  "auto init: Window.width read from the first canvas")
  results << assert_equal(60,  Window.height, "auto init: Window.height read from the first canvas")
  results << assert_pixel("picodx-game", 5, 5, 0, 255, 0, "auto init: draw outside Window.loop renders immediately")

  show_results(results)
end
