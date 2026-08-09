JS.document.getElementById('run').addEventListener('click') do |_e|
  results = []

  results << assert_equal([0,   0,   0  ], C_BLACK,   "C_BLACK")
  results << assert_equal([255, 255, 255], C_WHITE,   "C_WHITE")
  results << assert_equal([255, 0,   0  ], C_RED,     "C_RED")
  results << assert_equal([0,   255, 0  ], C_GREEN,   "C_GREEN")
  results << assert_equal([0,   0,   255], C_BLUE,    "C_BLUE")
  results << assert_equal([255, 255, 0  ], C_YELLOW,  "C_YELLOW")
  results << assert_equal([0,   255, 255], C_CYAN,    "C_CYAN")
  results << assert_equal([255, 0,   255], C_MAGENTA, "C_MAGENTA")

  show_results(results)
end
