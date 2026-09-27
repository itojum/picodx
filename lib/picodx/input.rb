module PicoDX
  class Input
    @keys_down       = {}
    @keys_prev       = {}
    @keys_pushed     = {}
    @keys_released   = {}
    @key_hold_frames = {}
    @repeat_initial  = 0
    @repeat_interval = 0
    @key_repeat      = {}
    @mouse_x         = 0
    @mouse_y         = 0
    @mouse_down      = {}
    @mouse_prev      = {}
    @mouse_pushed    = {}
    @mouse_released  = {}
    @mouse_wheel_pos = 0

    # Gamepad state (up to 4 pads)
    @pad_count          = 0
    @pad_btns_down      = []
    @pad_btns_prev      = []
    @pad_btns_pushed    = []
    @pad_btns_released  = []
    @pad_hold_frames    = []
    @pad_axes_data      = []
    @pad_repeat_initial = []
    @pad_repeat_interval= []

    class << self
      attr_reader :mouse_x, :mouse_y, :mouse_wheel_pos

      def setup(canvas = nil)
        return if @listening
        @listening = true

        JS.document.addEventListener('keydown') do |e|
          @keys_down[e[:code].to_s] = true
          JS.eval("window.__picodx_audio_ctx && window.__picodx_audio_ctx.state === 'suspended' && window.__picodx_audio_ctx.resume()")
        end
        JS.document.addEventListener('keyup') do |e|
          @keys_down.delete(e[:code].to_s)
        end

        return unless canvas

        canvas.addEventListener('mousemove') do |e|
          rect = canvas.getBoundingClientRect()
          @mouse_x = (e[:clientX].to_f - rect[:left].to_f).to_i
          @mouse_y = (e[:clientY].to_f - rect[:top].to_f).to_i
        end
        canvas.addEventListener('mousedown') do |e|
          raw = e[:button].to_i
          btn = raw == 2 ? 1 : (raw == 1 ? 2 : 0)
          @mouse_down[btn] = true
          JS.eval("window.__picodx_audio_ctx && window.__picodx_audio_ctx.state === 'suspended' && window.__picodx_audio_ctx.resume()")
        end
        canvas.addEventListener('mouseup') do |e|
          raw = e[:button].to_i
          btn = raw == 2 ? 1 : (raw == 1 ? 2 : 0)
          @mouse_down.delete(btn)
        end
        canvas.addEventListener('wheel') do |e|
          @mouse_wheel_pos += e[:deltaY].to_i
        end
      end

      def set_repeat(initial, interval)
        @repeat_initial  = initial
        @repeat_interval = interval
      end

      def set_key_repeat(key, initial, interval)
        @key_repeat[key] = [initial, interval]
      end

      def set_pad_repeat(initial, interval, padnum = 0)
        @pad_repeat_initial[padnum]  = initial
        @pad_repeat_interval[padnum] = interval
      end

      def _update
        new_pushed   = {}
        new_released = {}
        @keys_down.each_key do |code|
          if @keys_prev.key?(code)
            @key_hold_frames[code] += 1
            frames = @key_hold_frames[code]
            ini, rep = @key_repeat[code] || [@repeat_initial, @repeat_interval]
            if rep > 0 && frames >= ini && (frames - ini) % rep == 0
              new_pushed[code] = true
            end
          else
            new_pushed[code] = true
            @key_hold_frames[code] = 0
          end
        end
        @keys_prev.each_key do |code|
          unless @keys_down.key?(code)
            new_released[code] = true
            @key_hold_frames.delete(code)
          end
        end
        @keys_pushed   = new_pushed
        @keys_released = new_released
        @keys_prev.replace(@keys_down)

        new_mouse_pushed   = {}
        new_mouse_released = {}
        @mouse_down.each_key do |btn|
          new_mouse_pushed[btn] = true unless @mouse_prev.key?(btn)
        end
        @mouse_prev.each_key do |btn|
          new_mouse_released[btn] = true unless @mouse_down.key?(btn)
        end
        @mouse_pushed   = new_mouse_pushed
        @mouse_released = new_mouse_released
        @mouse_prev.replace(@mouse_down)

        _update_gamepads
      end

      def key_down?(key)
        @keys_down.key?(key)
      end

      def key_push?(key)
        @keys_pushed[key] || false
      end

      def key_release?(key)
        @keys_released[key] || false
      end

      def x
        if key_down?(K_LEFT) || key_down?(K_A)
          -1
        elsif key_down?(K_RIGHT) || key_down?(K_D)
          1
        else
          0
        end
      end

      def y
        if key_down?(K_UP) || key_down?(K_W)
          -1
        elsif key_down?(K_DOWN) || key_down?(K_S)
          1
        else
          0
        end
      end

      def mouse_down?(btn)
        @mouse_down.key?(btn)
      end

      def mouse_push?(btn)
        @mouse_pushed[btn] || false
      end

      def mouse_release?(btn)
        @mouse_released[btn] || false
      end

      # --- Gamepad API ---

      def pad_num
        @pad_count
      end

      def pad_down?(button, padnum = 0)
        return false unless (btns = @pad_btns_down[padnum])
        btns[button] || false
      end

      def pad_push?(button, padnum = 0)
        return false unless (btns = @pad_btns_pushed[padnum])
        btns[button] || false
      end

      def pad_release?(button, padnum = 0)
        return false unless (btns = @pad_btns_released[padnum])
        btns[button] || false
      end

      def pad_axis(padnum = 0)
        @pad_axes_data[padnum] || []
      end

      def pad_lx(padnum = 0)
        axes = @pad_axes_data[padnum]
        axes ? (axes[0] || 0.0) : 0.0
      end

      def pad_ly(padnum = 0)
        axes = @pad_axes_data[padnum]
        axes ? (axes[1] || 0.0) : 0.0
      end

      def pad_rx(padnum = 0)
        axes = @pad_axes_data[padnum]
        axes ? (axes[2] || 0.0) : 0.0
      end

      def pad_ry(padnum = 0)
        axes = @pad_axes_data[padnum]
        axes ? (axes[3] || 0.0) : 0.0
      end

      def pad_lstick(padnum = 0)
        [pad_lx(padnum), pad_ly(padnum)]
      end

      def pad_rstick(padnum = 0)
        [pad_rx(padnum), pad_ry(padnum)]
      end

      def pad_pov_x(padnum = 0)
        if pad_down?(P_LEFT, padnum)
          -1
        elsif pad_down?(P_RIGHT, padnum)
          1
        else
          0
        end
      end

      def pad_pov_y(padnum = 0)
        if pad_down?(P_UP, padnum)
          -1
        elsif pad_down?(P_DOWN, padnum)
          1
        else
          0
        end
      end

      def pad_pov(padnum = 0)
        px = pad_pov_x(padnum)
        py = pad_pov_y(padnum)
        return -1 if px == 0 && py == 0
        angle = (Math.atan2(py, px) * 180.0 / Math::PI).round
        angle < 0 ? angle + 360 : angle
      end

      private

      def _update_gamepads
        # Serialize as "idx:b0,b1,...|a0,a1,...;..." preserving the original
        # Gamepad.index so device identity is stable when slots are disconnected.
        raw = JS.eval(
          "(() => {" \
          "  const pads = Array.from(navigator.getGamepads());" \
          "  const parts = [];" \
          "  for (let i = 0; i < pads.length; i++) {" \
          "    const g = pads[i];" \
          "    if (!g) continue;" \
          "    parts.push(i + ':' + g.buttons.map(b => b.pressed ? 1 : 0).join(',') + '|' + Array.from(g.axes).join(','));" \
          "  }" \
          "  return parts.join(';');" \
          "})()"
        ).to_s

        if raw.empty?
          @pad_count         = 0
          @pad_btns_down     = []
          @pad_btns_pushed   = []
          @pad_btns_released = []
          @pad_axes_data     = []
          @pad_btns_prev     = []
          @pad_hold_frames   = []
          return
        end

        pads_raw = raw.split(';')
        @pad_count = pads_raw.length
        active_indices = []

        pads_raw.each do |pad_raw|
          colon_pos = pad_raw.index(':')
          pi        = pad_raw[0, colon_pos].to_i
          rest      = pad_raw[colon_pos + 1..]
          btn_str, axis_str = rest.split('|')
          active_indices << pi

          new_down = {}
          (btn_str || "").split(',').each_with_index do |v, bi|
            new_down[bi] = true if v.to_i == 1
          end

          @pad_btns_prev[pi]  ||= {}
          @pad_hold_frames[pi] ||= {}
          prev = @pad_btns_prev[pi]
          hold = @pad_hold_frames[pi]
          pushed   = {}
          released = {}
          ini  = @pad_repeat_initial[pi]  || 0
          rep  = @pad_repeat_interval[pi] || 0

          new_down.each_key do |bi|
            if prev.key?(bi)
              hold[bi] = (hold[bi] || 0) + 1
              frames = hold[bi]
              if rep > 0 && frames >= ini && (frames - ini) % rep == 0
                pushed[bi] = true
              end
            else
              pushed[bi] = true
              hold[bi] = 0
            end
          end
          prev.each_key do |bi|
            unless new_down.key?(bi)
              released[bi] = true
              hold.delete(bi)
            end
          end

          @pad_btns_down[pi]     = new_down
          @pad_btns_pushed[pi]   = pushed
          @pad_btns_released[pi] = released
          @pad_btns_prev[pi]     = new_down.dup

          axes = (axis_str || "").split(',').map { |v| v.to_f }
          @pad_axes_data[pi] = axes
        end

        # Clear state for slots that are no longer connected.
        # Use active_indices (original Gamepad.index values) so a gap in slots
        # (e.g. pad 0 gone, pad 1 still connected) doesn't clear the wrong entry.
        (0...@pad_btns_down.length).each do |pi|
          next if active_indices.include?(pi)
          @pad_btns_down[pi]     = {}
          @pad_btns_pushed[pi]   = {}
          @pad_btns_released[pi] = {}
          @pad_axes_data[pi]     = []
          @pad_btns_prev[pi]     = {}
          @pad_hold_frames[pi]   = {}
        end
      end
    end
  end
end
