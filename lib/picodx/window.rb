module PicoDX
  class Window
    class << self
      attr_reader :width, :height

      def init(canvas_id)
        @canvas  = JS.document.getElementById(canvas_id)
        @ctx     = @canvas.getContext('2d')
        @width   = @canvas[:width].to_i
        @height  = @canvas[:height].to_i
        @bgcolor = [0, 0, 0]
        JS.eval("window.__picodx_nextFrame = () => new Promise(resolve => requestAnimationFrame(resolve))")
        Input.setup
      end

      def bgcolor=(color)
        @bgcolor = color
      end

      def loop(&block)
        @user_block = block
        while true
          JS.global.__picodx_nextFrame().await
          _tick
        end
      end

      def draw(x, y, image)
        @ctx[:fillStyle] = _css(image.color)
        @ctx.fillRect(x, y, image.width, image.height)
      end

      def draw_box(x1, y1, x2, y2, color)
        @ctx[:strokeStyle] = _css(color)
        @ctx.strokeRect(x1, y1, x2 - x1, y2 - y1)
      end

      def draw_box_fill(x1, y1, x2, y2, color)
        @ctx[:fillStyle] = _css(color)
        @ctx.fillRect(x1, y1, x2 - x1, y2 - y1)
      end

      def draw_font(x, y, str, color, size = 16)
        @ctx[:fillStyle] = _css(color)
        @ctx[:font] = "#{size}px monospace"
        @ctx[:textBaseline] = 'top'
        @ctx.fillText(str, x, y)
      end

      private

      def _tick
        Input._update
        @ctx[:fillStyle] = _css(@bgcolor)
        @ctx.fillRect(0, 0, @width, @height)
        @user_block.call
      end

      def _css(color)
        r, g, b, a = color
        if a
          "rgba(#{r},#{g},#{b},#{a.to_f / 255})"
        else
          "rgb(#{r},#{g},#{b})"
        end
      end
    end
  end
end
