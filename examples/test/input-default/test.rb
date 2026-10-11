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

  results << assert_equal(true, Input.prevent_default, "Input.prevent_default defaults to true")

  %w[ArrowUp ArrowDown ArrowLeft ArrowRight Space Tab PageDown].each do |code|
    results << assert_equal(true, keydown_prevented?(code), "#{code} keydown is prevented")
  end
  results << assert_equal(false, keydown_prevented?("KeyA"),  "KeyA keydown is not prevented")
  results << assert_equal(false, keydown_prevented?("F5"),    "F5 keydown is not prevented")
  results << assert_equal(false, keydown_prevented?("ArrowDown", "document", ", ctrlKey: true"), "Ctrl+ArrowDown is not prevented")
  results << assert_equal(false, keydown_prevented?("Space", "document.getElementById('text')"), "Space in a text input is not prevented")

  Input.prevent_default = false
  results << assert_equal(false, Input.prevent_default, "Input.prevent_default = false")
  results << assert_equal(false, keydown_prevented?("ArrowDown"), "ArrowDown is not prevented after prevent_default = false")
  Input.prevent_default = true
  results << assert_equal(true, keydown_prevented?("ArrowDown"), "ArrowDown is prevented again after prevent_default = true")

  show_results(results)
end
