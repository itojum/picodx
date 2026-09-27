module PicoDX
  class Font
    class << self
      def default
        @default ||= new(16)
      end

      def default=(font)
        @default = font
      end

      def install(filename, name)
        JS.eval(
          "new FontFace(arguments[0], 'url(' + arguments[1] + ')')" \
          ".load().then(font => document.fonts.add(font));",
          name, filename
        )
        new(16, name)
      end
    end

    attr_reader :size, :fontname, :italic, :weight

    def initialize(size, name = "", options = {})
      @size     = size
      @fontname = name.to_s
      @italic   = options[:italic] || false
      @weight   = options[:weight].nil? ? 400 : options[:weight]
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

    def dispose
      @disposed = true
    end

    def disposed?
      @disposed || false
    end

    def info
      { size: @size, name: @fontname, italic: @italic, weight: @weight }
    end
  end
end
