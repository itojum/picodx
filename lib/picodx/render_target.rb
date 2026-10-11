module PicoDX
  class RenderTarget
    include Drawable

    attr_reader :width, :height, :bgcolor, :ox, :oy, :canvas

    def initialize(width, height, bgcolor = [0, 0, 0])
      @width    = width
      @height   = height
      @bgcolor  = bgcolor
      @ox       = 0
      @oy       = 0
      @disposed = false
      @canvas   = JS.eval("new OffscreenCanvas(#{width}, #{height})")
      @ctx      = @canvas.getContext('2d', JS.eval("({willReadFrequently: true})"))
      @ctx[:fillStyle] = _css(bgcolor)
      @ctx.fillRect(0, 0, width, height)
    end

    def bgcolor=(color)
      @bgcolor = color
    end

    # (ox, oy) が RenderTarget の左上に来るよう、以降の描画を (-ox, -oy) ずらす
    def ox=(value)
      @ox = value
      _apply_offset
    end

    def oy=(value)
      @oy = value
      _apply_offset
    end

    def min_filter=(filter)
      @min_filter = filter
      @ctx[:imageSmoothingEnabled] = (@min_filter != :nearest && @mag_filter != :nearest)
    end

    def mag_filter=(filter)
      @mag_filter = filter
      @ctx[:imageSmoothingEnabled] = (@min_filter != :nearest && @mag_filter != :nearest)
    end

    def discard; end
    def decide;  end

    def update
    end

    def to_image
      img = Image.new(@width, @height, [0, 0, 0, 0])
      img._copy_all_from(@canvas)
      img
    end

    def resize(w, h)
      return if @disposed
      @width  = w
      @height = h
      @canvas = JS.eval("new OffscreenCanvas(#{w}, #{h})")
      @ctx    = @canvas.getContext('2d', JS.eval("({willReadFrequently: true})"))
      @ctx[:imageSmoothingEnabled] = (@min_filter != :nearest && @mag_filter != :nearest)
      # 新しい canvas は透明なので背景色で塗り、ox / oy のずれを掛け直す
      @ctx[:fillStyle] = _css(@bgcolor)
      @ctx.fillRect(0, 0, w, h)
      _apply_offset
    end

    def dispose
      @disposed = true
    end

    def disposed?
      @disposed
    end

    private

    def _apply_offset
      @ctx.setTransform(1, 0, 0, 1, -@ox, -@oy)
    end

    # 画面外判定（Drawable#_on_screen?）で使う、描画に掛かっている平行移動量
    def _view_ox
      -@ox
    end

    def _view_oy
      -@oy
    end
  end
end
