require_relative '../support/e2e'

RSpec.describe 'Window', :e2e do
  include_context 'browser'

  it 'bgcolor fills canvas each frame' do
    load_ruby(<<~RUBY)
      Window.init("game")
      Window.bgcolor = [255, 0, 0]
      Window.loop { }
    RUBY

    page.wait_for_function(<<~JS, timeout: 15_000)
      () => {
        const p = document.getElementById('game').getContext('2d').getImageData(320, 240, 1, 1).data;
        return p[0] === 255 && p[1] === 0 && p[2] === 0 && p[3] === 255;
      }
    JS
  end

  it 'draw_box_fill renders a filled rectangle' do
    load_ruby(<<~RUBY)
      Window.init("game")
      Window.loop do
        Window.draw_box_fill(10, 10, 110, 110, [0, 255, 0])
      end
    RUBY

    page.wait_for_function(<<~JS, timeout: 15_000)
      () => {
        const p = document.getElementById('game').getContext('2d').getImageData(60, 60, 1, 1).data;
        return p[0] === 0 && p[1] === 255 && p[2] === 0 && p[3] === 255;
      }
    JS
  end
end
