require_relative '../support/e2e'

RSpec.describe 'Input', :e2e do
  include_context 'browser'

  it 'key_down? detects a held key' do
    load_ruby(<<~RUBY)
      Window.init("game")
      Window.loop do
        if Input.key_down?(K_LEFT)
          Window.draw_box_fill(0, 0, 10, 10, [255, 0, 0])
        end
      end
    RUBY

    # WASMが起動して最初のフレームが描画されるまで待つ
    page.wait_for_function(<<~JS, timeout: 15_000)
      () => document.getElementById('game').getContext('2d').getImageData(320, 240, 1, 1).data[3] > 0
    JS

    page.keyboard.down('ArrowLeft')

    page.wait_for_function(<<~JS, timeout: 5_000)
      () => {
        const p = document.getElementById('game').getContext('2d').getImageData(5, 5, 1, 1).data;
        return p[0] === 255 && p[1] === 0 && p[2] === 0 && p[3] === 255;
      }
    JS

    page.keyboard.up('ArrowLeft')
  end
end
