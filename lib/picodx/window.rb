module PicoDX
  class Window
    class << self
      include Drawable

      attr_reader :real_fps

      def fps;     @fps     || 60;        end
      def ox;      @ox      || 0;         end
      def oy;      @oy      || 0;         end
      def bgcolor; @bgcolor || [0, 0, 0]; end

      # init 前に読まれた場合も canvas の実サイズを返せるよう、自動接続する
      def width
        _ensure_ready
        @width
      end

      def height
        _ensure_ready
        @height
      end

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
        # init 前に setter で設定された値は保持する（Window.init を省略して
        # 自動接続したときも、先に書いた bgcolor= / fps= などが効くように）
        @bgcolor ||= [0, 0, 0]
        @fps     ||= 60
        @real_fps = 0.0
        @ox      ||= 0
        @oy      ||= 0
        @looping   = false
        @closed    = false
        @created   = true
        @frameskip = false if @frameskip.nil?
        @draw_queue = nil
        _apply_smoothing
        self.scale = @scale if @scale
        JS.eval("window.__picodx_nextFrame = () => new Promise(resolve => requestAnimationFrame(resolve))")
        Input.setup(@canvas)
      end

      def close
        @closed   = true
        @created  = false
        @looping  = false
      end

      def closed?
        @closed || false
      end

      def created?
        @created || false
      end

      def active?
        JS.eval("document.hasFocus()").to_s == "true"
      end

      def get_screen_shot(filename = nil)
        fname = filename || "screenshot.png"
        url = @canvas.toDataURL("image/png")
        a   = JS.document.createElement("a")
        a[:href]     = url
        a[:download] = fname
        a.click
      end

      def resize(w, h)
        @canvas[:width]  = w
        @canvas[:height] = h
        @width  = w
        @height = h
        _apply_smoothing
      end

      def scale=(s)
        @scale = s
        return unless @canvas
        @canvas[:style][:width]  = "#{(@width  * s).to_i}px"
        @canvas[:style][:height] = "#{(@height * s).to_i}px"
      end

      def sync
      end

      def update
      end

      def min_filter=(filter)
        @min_filter = filter
        _apply_smoothing
      end

      def mag_filter=(filter)
        @mag_filter = filter
        _apply_smoothing
      end

      def frameskip=(val)
        @frameskip = val
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
        _ensure_ready
        if @looping
          # Re-entrant call: run a nested frame loop until the block exits.
          # break/return inside the block raises LocalJumpError via .call,
          # which we rescue to cleanly exit the inner loop.
          # The exit_value carries the value from break/return so callers
          # can use: result = Window.loop { ... ; return chara_type }
          result = nil
          while !@closed
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
          while !@closed
            JS.global.__picodx_nextFrame().await
            _tick
          end
        end
      end

      private

      # ctx に現在掛かっている平行移動量（_tick_with が translate した分の累計）。
      # ループ外の即時描画では 0。ブロック内で ox を変えても、ネストしたループで
      # translate が重なっても、実際の描画位置と一致する
      def _view_ox
        @view_ox || 0
      end

      def _view_oy
        @view_oy || 0
      end

      def _apply_smoothing
        return unless @ctx
        @ctx[:imageSmoothingEnabled] = (@min_filter != :nearest && @mag_filter != :nearest)
      end

      # Window.init を省略したとき、最初の描画か Window.loop の時点で
      # #game、なければページ内の最初の <canvas> に自動で接続する。
      def _ensure_ready
        return if @ctx
        id = JS.eval(
          "(() => {" \
          " const c = document.querySelector('canvas#game') || document.querySelector('canvas');" \
          " if (!c) return '';" \
          " if (!c.id) c.id = 'picodx-game';" \
          " return c.id;" \
          "})()"
        ).to_s
        if id.empty?
          raise "PicoDX: no <canvas> found. Add <canvas id=\"game\"> to the page or call Window.init(canvas_id)."
        end
        init(id)
      end

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
        saved_view_ox = @view_ox
        saved_view_oy = @view_oy
        @draw_queue = []
        @ctx.save
        @ctx.translate(@ox, @oy) if @ox != 0 || @oy != 0
        @view_ox = (saved_view_ox || 0) + @ox
        @view_oy = (saved_view_oy || 0) + @oy
        begin
          blk.call
        ensure
          _flush_draw_queue
          @draw_queue = saved_queue
          @view_ox = saved_view_ox
          @view_oy = saved_view_oy
          @ctx.restore
        end
      end
    end
  end
end
