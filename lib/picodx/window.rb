module PicoDX
  class Window
    class << self
      include Drawable

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
        @looping  = false
        JS.eval("window.__picodx_nextFrame = () => new Promise(resolve => requestAnimationFrame(resolve))")
        Input.setup(@canvas)
      end

      def caption
        JS.document[:title].to_s
      end

      def caption=(str)
        JS.document[:title] = str
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
        if @looping
          # Re-entrant call: run a nested frame loop until the block exits.
          # break/return inside the block raises LocalJumpError via .call,
          # which we rescue to cleanly exit the inner loop.
          while true
            JS.global.__picodx_nextFrame().await
            begin
              _tick_with(block)
            rescue LocalJumpError
              break
            end
          end
        else
          @looping           = true
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
      end

      private

      def _tick
        _tick_with(@user_block)
      end

      def _tick_with(blk)
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
        blk.call
        @ctx.restore
      end
    end
  end
end
