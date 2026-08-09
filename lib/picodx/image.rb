module PicoDX
  class Image
    attr_reader :width, :height, :color, :canvas

    def initialize(width, height, color = [0, 0, 0])
      @width  = width
      @height = height
      @color  = color
      @canvas = JS.eval("new OffscreenCanvas(#{width}, #{height})")
      @ctx    = @canvas.getContext('2d', JS.eval("({willReadFrequently: true})"))
      r, g, b, a = color
      @ctx[:fillStyle] = a ? "rgba(#{r},#{g},#{b},#{a.to_f / 255})" : "rgb(#{r},#{g},#{b})"
      @ctx.fillRect(0, 0, width, height)
    end

    def self.load(filename)
      promise = JS.eval("new Promise((res,rej)=>{const i=new Image();i.onload=()=>res(i);i.onerror=()=>rej(new Error('load error'));i.src='#{filename}';})")
      html_img = promise.await
      w = html_img[:naturalWidth].to_i
      h = html_img[:naturalHeight].to_i
      img = Image.new(w, h, [0, 0, 0, 0])
      img._copy_all_from(html_img)
      img
    end

    def self.load_tiles(filename, x_count, y_count)
      base = load(filename)
      tw = base.width / x_count
      th = base.height / y_count
      result = []
      y_count.times do |row|
        row_arr = []
        x_count.times do |col|
          row_arr << base.slice(col * tw, row * th, tw, th)
        end
        result << row_arr
      end
      result
    end

    def fill(color)
      @ctx[:fillStyle] = _css(color)
      @ctx.fillRect(0, 0, @width, @height)
    end

    def clear
      @ctx.clearRect(0, 0, @width, @height)
    end

    def line(x1, y1, x2, y2, color)
      @ctx.beginPath
      @ctx[:strokeStyle] = _css(color)
      @ctx.moveTo(x1 + 0.5, y1 + 0.5)
      @ctx.lineTo(x2 + 0.5, y2 + 0.5)
      @ctx.stroke
    end

    def box(x1, y1, x2, y2, color)
      @ctx[:strokeStyle] = _css(color)
      @ctx.strokeRect(x1 + 0.5, y1 + 0.5, x2 - x1, y2 - y1)
    end

    def box_fill(x1, y1, x2, y2, color)
      @ctx[:fillStyle] = _css(color)
      @ctx.fillRect(x1, y1, x2 - x1, y2 - y1)
    end

    def circle(x, y, r, color)
      @ctx.beginPath
      @ctx[:strokeStyle] = _css(color)
      @ctx.arc(x, y, r, 0, 6.283185307179586)
      @ctx.stroke
    end

    def circle_fill(x, y, r, color)
      @ctx.beginPath
      @ctx[:fillStyle] = _css(color)
      @ctx.arc(x, y, r, 0, 6.283185307179586)
      @ctx.fill
    end

    def triangle(x1, y1, x2, y2, x3, y3, color)
      @ctx.beginPath
      @ctx[:strokeStyle] = _css(color)
      @ctx.moveTo(x1 + 0.5, y1 + 0.5)
      @ctx.lineTo(x2 + 0.5, y2 + 0.5)
      @ctx.lineTo(x3 + 0.5, y3 + 0.5)
      @ctx.closePath
      @ctx.stroke
    end

    def triangle_fill(x1, y1, x2, y2, x3, y3, color)
      @ctx.beginPath
      @ctx[:fillStyle] = _css(color)
      @ctx.moveTo(x1, y1)
      @ctx.lineTo(x2, y2)
      @ctx.lineTo(x3, y3)
      @ctx.closePath
      @ctx.fill
    end

    def draw(x, y, other_image)
      @ctx.drawImage(other_image.canvas, x, y)
    end

    def draw_font(x, y, str, font, color = [255, 255, 255])
      @ctx.save
      @ctx[:fillStyle]    = _css(color)
      @ctx[:font]         = font._css_font
      @ctx[:textBaseline] = 'top'
      @ctx.fillText(str, x, y)
      @ctx.restore
    end

    def draw_font_ex(x, y, str, font, options = {})
      color        = options[:color]        || [255, 255, 255]
      edge_color   = options[:edge_color]
      edge_width   = options[:edge_width]   || 2
      shadow       = options[:shadow]       || false
      shadow_color = options[:shadow_color] || [0, 0, 0]
      shadow_x     = options[:shadow_x]     || 1
      shadow_y     = options[:shadow_y]     || 1

      @ctx.save
      @ctx[:font]         = font._css_font
      @ctx[:textBaseline] = 'top'

      if shadow
        @ctx[:shadowColor]   = _css(shadow_color)
        @ctx[:shadowOffsetX] = shadow_x
        @ctx[:shadowOffsetY] = shadow_y
      end

      if edge_color
        @ctx[:strokeStyle] = _css(edge_color)
        @ctx[:lineWidth]   = edge_width * 2
        @ctx[:lineJoin]    = 'round'
        @ctx.strokeText(str, x, y)
      end

      @ctx[:fillStyle] = _css(color)
      @ctx.fillText(str, x, y)
      @ctx.restore
    end

    def [](x, y)
      data = @ctx.getImageData(x, y, 1, 1)[:data]
      [data[0].to_i, data[1].to_i, data[2].to_i, data[3].to_i]
    end

    def []=(x, y, color)
      r, g, b, a = color
      a ||= 255
      @ctx[:fillStyle] = "rgba(#{r},#{g},#{b},#{a.to_f / 255})"
      @ctx.fillRect(x, y, 1, 1)
    end

    def slice(x, y, w, h)
      new_img = Image.new(w, h, [0, 0, 0, 0])
      new_img._copy_from(@canvas, x, y, w, h)
      new_img
    end

    def dup
      new_img = Image.new(@width, @height, [0, 0, 0, 0])
      new_img._copy_all_from(@canvas)
      new_img
    end

    alias clone dup

    def _copy_from(src, sx, sy, sw, sh)
      @ctx.clearRect(0, 0, @width, @height)
      @ctx.drawImage(src, sx, sy, sw, sh, 0, 0, sw, sh)
    end

    def _copy_all_from(src)
      @ctx.clearRect(0, 0, @width, @height)
      @ctx.drawImage(src, 0, 0)
    end

    private

    def _css(color)
      r, g, b, a = color
      a ? "rgba(#{r},#{g},#{b},#{a.to_f / 255})" : "rgb(#{r},#{g},#{b})"
    end
  end
end
