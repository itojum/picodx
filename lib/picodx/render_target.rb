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
    end

    def dispose
      @disposed = true
    end

    def disposed?
      @disposed
    end

    NOT_IMPL = "not supported on the Canvas 2D backend (picodx). See docs/compatibility.md"
    def draw_shader(*_); raise NotImplementedError, "RenderTarget#draw_shader #{NOT_IMPL}"; end
    def min_filter=(_v); raise NotImplementedError, "RenderTarget#min_filter= #{NOT_IMPL}"; end
    def mag_filter=(_v); raise NotImplementedError, "RenderTarget#mag_filter= #{NOT_IMPL}"; end
    def discard(*_);     raise NotImplementedError, "RenderTarget#discard #{NOT_IMPL}";     end
    def decide(*_);      raise NotImplementedError, "RenderTarget#decide #{NOT_IMPL}";      end
  end
end
