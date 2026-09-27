module PicoDX
  class Image
    attr_reader :width, :height

    def _ctx
      @ctx
    end

    def initialize(width, height, color = [0, 0, 0])
      @width  = width
      @height = height
      @color  = color
      @canvas = JS.eval("new OffscreenCanvas(#{width}, #{height})")
      @ctx    = @canvas.getContext('2d', JS.eval("({willReadFrequently: true})"))
      @ctx[:fillStyle] = _css(color)
      @ctx.fillRect(0, 0, width, height)
    end

    @@cache = {}

    def self.create_from_array(width, height, array)
      img = Image.new(width, height, [0, 0, 0, 0])
      raw = img._ctx.createImageData(width, height)
      data = raw[:data]
      n = width * height
      i = 0
      while i < n
        pixel = array[i] || [0, 0, 0, 0]
        a, r, g, b = pixel
        j = i * 4
        data[j]     = r.to_i
        data[j + 1] = g.to_i
        data[j + 2] = b.to_i
        data[j + 3] = a.to_i
        i += 1
      end
      img._ctx.putImageData(raw, 0, 0)
      img
    end

    def self.load(filename)
      cached = @@cache[filename]
      return cached.dup if cached

      promise = JS.eval("new Promise((res,rej)=>{const i=new Image();i.onload=()=>res(i);i.onerror=()=>rej(new Error('load error'));i.src='#{filename}';})")
      html_img = promise.await
      w = html_img[:naturalWidth].to_i
      h = html_img[:naturalHeight].to_i
      img = Image.new(w, h, [0, 0, 0, 0])
      img._copy_all_from(html_img)
      @@cache[filename] = img
      img.dup
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

    def dispose
      @disposed = true
      @canvas = nil
      @ctx    = nil
    end

    def disposed?
      @disposed || false
    end

    def set_color_key(color)
      return if @disposed
      a, r, g, b = color.length == 4 ? color : [255, *color]
      raw = @ctx.getImageData(0, 0, @width, @height)
      data = raw[:data]
      n = @width * @height
      i = 0
      while i < n
        j = i * 4
        if data[j].to_i == r && data[j+1].to_i == g && data[j+2].to_i == b && data[j+3].to_i == a
          data[j]     = 0
          data[j + 1] = 0
          data[j + 2] = 0
          data[j + 3] = 0
        end
        i += 1
      end
      @ctx.putImageData(raw, 0, 0)
      self
    end

    def copy_rect(x, y, src, sx, sy, sw, sh)
      return if @disposed
      @ctx.drawImage(src._ctx[:canvas], sx, sy, sw, sh, x, y, sw, sh)
    end

    def save(filename = nil)
      return if @disposed
      a_el = JS.eval("document.createElement('a')")
      a_el[:href]     = @canvas.toDataURL('image/png')
      a_el[:download] = filename || "image.png"
      a_el.click
    end

    def slice_tiles(x_count, y_count)
      tw = @width / x_count
      th = @height / y_count
      result = []
      y_count.times do |row|
        row_arr = []
        x_count.times do |col|
          row_arr << slice(col * tw, row * th, tw, th)
        end
        result << row_arr
      end
      result
    end

    def flush
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
      @ctx.drawImage(other_image._ctx[:canvas], x, y)
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

    def to_a
      data = @ctx.getImageData(0, 0, @width, @height)[:data]
      result = []
      n = @width * @height
      i = 0
      while i < n
        j = i * 4
        result << [data[j+3].to_i, data[j].to_i, data[j+1].to_i, data[j+2].to_i]
        i += 1
      end
      result
    end
    def compare(x, y, other, ox, oy, w, h)
      data1 = @ctx.getImageData(x, y, w, h)[:data]
      data2 = other._ctx.getImageData(ox, oy, w, h)[:data]
      diff = 0
      n = w * h
      i = 0
      while i < n
        j = i * 4
        if data1[j].to_i   != data2[j].to_i   ||
           data1[j+1].to_i != data2[j+1].to_i ||
           data1[j+2].to_i != data2[j+2].to_i ||
           data1[j+3].to_i != data2[j+3].to_i
          diff += 1
        end
        i += 1
      end
      diff
    end

    def change_hls(hue = 0, luminance = 0, saturation = 0)
      hue_shift        = hue.to_f
      luminance_delta  = luminance.to_f / 100.0
      saturation_delta = saturation.to_f / 100.0
      return dup if hue_shift.zero? && luminance_delta.zero? && saturation_delta.zero?
      base_img = hue_shift.zero? ? self : _change_hls_hue(hue_shift)
      return base_img if luminance_delta.zero? && saturation_delta.zero?

      new_img = Image.new(@width, @height, [0, 0, 0, 0])
      src_data = base_img._ctx.getImageData(0, 0, @width, @height)[:data]
      dst_img  = new_img._ctx.createImageData(@width, @height)
      dst_data = dst_img[:data]
      n = @width * @height
      i = 0
      while i < n
        j = i * 4
        r = src_data[j].to_f / 255
        g = src_data[j + 1].to_f / 255
        b = src_data[j + 2].to_f / 255
        a = src_data[j + 3].to_i

        h, l, s = _rgb_to_hls(r, g, b)
        l = _clamp01(l + luminance_delta)
        s = _clamp01(s + saturation_delta)
        nr, ng, nb = _hls_to_rgb(h, l, s)

        dst_data[j]     = (nr * 255).round
        dst_data[j + 1] = (ng * 255).round
        dst_data[j + 2] = (nb * 255).round
        dst_data[j + 3] = a
        i += 1
      end
      new_img._ctx.putImageData(dst_img, 0, 0)
      new_img
    end

    def [](x, y)
      data = @ctx.getImageData(x, y, 1, 1)[:data]
      [data[3].to_i, data[0].to_i, data[1].to_i, data[2].to_i]
    end

    def []=(x, y, color)
      @ctx.clearRect(x, y, 1, 1)
      @ctx[:fillStyle] = _css(color)
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

    def _change_hls_hue(hue_shift)
      new_img = Image.new(@width, @height, [0, 0, 0, 0])
      new_img._ctx[:filter] = "hue-rotate(#{hue_shift}deg)"
      new_img._ctx.drawImage(@canvas, 0, 0)
      new_img._ctx[:filter] = "none"
      new_img
    end

    def _css(color)
      if color.length == 4
        a, r, g, b = color
        "rgba(#{r},#{g},#{b},#{a.to_f / 255})"
      else
        r, g, b = color
        "rgb(#{r},#{g},#{b})"
      end
    end

    def _clamp01(value)
      return 0.0 if value < 0.0
      return 1.0 if value > 1.0
      value
    end

    def _rgb_to_hls(r, g, b)
      max = [r, g, b].max
      min = [r, g, b].min
      l = (max + min) / 2.0
      return [0.0, l, 0.0] if max == min

      d = max - min
      s = l > 0.5 ? d / (2.0 - max - min) : d / (max + min)
      h = case max
          when r then ((g - b) / d) + (g < b ? 6.0 : 0.0)
          when g then ((b - r) / d) + 2.0
          else         ((r - g) / d) + 4.0
          end
      [(h * 60.0) % 360.0, l, s]
    end

    def _hls_to_rgb(h, l, s)
      return [l, l, l] if s == 0.0

      q = l < 0.5 ? l * (1.0 + s) : l + s - (l * s)
      p = 2.0 * l - q
      hk = h / 360.0
      [
        _hue_to_rgb(p, q, hk + (1.0 / 3.0)),
        _hue_to_rgb(p, q, hk),
        _hue_to_rgb(p, q, hk - (1.0 / 3.0))
      ]
    end

    def _hue_to_rgb(p, q, t)
      t += 1.0 if t < 0.0
      t -= 1.0 if t > 1.0
      return p + (q - p) * 6.0 * t if t < (1.0 / 6.0)
      return q if t < 0.5
      return p + (q - p) * ((2.0 / 3.0) - t) * 6.0 if t < (2.0 / 3.0)
      p
    end
  end
end
