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

  C_BLACK   = [0,   0,   0  ]
  C_WHITE   = [255, 255, 255]
  C_RED     = [255, 0,   0  ]
  C_GREEN   = [0,   255, 0  ]
  C_BLUE    = [0,   0,   255]
  C_YELLOW  = [255, 255, 0  ]
  C_CYAN    = [0,   255, 255]
  C_MAGENTA = [255, 0,   255]

  # ゲームパッドボタン定数（Gamepad API のボタンインデックス対応）
  P_BUTTON1  =  0; P_BUTTON2  =  1; P_BUTTON3  =  2; P_BUTTON4  =  3
  P_BUTTON5  =  4; P_BUTTON6  =  5; P_BUTTON7  =  6; P_BUTTON8  =  7
  P_BUTTON9  =  8; P_BUTTON10 =  9; P_BUTTON11 = 10; P_BUTTON12 = 11
  P_BUTTON13 = 12; P_BUTTON14 = 13; P_BUTTON15 = 14; P_BUTTON16 = 15
  P_BUTTON17 = 16; P_BUTTON18 = 17; P_BUTTON19 = 18; P_BUTTON20 = 19

  # 標準的なゲームパッドのボタンエイリアス（Standard Gamepad Layout）
  P_A     =  0  # A / Cross
  P_B     =  1  # B / Circle
  P_X     =  2  # X / Square
  P_Y     =  3  # Y / Triangle
  P_L     =  4  # L1 / LB
  P_R     =  5  # R1 / RB
  P_L2    =  6  # L2 / LT
  P_R2    =  7  # R2 / RT
  P_SELECT = 8  # Select / Back
  P_START  = 9  # Start / Menu
  P_UP    = 12  # D-Pad Up
  P_DOWN  = 13  # D-Pad Down
  P_LEFT  = 14  # D-Pad Left
  P_RIGHT = 15  # D-Pad Right
end
