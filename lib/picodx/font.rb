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
        family = name || filename.to_s.split('/').last.split('.').first
        JS.global[:__picodx_font_name] = family
        JS.global[:__picodx_font_url]  = filename.to_s
        JS.eval(
          "new FontFace(window.__picodx_font_name," \
          " 'url(' + window.__picodx_font_url + ')')" \
          ".load().then(font => { document.fonts.add(font); return font; });"
        ).await
        [family]
      end

      # フォント名の別名表。DXRuby のゲームに多い Windows のフォント名を、
      # ブラウザで使えるフォントに読み替える。
      #   Font.add_alias("ＭＳ ゴシック", "Noto Sans JP")
      #   Font.add_alias("メイリオ", ["Hiragino Sans", "sans-serif"])
      def aliases
        @aliases ||= _default_aliases
      end

      def aliases=(table)
        @aliases = table
      end

      def add_alias(name, families)
        aliases[name.to_s] = families
      end

      # Font#_css_font で使う font-family の文字列
      def _css_family(name)
        families = aliases[name]
        families = [name] if families.nil?
        families = [families] unless families.is_a?(Array)
        list = families.map { |f| _css_family_name(f.to_s) }
        list << "monospace" unless families.include?("monospace")
        list.join(", ")
      end

      private

      # 総称ファミリはそのまま、それ以外は引用符で囲む（空白や全角文字を含む名前のため）
      def _css_family_name(name)
        case name
        when "serif", "sans-serif", "monospace", "cursive", "fantasy", "system-ui",
             "ui-serif", "ui-sans-serif", "ui-monospace", "ui-rounded", "emoji", "math", "fangsong"
          name
        else
          "\"#{name.split('"').join}\""
        end
      end

      # Windows の代表的な日本語フォントを、等幅・プロポーショナル・明朝の
      # 総称ファミリに読み替える既定の表
      def _default_aliases
        {
          "ＭＳ ゴシック"   => "monospace",
          "MS Gothic"       => "monospace",
          "ＭＳ Ｐゴシック" => "sans-serif",
          "MS PGothic"      => "sans-serif",
          "MS UI Gothic"    => "sans-serif",
          "メイリオ"        => "sans-serif",
          "Meiryo"          => "sans-serif",
          "游ゴシック"      => "sans-serif",
          "Yu Gothic"       => "sans-serif",
          "ＭＳ 明朝"       => "serif",
          "MS Mincho"       => "serif",
          "ＭＳ Ｐ明朝"     => "serif",
          "MS PMincho"      => "serif",
          "游明朝"          => "serif",
          "Yu Mincho"       => "serif"
        }
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
      family = @fontname.empty? ? "monospace" : Font._css_family(@fontname)
      "#{style}#{@weight} #{@size}px #{family}"
    end

    def dispose
      @disposed = true
    end

    def disposed?
      @disposed || false
    end

    def info(str)
      @measure_ctx ||= JS.eval("new OffscreenCanvas(1, 1)").getContext('2d')
      @measure_ctx[:font] = _css_font
      m  = @measure_ctx.measureText(str)
      {
        width:       m[:width].to_i,
        height:      (m[:actualBoundingBoxAscent].to_f + m[:actualBoundingBoxDescent].to_f).to_i,
        left_offset: m[:actualBoundingBoxLeft].to_i,
        top_offset:  m[:actualBoundingBoxAscent].to_i
      }
    end
  end
end
