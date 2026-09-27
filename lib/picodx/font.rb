module PicoDX
  class Font
    class << self
      def default
        @default ||= new(16)
      end

      def default=(font)
        @default = font
      end

      def install(filename, name = nil)
        font_name = name || File.basename(filename, ".*")
        safe_name = font_name.gsub("\\") { "\\\\" }.gsub("'") { "\\'" }
        safe_file = filename.gsub("\\") { "\\\\" }.gsub("'") { "\\'" }
        JS.eval(
          "new FontFace('#{safe_name}', 'url(#{safe_file})').load().then(f => document.fonts.add(f))"
        ).await
        font_name
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

    def dispose
      @disposed = true
    end

    def disposed?
      @disposed || false
    end

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
