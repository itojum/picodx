module PicoDX
  class Input
    @keys_down      = {}
    @keys_prev      = {}
    @keys_pushed    = {}
    @keys_released  = {}
    @mouse_x        = 0
    @mouse_y        = 0
    @mouse_down     = {}
    @mouse_prev     = {}
    @mouse_pushed   = {}
    @mouse_released = {}
    @mouse_wheel_pos = 0

    class << self
      attr_reader :mouse_x, :mouse_y, :mouse_wheel_pos

      def setup(canvas = nil)
        return if @listening
        @listening = true

        JS.document.addEventListener('keydown') do |e|
          @keys_down[e[:code].to_s] = true
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

      def _update
        new_pushed   = {}
        new_released = {}
        @keys_down.each_key do |code|
          new_pushed[code] = true unless @keys_prev.key?(code)
        end
        @keys_prev.each_key do |code|
          new_released[code] = true unless @keys_down.key?(code)
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
    end
  end
end
