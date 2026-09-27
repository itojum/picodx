module PicoDX
  M_LBUTTON = 0
  M_RBUTTON = 1
  M_MBUTTON = 2

  K_LEFT   = "ArrowLeft"
  K_RIGHT  = "ArrowRight"
  K_UP     = "ArrowUp"
  K_DOWN   = "ArrowDown"
  K_SPACE  = "Space"
  K_ESCAPE = "Escape"
  K_RETURN = "Enter"

  K_A = "KeyA"; K_B = "KeyB"; K_C = "KeyC"; K_D = "KeyD"; K_E = "KeyE"
  K_F = "KeyF"; K_G = "KeyG"; K_H = "KeyH"; K_I = "KeyI"; K_J = "KeyJ"
  K_K = "KeyK"; K_L = "KeyL"; K_M = "KeyM"; K_N = "KeyN"; K_O = "KeyO"
  K_P = "KeyP"; K_Q = "KeyQ"; K_R = "KeyR"; K_S = "KeyS"; K_T = "KeyT"
  K_U = "KeyU"; K_V = "KeyV"; K_W = "KeyW"; K_X = "KeyX"; K_Y = "KeyY"
  K_Z = "KeyZ"

  K_0 = "Digit0"; K_1 = "Digit1"; K_2 = "Digit2"; K_3 = "Digit3"; K_4 = "Digit4"
  K_5 = "Digit5"; K_6 = "Digit6"; K_7 = "Digit7"; K_8 = "Digit8"; K_9 = "Digit9"

  K_LSHIFT   = "ShiftLeft";   K_RSHIFT   = "ShiftRight"
  K_LCONTROL = "ControlLeft"; K_RCONTROL = "ControlRight"
  K_LALT     = "AltLeft";     K_RALT     = "AltRight"

  K_TAB    = "Tab"
  K_BACK   = "Backspace"
  K_DELETE = "Delete"
  K_INSERT = "Insert"
  K_HOME   = "Home"
  K_END    = "End"
  K_PRIOR  = "PageUp"
  K_NEXT   = "PageDown"

  K_NUMPAD0 = "Numpad0"; K_NUMPAD1 = "Numpad1"; K_NUMPAD2 = "Numpad2"
  K_NUMPAD3 = "Numpad3"; K_NUMPAD4 = "Numpad4"; K_NUMPAD5 = "Numpad5"
  K_NUMPAD6 = "Numpad6"; K_NUMPAD7 = "Numpad7"; K_NUMPAD8 = "Numpad8"
  K_NUMPAD9 = "Numpad9"
  K_DECIMAL   = "NumpadDecimal"
  K_ADD       = "NumpadAdd"
  K_SUBTRACT  = "NumpadSubtract"
  K_MULTIPLY  = "NumpadMultiply"
  K_DIVIDE    = "NumpadDivide"
  K_NUMRETURN = "NumpadEnter"

  # Gamepad button constants (Gamepad API "standard" mapping)
  P_A     = 0   # A / Cross
  P_B     = 1   # B / Circle
  P_C     = 2   # X / Square
  P_D     = 3   # Y / Triangle
  P_E     = 4   # LB / L1
  P_F     = 5   # RB / R1
  P_G     = 6   # LT / L2
  P_H     = 7   # RT / R2
  P_UP    = 12  # D-pad Up
  P_DOWN  = 13  # D-pad Down
  P_LEFT  = 14  # D-pad Left
  P_RIGHT = 15  # D-pad Right
  P_START = 9   # Start / Options
  P_SELECT= 8   # Back / Select
  P_L3    = 10  # Left stick click
  P_R3    = 11  # Right stick click
  # P_BUTTON0..P_BUTTON15: DXRuby-compatible names for face/shoulder buttons.
  # Values 0-11 match the Gamepad API standard mapping.
  # P_UP/DOWN/LEFT/RIGHT map to Gamepad API D-pad buttons (12-15); note that
  # DXRuby's original numeric values for these constants differ (POV-hat based)
  # but the named constants work correctly in ported code. See docs/compatibility.md.
  (0..15).each { |i| const_set("P_#{i}", i); const_set("P_BUTTON#{i}", i) }

  C_BLACK   = [0,   0,   0  ]
  C_WHITE   = [255, 255, 255]
  C_RED     = [255, 0,   0  ]
  C_GREEN   = [0,   255, 0  ]
  C_BLUE    = [0,   0,   255]
  C_YELLOW  = [255, 255, 0  ]
  C_CYAN    = [0,   255, 255]
  C_MAGENTA = [255, 0,   255]
end
