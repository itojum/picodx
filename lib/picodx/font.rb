module PicoDX
  class Font
    NORMAL = 400
    BOLD   = 700

    class << self
      def default
        @default ||= new(16)
      end

      def default=(font)
        @default = font
      end
    end

    attr_reader :size, :fontname, :italic, :weight

    def initialize(size, name = "", options = {})
      @size     = size
      @fontname = name.to_s
      @italic   = options[:italic] || false
      @weight   = options[:weight] || NORMAL
    end

    alias name fontname

    def get_width(str)
      @measure_ctx ||= JS.eval("new OffscreenCanvas(1, 1)").getContext('2d')
      @measure_ctx[:font] = _css_font
      @measure_ctx.measureText(str)[:width].to_i
    end

    def _css_font
      style  = @italic ? "italic " : ""
      family = @fontname.empty? ? "monospace" : "#{@fontname}, monospace"
      "#{style}#{@weight} #{@size}px #{family}"
    end
  end
end
