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
      r, g, b, a = bgcolor
      @ctx[:fillStyle] = a ? "rgba(#{r},#{g},#{b},#{a.to_f / 255})" : "rgb(#{r},#{g},#{b})"
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
  end
end
