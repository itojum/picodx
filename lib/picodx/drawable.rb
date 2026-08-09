module PicoDX
  module Drawable
    def draw(x, y, image)
      @ctx.drawImage(image.canvas, x, y)
    end

    def draw_box(x1, y1, x2, y2, color)
      @ctx[:strokeStyle] = _css(color)
      @ctx.strokeRect(x1, y1, x2 - x1, y2 - y1)
    end

    def draw_box_fill(x1, y1, x2, y2, color)
      @ctx[:fillStyle] = _css(color)
      @ctx.fillRect(x1, y1, x2 - x1, y2 - y1)
    end

    def draw_font(x, y, str, font_or_color, color_or_size = nil)
      if font_or_color.is_a?(Font)
        font  = font_or_color
        color = color_or_size.is_a?(Hash) ? (color_or_size[:color] || [255, 255, 255]) : (color_or_size || [255, 255, 255])
        @ctx.save
        @ctx[:fillStyle] = _css(color)
        @ctx[:font]         = font._css_font
        @ctx[:textBaseline] = 'top'
        @ctx.fillText(str, x, y)
        @ctx.restore
      else
        color = font_or_color
        size  = color_or_size || 16
        @ctx.save
        @ctx[:fillStyle]    = _css(color)
        @ctx[:font]         = "#{size}px monospace"
        @ctx[:textBaseline] = 'top'
        @ctx.fillText(str, x, y)
        @ctx.restore
      end
    end

    def draw_line(x1, y1, x2, y2, color)
      @ctx.beginPath
      @ctx[:strokeStyle] = _css(color)
      @ctx.moveTo(x1, y1)
      @ctx.lineTo(x2, y2)
      @ctx.stroke
    end

    def draw_pixel(x, y, color)
      @ctx[:fillStyle] = _css(color)
      @ctx.fillRect(x, y, 1, 1)
    end

    def draw_circle(x, y, r, color)
      @ctx.beginPath
      @ctx[:strokeStyle] = _css(color)
      @ctx.arc(x, y, r, 0, 6.283185307179586)
      @ctx.stroke
    end

    def draw_circle_fill(x, y, r, color)
      @ctx.beginPath
      @ctx[:fillStyle] = _css(color)
      @ctx.arc(x, y, r, 0, 6.283185307179586)
      @ctx.fill
    end

    def draw_scale(x, y, image, scale_x, scale_y)
      @ctx.save
      @ctx.translate(x, y)
      @ctx.scale(scale_x, scale_y)
      @ctx.drawImage(image.canvas, 0, 0)
      @ctx.restore
    end

    def draw_rot(x, y, image, angle, cx = 0, cy = 0)
      rad = angle * Math::PI / 180.0
      @ctx.save
      @ctx.translate(x, y)
      @ctx.rotate(rad)
      @ctx.drawImage(image.canvas, -cx, -cy)
      @ctx.restore
    end

    def draw_alpha(x, y, image, alpha)
      @ctx.save
      @ctx[:globalAlpha] = alpha.to_f / 255
      @ctx.drawImage(image.canvas, x, y)
      @ctx.restore
    end

    def draw_ex(x, y, image, options = {})
      angle   = options[:angle]   || 0
      scale_x = options[:scale_x] || 1.0
      scale_y = options[:scale_y] || 1.0
      alpha   = options[:alpha]
      cx      = options[:cx]      || 0
      cy      = options[:cy]      || 0
      blend   = options[:blend]
      rad = angle * Math::PI / 180.0
      @ctx.save
      @ctx[:globalCompositeOperation] = _blend_op(blend) if blend
      @ctx[:globalAlpha] = alpha.to_f / 255 if alpha
      @ctx.translate(x, y)
      @ctx.rotate(rad)
      @ctx.scale(scale_x, scale_y)
      @ctx.drawImage(image.canvas, -cx, -cy)
      @ctx.restore
    end

    def draw_tile(x, y, map, chips, offset_x, offset_y, count_x, count_y)
      flat = chips.flatten
      return if flat.empty?
      tw    = flat[0].width
      th    = flat[0].height
      t_ox  = offset_x / tw
      t_oy  = offset_y / th
      px_ox = offset_x % tw
      px_oy = offset_y % th
      (count_y + 1).times do |row|
        map_row = t_oy + row
        next if map_row < 0 || map_row >= map.length
        (count_x + 1).times do |col|
          map_col = t_ox + col
          next if map_col < 0 || map_col >= map[map_row].length
          idx = map[map_row][map_col]
          next if idx.nil?
          chip = flat[idx]
          next if chip.nil?
          @ctx.drawImage(chip.canvas, x + col * tw - px_ox, y + row * th - px_oy)
        end
      end
    end

    private

    def _css(color)
      r, g, b, a = color
      a ? "rgba(#{r},#{g},#{b},#{a.to_f / 255})" : "rgb(#{r},#{g},#{b})"
    end

    def _blend_op(blend)
      case blend
      when :add then "lighter"
      when :sub then "difference"
      else "source-over"
      end
    end
  end
end
