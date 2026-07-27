module PicoDX
  class Input
    @keys_down    = {}
    @keys_prev    = {}
    @keys_pushed  = {}

    class << self
      def setup
        return if @listening
        @listening = true
        JS.document.addEventListener('keydown') do |e|
          @keys_down[e[:code].to_s] = true
        end
        JS.document.addEventListener('keyup') do |e|
          @keys_down.delete(e[:code].to_s)
        end
      end

      def _update
        @keys_pushed = {}
        @keys_down.each_key do |code|
          @keys_pushed[code] = true unless @keys_prev.key?(code)
        end
        @keys_prev.replace(@keys_down)
      end

      def key_down?(key)
        @keys_down.key?(key)
      end

      def key_push?(key)
        @keys_pushed[key] || false
      end
    end
  end
end
