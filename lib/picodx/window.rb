module PicoDX
  class Window
    class << self
      attr_reader :width, :height, :fps, :real_fps, :ox, :oy, :bgcolor

      def init(canvas_id)
        @canvas   = JS.document.getElementById(canvas_id)
        @ctx      = @canvas.getContext('2d', JS.eval("({willReadFrequently: true})"))
        @width    = @canvas[:width].to_i
        @height   = @canvas[:height].to_i
        @bgcolor  = [0, 0, 0]
        @fps      = 60
        @real_fps = 0.0
        @ox       = 0
        @oy       = 0
        JS.eval("window.__picodx_nextFrame = () => new Promise(resolve => requestAnimationFrame(resolve))")
        Input.setup(@canvas)
      end

      def bgcolor=(color)
        @bgcolor = color
      end

      def fps=(value)
        @fps = value
      end

      def ox=(value)
        @ox = value
      end

      def oy=(value)
        @oy = value
      end

      def running_time
        return 0 unless @loop_start_time
        (JS.eval("performance.now()").to_f - @loop_start_time).to_i
      end

      def loop(&block)
        @user_block        = block
        @loop_start_time   = nil
        @last_tick_time    = nil
        @last_process_time = nil
        @accumulated       = 0.0
        @real_fps          = 0.0
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
        @ctx.save
        @ctx[:fillStyle] = _css(color)
        @ctx[:font] = "#{size}px monospace"
        @ctx[:textBaseline] = 'top'
        @ctx.fillText(str, x, y)
        @ctx.restore
      end

      def draw_line(x1, y1, x2, y2, color)
        @ctx.beginPath
        @ctx[:strokeStyle] = _css(color)
        @ctx.moveTo(x1, y1)
        @ctx.lineTo(x2, y2)
        @ctx.stroke
      end

      def draw_pixel(x, y, color)
        @ctx[:fillStyle] = _css(color)
        @ctx.fillRect(x, y, 1, 1)
      end

      def draw_circle(x, y, r, color)
        @ctx.beginPath
        @ctx[:strokeStyle] = _css(color)
        @ctx.arc(x, y, r, 0, 6.283185307179586)
        @ctx.stroke
      end

      def draw_circle_fill(x, y, r, color)
        @ctx.beginPath
        @ctx[:fillStyle] = _css(color)
        @ctx.arc(x, y, r, 0, 6.283185307179586)
        @ctx.fill
      end

      def draw_scale(x, y, image, scale_x, scale_y)
        @ctx.save
        @ctx.translate(x, y)
        @ctx.scale(scale_x, scale_y)
        _draw_image_at_origin(image)
        @ctx.restore
      end

      def draw_rot(x, y, image, angle, cx = 0, cy = 0)
        rad = angle * Math::PI / 180.0
        @ctx.save
        @ctx.translate(x, y)
        @ctx.rotate(rad)
        _draw_image_at_origin(image, -cx, -cy)
        @ctx.restore
      end

      def draw_alpha(x, y, image, alpha)
        @ctx.save
        @ctx[:globalAlpha] = alpha.to_f / 255
        draw(x, y, image)
        @ctx.restore
      end

      def draw_ex(x, y, image, options = {})
        angle   = options[:angle]   || 0
        scale_x = options[:scale_x] || 1.0
        scale_y = options[:scale_y] || 1.0
        alpha   = options[:alpha]
        cx      = options[:cx]      || 0
        cy      = options[:cy]      || 0
        rad = angle * Math::PI / 180.0
        @ctx.save
        @ctx[:globalAlpha] = alpha.to_f / 255 if alpha
        @ctx.translate(x, y)
        @ctx.rotate(rad)
        @ctx.scale(scale_x, scale_y)
        _draw_image_at_origin(image, -cx, -cy)
        @ctx.restore
      end

      private

      def _draw_image_at_origin(image, dx = 0, dy = 0)
        @ctx[:fillStyle] = _css(image.color)
        @ctx.fillRect(dx, dy, image.width, image.height)
      end

      def _tick
        now = JS.eval("performance.now()").to_f
        @loop_start_time ||= now

        interval = 1000.0 / @fps
        if @last_tick_time
          delta = now - @last_tick_time
          @accumulated += delta
          if @accumulated < interval * 0.9
            @last_tick_time = now
            return
          end
          @accumulated -= interval
          @accumulated = interval if @accumulated > interval
        end
        @last_tick_time = now

        if @last_process_time
          elapsed = now - @last_process_time
          @real_fps = elapsed > 0 ? 1000.0 / elapsed : 0.0
        end
        @last_process_time = now

        Input._update
        @ctx[:fillStyle] = _css(@bgcolor)
        @ctx.fillRect(0, 0, @width, @height)
        @ctx.save
        @ctx.translate(@ox, @oy) if @ox != 0 || @oy != 0
        @user_block.call
        @ctx.restore
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
