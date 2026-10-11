Window.init("game")

# Dispatches a mouse event at canvas-relative CSS offset (ox, oy) and
# returns whether the event's default action was prevented.
def dispatch_mouse(type, ox, oy, button = 0)
  JS.eval(
    "(() => {" \
    " const c = document.getElementById('game');" \
    " const r = c.getBoundingClientRect();" \
    " const ev = new MouseEvent('#{type}', { bubbles: true, cancelable: true, button: #{button}," \
    "   clientX: r.left + c.clientLeft + #{ox}, clientY: r.top + c.clientTop + #{oy} });" \
    " c.dispatchEvent(ev);" \
    " return ev.defaultPrevented;" \
    "})()"
  ).to_s == "true"
end

JS.document.getElementById('run').addEventListener('click') do |_e|
  results = []

  # 200x100 canvas displayed at 400x200 → CSS offset is halved.
  # Offsets are odd so they land mid-pixel: synthetic clientX/Y are rounded to
  # integers while the canvas may sit at a fractional page position.
  dispatch_mouse("mousemove", 101, 51)
  Window.loop { break }
  results << assert_equal(50, Input.mouse_x, "scaled canvas: mouse_x is in canvas pixels")
  results << assert_equal(25, Input.mouse_y, "scaled canvas: mouse_y is in canvas pixels")

  dispatch_mouse("mousemove", 399, 199)
  Window.loop { break }
  results << assert_equal(199, Input.mouse_x, "scaled canvas: bottom-right mouse_x")
  results << assert_equal(99,  Input.mouse_y, "scaled canvas: bottom-right mouse_y")

  # mousedown also updates the position (click without moving first)
  dispatch_mouse("mousedown", 21, 41)
  Window.loop { break }
  results << assert_equal([10, 20], [Input.mouse_x, Input.mouse_y], "mousedown updates the mouse position")
  dispatch_mouse("mouseup", 21, 41)

  results << assert_equal(true, dispatch_mouse("contextmenu", 10, 10, 2), "right click: context menu is prevented")

  show_results(results)

  # Manual check: show the current mouse position (started after the
  # assertions so it does not compete with the loops above for frames)
  Window.loop do
    Window.draw_font(4, 4, "(#{Input.mouse_x}, #{Input.mouse_y})", [255, 255, 255])
  end
end
