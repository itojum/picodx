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
    @pad_buttons_down    = {}
    @pad_buttons_prev    = {}
    @pad_buttons_pushed  = {}
    @pad_buttons_released= {}
    @pad_hold_frames     = {}
    @pad_repeat_initial  = 0
    @pad_repeat_interval = 0
    @connected_pads      = []

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

        if JS.eval("typeof navigator.getGamepads === 'function'")
          gamepads = JS.eval("navigator.getGamepads()")
          max = JS.eval("navigator.getGamepads().length").to_i
          @pad_buttons_prev.replace(@pad_buttons_down)
          @pad_buttons_down    = {}
          @pad_buttons_pushed  = {}
          @pad_buttons_released= {}
          @connected_pads      = []
          pad_idx = 0
          while pad_idx < max
            gp = gamepads[pad_idx]
            if gp.nil? || gp[:connected].to_s == "false"
              @pad_buttons_prev.delete(pad_idx)
              @pad_hold_frames.delete(pad_idx)
            else
              @connected_pads << pad_idx
              btn_count = gp[:buttons][:length].to_i
              @pad_buttons_down[pad_idx]     = {}
              @pad_buttons_pushed[pad_idx]   = {}
              @pad_buttons_released[pad_idx] = {}
              @pad_hold_frames[pad_idx]      ||= {}
              btn_i = 0
              while btn_i < btn_count
                pressed = gp[:buttons][btn_i][:pressed].to_s == "true"
                prev    = @pad_buttons_prev.dig(pad_idx, btn_i)
                @pad_buttons_down[pad_idx][btn_i] = true if pressed
                if pressed && !prev
                  @pad_buttons_pushed[pad_idx][btn_i] = true
                  @pad_hold_frames[pad_idx][btn_i] = 0
                elsif pressed && prev
                  @pad_hold_frames[pad_idx][btn_i] = (@pad_hold_frames[pad_idx][btn_i] || 0) + 1
                  frames = @pad_hold_frames[pad_idx][btn_i]
                  ini = @pad_repeat_initial; rep = @pad_repeat_interval
                  if rep > 0 && frames >= ini && (frames - ini) % rep == 0
                    @pad_buttons_pushed[pad_idx][btn_i] = true
                  end
                elsif !pressed && prev
                  @pad_buttons_released[pad_idx][btn_i] = true
                  @pad_hold_frames[pad_idx].delete(btn_i)
                end
                btn_i += 1
              end
            end
            pad_idx += 1
          end
        end
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

      def set_pad_repeat(initial, interval)
        @pad_repeat_initial  = initial
        @pad_repeat_interval = interval
      end

      def pad_num
        @connected_pads.length
      end

      def pad_down?(button, pad = 0)
        slot = _pad_slot(pad)
        return false unless slot && @pad_buttons_down[slot]
        @pad_buttons_down[slot][button] || false
      end

      def pad_push?(button, pad = 0)
        slot = _pad_slot(pad)
        return false unless slot && @pad_buttons_pushed[slot]
        @pad_buttons_pushed[slot][button] || false
      end

      def pad_release?(button, pad = 0)
        slot = _pad_slot(pad)
        return false unless slot && @pad_buttons_released[slot]
        @pad_buttons_released[slot][button] || false
      end

      def pad_axis(index, pad = 0)
        axes = _pad_axes(pad)
        return 0.0 unless axes
        axes[index] || 0.0
      end

      def pad_lstick(pad = 0)
        axes = _pad_axes(pad)
        return [0.0, 0.0] unless axes
        [axes[0] || 0.0, axes[1] || 0.0]
      end

      def pad_rstick(pad = 0)
        axes = _pad_axes(pad)
        return [0.0, 0.0] unless axes
        [axes[2] || 0.0, axes[3] || 0.0]
      end

      def pad_lx(pad = 0); pad_lstick(pad)[0]; end
      def pad_ly(pad = 0); pad_lstick(pad)[1]; end
      def pad_rx(pad = 0); pad_rstick(pad)[0]; end
      def pad_ry(pad = 0); pad_rstick(pad)[1]; end

      def pad_pov(pad = 0)
        up    = pad_down?(P_UP,    pad)
        down  = pad_down?(P_DOWN,  pad)
        left  = pad_down?(P_LEFT,  pad)
        right = pad_down?(P_RIGHT, pad)
        return  -1 unless up || down || left || right
        return   0 if up    && !right && !left
        return  45 if up    && right
        return  90 if right && !up   && !down
        return 135 if down  && right
        return 180 if down  && !right && !left
        return 225 if down  && left
        return 270 if left  && !up   && !down
        return 315 if up    && left
        -1
      end

      def pad_pov_x(pad = 0)
        right = pad_down?(P_RIGHT, pad)
        left  = pad_down?(P_LEFT,  pad)
        right ? 1 : (left ? -1 : 0)
      end

      def pad_pov_y(pad = 0)
        down = pad_down?(P_DOWN, pad)
        up   = pad_down?(P_UP,   pad)
        down ? 1 : (up ? -1 : 0)
      end

      private

      def _pad_slot(pad)
        @connected_pads[pad]
      end

      def _pad_axes(pad)
        return nil unless JS.eval("typeof navigator.getGamepads === 'function'")
        slot = _pad_slot(pad)
        return nil unless slot
        gamepads = JS.eval("navigator.getGamepads()")
        gp = gamepads[slot]
        return nil if gp.nil? || gp[:connected].to_s == "false"
        axis_count = gp[:axes][:length].to_i
        result = []
        i = 0
        while i < axis_count
          result << gp[:axes][i].to_f
          i += 1
        end
        result
      end
    end
  end
end
