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

  # Switching back re-targets the first canvas without registering its listeners twice
  Window.init("game")
  results << assert_equal(true, keydown_prevented?("ArrowDown", canvas), "Window.init(game) again: keys on the first canvas are prevented")
  results << assert_equal(true, JS.eval("#{canvas}.__picodx_input === true").to_s == "true", "Window.init(game) again: canvas listeners are registered once (marker kept)")

  show_results(results)
end
