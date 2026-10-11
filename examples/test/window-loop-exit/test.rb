Window.init("game")

def looping?
  Window.instance_variable_get(:@looping) == true
end

def return_from_loop
  Window.loop { return 7 }
  :not_reached
end

def return_from_nested_loop
  Window.loop do
    Window.loop { return 99 }
    break
  end
  :not_reached
end

JS.document.getElementById('run').addEventListener('click') do |_e|
  results = []

  # --- top-level Window.loop ---
  results << assert_equal(nil, Window.loop { break }, "top-level: break returns nil")
  results << assert_equal(false, looping?, "top-level: state is reset after break")
  results << assert_equal(5, Window.loop { break 5 }, "top-level: break value is returned")
  results << assert_equal(7, return_from_loop, "top-level: return leaves the enclosing method with its value")
  results << assert_equal(false, looping?, "top-level: state is reset after return")

  raised = nil
  begin
    Window.loop { raise "boom" }
  rescue => e
    raised = e.message
  end
  results << assert_equal("boom", raised, "top-level: exceptions propagate out of Window.loop")
  results << assert_equal(false, looping?, "top-level: state is reset after an exception")
  results << assert_equal(1, Window.loop { break 1 }, "top-level: Window.loop works again after an exception")

  # --- nested Window.loop ---
  inner = nil
  outer = Window.loop do
    inner = Window.loop { break 42 }
    break 43
  end
  results << assert_equal(42, inner, "nested: inner break value is returned by the inner loop")
  results << assert_equal(43, outer, "nested: outer break value is returned by the outer loop")
  results << assert_equal(99, return_from_nested_loop, "nested: return leaves the enclosing method with its value")
  results << assert_equal(false, looping?, "nested: state is reset after the outer loop exits")

  show_results(results)
end
