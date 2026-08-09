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

  results << assert_equal('Digit0', K_0, "K_0")
  results << assert_equal('Digit9', K_9, "K_9")

  results << assert_equal('ShiftLeft',    K_LSHIFT,   "K_LSHIFT")
  results << assert_equal('ShiftRight',   K_RSHIFT,   "K_RSHIFT")
  results << assert_equal('ControlLeft',  K_LCONTROL, "K_LCONTROL")
  results << assert_equal('ControlRight', K_RCONTROL, "K_RCONTROL")
  results << assert_equal('AltLeft',      K_LALT,     "K_LALT")
  results << assert_equal('AltRight',     K_RALT,     "K_RALT")

  results << assert_equal('Tab',      K_TAB,    "K_TAB")
  results << assert_equal('Backspace', K_BACK,   "K_BACK")
  results << assert_equal('Delete',   K_DELETE, "K_DELETE")
  results << assert_equal('Insert',   K_INSERT, "K_INSERT")
  results << assert_equal('Home',     K_HOME,   "K_HOME")
  results << assert_equal('End',      K_END,    "K_END")
  results << assert_equal('PageUp',   K_PRIOR,  "K_PRIOR")
  results << assert_equal('PageDown', K_NEXT,   "K_NEXT")

  results << assert_equal('Numpad0',        K_NUMPAD0,  "K_NUMPAD0")
  results << assert_equal('Numpad9',        K_NUMPAD9,  "K_NUMPAD9")
  results << assert_equal('NumpadDecimal',  K_DECIMAL,  "K_DECIMAL")
  results << assert_equal('NumpadAdd',      K_ADD,      "K_ADD")
  results << assert_equal('NumpadSubtract', K_SUBTRACT, "K_SUBTRACT")
  results << assert_equal('NumpadMultiply', K_MULTIPLY, "K_MULTIPLY")
  results << assert_equal('NumpadDivide',   K_DIVIDE,   "K_DIVIDE")
  results << assert_equal('NumpadEnter',    K_NUMRETURN,"K_NUMRETURN")

  show_results(results)
end
