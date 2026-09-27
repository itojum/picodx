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

    def ox=(value)
      @ox = value
    end

    def oy=(value)
      @oy = value
    end

    def min_filter=(filter)
      @min_filter = filter
      @ctx[:imageSmoothingEnabled] = (filter != :nearest)
    end

    def mag_filter=(filter)
      @mag_filter = filter
      @ctx[:imageSmoothingEnabled] = (filter != :nearest)
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
    end

    def dispose
      @disposed = true
    end

    def disposed?
      @disposed
    end
  end
end
