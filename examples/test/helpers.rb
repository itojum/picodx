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
