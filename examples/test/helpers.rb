def assert_equal(expected, actual, label)
  if expected == actual
    "<span class='pass'>PASS</span> #{label}"
  else
    "<span class='fail'>FAIL</span> #{label}\n  expected: #{expected.inspect}\n  actual:   #{actual.inspect}"
  end
end

def assert_pixel(canvas_id, x, y, er, eg, eb, label)
  r = JS.eval("document.getElementById('#{canvas_id}').getContext('2d').getImageData(#{x},#{y},1,1).data[0]").to_i
  g = JS.eval("document.getElementById('#{canvas_id}').getContext('2d').getImageData(#{x},#{y},1,1).data[1]").to_i
  b = JS.eval("document.getElementById('#{canvas_id}').getContext('2d').getImageData(#{x},#{y},1,1).data[2]").to_i
  if r == er && g == eg && b == eb
    "<span class='pass'>PASS</span> #{label}"
  else
    "<span class='fail'>FAIL</span> #{label}\n  expected: rgb(#{er},#{eg},#{eb})\n  actual:   rgb(#{r},#{g},#{b})"
  end
end

# Like assert_pixel, but allows each channel to differ by up to `tolerance`
# (blending and alpha are subject to rounding).
def assert_pixel_near(canvas_id, x, y, er, eg, eb, tolerance, label)
  data = "document.getElementById('#{canvas_id}').getContext('2d').getImageData(#{x},#{y},1,1).data"
  r = JS.eval("#{data}[0]").to_i
  g = JS.eval("#{data}[1]").to_i
  b = JS.eval("#{data}[2]").to_i
  if (r - er).abs <= tolerance && (g - eg).abs <= tolerance && (b - eb).abs <= tolerance
    "<span class='pass'>PASS</span> #{label}"
  else
    "<span class='fail'>FAIL</span> #{label}\n  expected: rgb(#{er},#{eg},#{eb}) ±#{tolerance}\n  actual:   rgb(#{r},#{g},#{b})"
  end
end

# Like assert_equal for numbers, but allows a difference of up to `tolerance`.
# Canvas stores semi-transparent pixels premultiplied by alpha, so their R/G/B
# can come back off by one (see docs/image.md).
def assert_near(expected, actual, tolerance, label)
  if (expected - actual).abs <= tolerance
    "<span class='pass'>PASS</span> #{label}"
  else
    "<span class='fail'>FAIL</span> #{label}\n  expected: #{expected} ±#{tolerance}\n  actual:   #{actual}"
  end
end

def show_results(results)
  pass_count = 0
  fail_count = 0
  results.each do |r|
    if r.include?("PASS")
      pass_count += 1
    else
      fail_count += 1
    end
  end
  summary = "<b>#{pass_count} passed, #{fail_count} failed</b>\n\n"
  JS.document.getElementById('test-output').innerHTML = summary + results.join("\n")
end
