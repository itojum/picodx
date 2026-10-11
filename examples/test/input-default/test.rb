Window.init("game")

# Dispatches a cancelable keydown on `target` and returns whether it was prevented.
def keydown_prevented?(code, target = "document", modifiers = "")
  JS.eval(
    "(() => {" \
    " const ev = new KeyboardEvent('keydown', { code: '#{code}', bubbles: true, cancelable: true #{modifiers} });" \
    " #{target}.dispatchEvent(ev);" \
    " return ev.defaultPrevented;" \
    "})()"
  ).to_s == "true"
end

JS.document.getElementById('run').addEventListener('click') do |_e|
  results = []
  canvas = "document.getElementById('game')"

  results << assert_equal(true, Input.prevent_default, "Input.prevent_default defaults to true")
  results << assert_equal(0, JS.eval("#{canvas}.tabIndex").to_i, "game canvas is focusable (tabIndex 0)")

  # Keys are only suppressed while the game canvas has focus
  JS.eval("#{canvas}.focus()")
  %w[ArrowUp ArrowDown ArrowLeft ArrowRight Space Tab PageDown].each do |code|
    results << assert_equal(true, keydown_prevented?(code, canvas), "#{code} keydown on the focused canvas is prevented")
  end
  results << assert_equal(false, keydown_prevented?("KeyA", canvas), "KeyA keydown is not prevented")
  results << assert_equal(false, keydown_prevented?("F5", canvas),   "F5 keydown is not prevented")
  results << assert_equal(false, keydown_prevented?("ArrowDown", canvas, ", ctrlKey: true"), "Ctrl+ArrowDown is not prevented")

  Input.prevent_default = false
  results << assert_equal(false, Input.prevent_default, "Input.prevent_default = false")
  results << assert_equal(false, keydown_prevented?("ArrowDown", canvas), "ArrowDown is not prevented after prevent_default = false")
  Input.prevent_default = true
  results << assert_equal(true, keydown_prevented?("ArrowDown", canvas), "ArrowDown is prevented again after prevent_default = true")

  # Other page controls keep their default behaviour
  JS.eval("document.getElementById('text').focus()")
  results << assert_equal(false, keydown_prevented?("Space", "document.getElementById('text')"), "Space in a focused text input is not prevented")
  JS.eval("document.getElementById('run').focus()")
  results << assert_equal(false, keydown_prevented?("Tab", "document.getElementById('run')"), "Tab on a focused button is not prevented (no focus trap)")
  results << assert_equal(false, keydown_prevented?("Space", "document.getElementById('run')"), "Space on a focused button is not prevented")

  # Switching canvases with Window.init moves suppression / focus to the new canvas
  canvas2 = "document.getElementById('game2')"
  Window.init("game2")
  results << assert_equal("game2", JS.eval("document.activeElement.id").to_s, "Window.init(game2): new canvas is focused")
  results << assert_equal(0, JS.eval("#{canvas2}.tabIndex").to_i, "Window.init(game2): new canvas is focusable")
  results << assert_equal(true, keydown_prevented?("ArrowDown", canvas2), "Window.init(game2): keys on the new canvas are prevented")
  JS.eval("#{canvas}.focus()")
  results << assert_equal(false, keydown_prevented?("ArrowDown", canvas), "Window.init(game2): keys on the old canvas are no longer prevented")
  JS.eval("document.getElementById('text').focus()")
  JS.eval("#{canvas2}.dispatchEvent(new MouseEvent('mousedown', { bubbles: true }))")
  results << assert_equal("game2", JS.eval("document.activeElement.id").to_s, "Window.init(game2): clicking the new canvas focuses it")

  # Mouse events on the previous canvas no longer update Input
  move = lambda do |target, x, y|
    JS.eval(
      "(() => { const c = #{target}; const r = c.getBoundingClientRect();" \
      " c.dispatchEvent(new MouseEvent('mousemove', { bubbles: true, clientX: r.left + c.clientLeft + #{x}, clientY: r.top + c.clientTop + #{y} })); })()"
    )
    Window.loop { break }
  end
  # (the earlier click test left the left button down on game2; release it first)
  JS.eval("#{canvas2}.dispatchEvent(new MouseEvent('mouseup', { bubbles: true, button: 0 }))")
  move.call(canvas2, 31, 21)
  # synthetic clientX/Y are rounded while the canvas may sit at a fractional position
  new_pos = [Input.mouse_x, Input.mouse_y]
  results << ((new_pos[0] - 31).abs <= 1 && (new_pos[1] - 21).abs <= 1 ?
              "<span class='pass'>PASS</span> Window.init(game2): mouse on the new canvas updates Input" :
              "<span class='fail'>FAIL</span> Window.init(game2): mouse on the new canvas did not update Input: #{new_pos.inspect}")
  move.call(canvas, 101, 41)
  results << assert_equal(new_pos, [Input.mouse_x, Input.mouse_y], "Window.init(game2): mouse on the old canvas is ignored")
  JS.eval("#{canvas}.dispatchEvent(new MouseEvent('mousedown', { bubbles: true, button: 0 }))")
  Window.loop { break }
  results << assert_equal(false, Input.mouse_down?(M_LBUTTON), "Window.init(game2): mouse buttons on the old canvas are ignored")

  # Switching back re-targets the first canvas without registering its listeners twice
  Window.init("game")
  results << assert_equal(true, keydown_prevented?("ArrowDown", canvas), "Window.init(game) again: keys on the first canvas are prevented")
  results << assert_equal(1, JS.eval("#{canvas}.__picodx_input_id").to_i, "Window.init(game) again: canvas keeps its input id (listeners registered once)")

  show_results(results)
end
