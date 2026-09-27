module PicoDX
  class Window
    class << self
      include Drawable

      attr_reader :width, :height, :fps, :real_fps, :ox, :oy, :bgcolor

      def width=(value)
        @preset_width = value
        @preset_width_canvas_id = @canvas_id if @canvas_id
        if @canvas
          @canvas[:width] = value
          @width = value
        end
      end

      def height=(value)
        @preset_height = value
        @preset_height_canvas_id = @canvas_id if @canvas_id
        if @canvas
          @canvas[:height] = value
          @height = value
        end
      end

      def init(canvas_id)
        @canvas_id = canvas_id
        @canvas   = JS.document.getElementById(canvas_id)
        @ctx      = @canvas.getContext('2d', JS.eval("({willReadFrequently: true})"))
        apply_width  = @preset_width_canvas_id.nil? || @preset_width_canvas_id == canvas_id
        apply_height = @preset_height_canvas_id.nil? || @preset_height_canvas_id == canvas_id
        @canvas[:width]  = @preset_width  if apply_width && @preset_width
        @canvas[:height] = @preset_height if apply_height && @preset_height
        @preset_width_canvas_id = canvas_id if apply_width && @preset_width
        @preset_height_canvas_id = canvas_id if apply_height && @preset_height
        @width    = @canvas[:width].to_i
        @height   = @canvas[:height].to_i
        @bgcolor  = [0, 0, 0]
        @fps      = 60
        @real_fps = 0.0
        @ox       = 0
        @oy       = 0
        @looping  = false
        @draw_queue = nil
        JS.eval("window.__picodx_nextFrame = () => new Promise(resolve => requestAnimationFrame(resolve))")
        Input.setup(@canvas)
      end

      def created?
        !@canvas.nil?
      end

      def closed?
        @closed || false
      end

      def close
        @closed = true
      end

      def active?
        JS.eval("document.hasFocus()").to_s == "true"
      end

      def get_screen_shot(filename = nil)
        return unless @canvas
        a_el = JS.document.createElement('a')
        a_el[:href]     = @canvas.toDataURL('image/png')
        a_el[:download] = filename || "screenshot.png"
        a_el.click
      end

      def scale=(s)
        return unless @canvas
        @canvas[:style][:transform] = "scale(#{s})"
        @canvas[:style][:transformOrigin] = "0 0"
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
          # The exit_value carries the value from break/return so callers
          # can use: result = Window.loop { ... ; return chara_type }
          result = nil
          while true
            JS.global.__picodx_nextFrame().await
            begin
              _tick_with(block)
            rescue LocalJumpError => e
              result = e.exit_value
              break
            end
          end
          result
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

      # --- Platform non-applicable (Canvas 2D backend) ---
      # These APIs exist in DXRuby but cannot be implemented in a browser.
      # They raise NotImplementedError so ported code fails with a clear message.
      NOT_IMPL = "not supported on the Canvas 2D backend (picodx). See docs/compatibility.md"
      def hWnd;              raise NotImplementedError, "Window.hWnd #{NOT_IMPL}";              end
      def full_screen?;      raise NotImplementedError, "Window.full_screen? #{NOT_IMPL}";      end
      def full_screen=(_v);  raise NotImplementedError, "Window.full_screen= #{NOT_IMPL}";      end
      def windowed?;         raise NotImplementedError, "Window.windowed? #{NOT_IMPL}";          end
      def windowed=(_v);     raise NotImplementedError, "Window.windowed= #{NOT_IMPL}";          end
      def get_screen_modes;  raise NotImplementedError, "Window.get_screen_modes #{NOT_IMPL}";  end
      def get_current_mode;  raise NotImplementedError, "Window.get_current_mode #{NOT_IMPL}";  end
      def load_icon(*_);     raise NotImplementedError, "Window.load_icon #{NOT_IMPL}";         end
      def open_filename(*_); raise NotImplementedError, "Window.open_filename #{NOT_IMPL}";     end
      def save_filename(*_); raise NotImplementedError, "Window.save_filename #{NOT_IMPL}";     end
      def folder_dialog(*_); raise NotImplementedError, "Window.folder_dialog #{NOT_IMPL}";     end
      def draw_shader(*_);   raise NotImplementedError, "Window.draw_shader #{NOT_IMPL}";       end

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
        saved_queue = @draw_queue
        @draw_queue = []
        @ctx.save
        @ctx.translate(@ox, @oy) if @ox != 0 || @oy != 0
        begin
          blk.call
        ensure
          _flush_draw_queue
          @draw_queue = saved_queue
          @ctx.restore
        end
      end
    end
  end
end
