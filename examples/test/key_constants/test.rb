JS.document.getElementById('run').addEventListener('click') do |_e|
  results = []

  results << assert_equal('ArrowLeft',  K_LEFT,   "K_LEFT")
  results << assert_equal('ArrowRight', K_RIGHT,  "K_RIGHT")
  results << assert_equal('ArrowUp',    K_UP,     "K_UP")
  results << assert_equal('ArrowDown',  K_DOWN,   "K_DOWN")
  results << assert_equal('Space',      K_SPACE,  "K_SPACE")
  results << assert_equal('Escape',     K_ESCAPE, "K_ESCAPE")
  results << assert_equal('Enter',      K_RETURN, "K_RETURN")
  results << assert_equal('KeyA',       K_A,      "K_A")
  results << assert_equal('KeyZ',       K_Z,      "K_Z")

  show_results(results)
end
