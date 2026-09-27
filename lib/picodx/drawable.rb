module PicoDX
  module Drawable
    # -------------------------------------------------------------------------
    # Queue-aware public draw methods
    # Each method pushes a descriptor onto @draw_queue when available
    # (Window), or falls through to the immediate _render_* variant
    # (RenderTarget, which has no queue).
    # -------------------------------------------------------------------------

    def draw(x, y, image, z: 0)
      if _has_queue?
        @draw_queue << { type: :draw, z: z, x: x, y: y, image: image }
      else
        _render_draw(x, y, image)
      end
    end

    def draw_box(x1, y1, x2, y2, color, z: 0)
      if _has_queue?
        @draw_queue << { type: :draw_box, z: z, x1: x1, y1: y1, x2: x2, y2: y2, color: color }
      else
        _render_draw_box(x1, y1, x2, y2, color)
      end
    end

    def draw_box_fill(x1, y1, x2, y2, color, z: 0)
      if _has_queue?
        @draw_queue << { type: :draw_box_fill, z: z, x1: x1, y1: y1, x2: x2, y2: y2, color: color }
      else
        _render_draw_box_fill(x1, y1, x2, y2, color)
      end
    end

    def draw_font(x, y, str, font_or_color, color_or_size = nil)
      z = 0
      if font_or_color.is_a?(Font)
        opts = color_or_size.is_a?(Hash) ? color_or_size : {}
        z = opts[:z] || 0
      end
      if _has_queue?
        @draw_queue << { type: :draw_font, z: z, x: x, y: y, str: str,
                         font_or_color: font_or_color, color_or_size: color_or_size }
      else
        _render_draw_font(x, y, str, font_or_color, color_or_size)
      end
    end

    def draw_font_ex(x, y, str, font_or_color, options_or_size = nil)
      z = 0
      if font_or_color.is_a?(Font)
        opts = options_or_size.is_a?(Hash) ? options_or_size : {}
        z = opts[:z] || 0
      end
      if _has_queue?
        @draw_queue << { type: :draw_font_ex, z: z, x: x, y: y, str: str,
                         font_or_color: font_or_color, options_or_size: options_or_size }
      else
        _render_draw_font_ex(x, y, str, font_or_color, options_or_size)
      end
    end

    def draw_line(x1, y1, x2, y2, color, z: 0)
      if _has_queue?
        @draw_queue << { type: :draw_line, z: z, x1: x1, y1: y1, x2: x2, y2: y2, color: color }
      else
        _render_draw_line(x1, y1, x2, y2, color)
      end
    end

    def draw_pixel(x, y, color, z: 0)
      if _has_queue?
        @draw_queue << { type: :draw_pixel, z: z, x: x, y: y, color: color }
      else
        _render_draw_pixel(x, y, color)
      end
    end

    def draw_circle(x, y, r, color, z: 0)
      if _has_queue?
        @draw_queue << { type: :draw_circle, z: z, x: x, y: y, r: r, color: color }
      else
        _render_draw_circle(x, y, r, color)
      end
    end

    def draw_circle_fill(x, y, r, color, z: 0)
      if _has_queue?
        @draw_queue << { type: :draw_circle_fill, z: z, x: x, y: y, r: r, color: color }
      else
        _render_draw_circle_fill(x, y, r, color)
      end
    end

    def draw_scale(x, y, image, scale_x, scale_y, cx = nil, cy = nil, z: 0)
      if _has_queue?
        @draw_queue << { type: :draw_scale, z: z, x: x, y: y, image: image,
                         scale_x: scale_x, scale_y: scale_y, cx: cx, cy: cy }
      else
        _render_draw_scale(x, y, image, scale_x, scale_y, cx, cy)
      end
    end

    def draw_rot(x, y, image, angle, cx = nil, cy = nil, z: 0)
      if _has_queue?
        @draw_queue << { type: :draw_rot, z: z, x: x, y: y, image: image,
                         angle: angle, cx: cx, cy: cy }
      else
        _render_draw_rot(x, y, image, angle, cx, cy)
      end
    end

    def draw_alpha(x, y, image, alpha, z: 0)
      if _has_queue?
        @draw_queue << { type: :draw_alpha, z: z, x: x, y: y, image: image, alpha: alpha }
      else
        _render_draw_alpha(x, y, image, alpha)
      end
    end

    def draw_ex(x, y, image, options = {})
      z = options[:z] || 0
      if _has_queue?
        @draw_queue << { type: :draw_ex, z: z, x: x, y: y, image: image, options: options }
      else
        _render_draw_ex(x, y, image, options)
      end
    end

    def draw_add(x, y, image, alpha = 255, z: 0)
      if _has_queue?
        @draw_queue << { type: :draw_add, z: z, x: x, y: y, image: image, alpha: alpha }
      else
        _render_draw_add(x, y, image, alpha)
      end
    end

    def draw_sub(x, y, image, alpha = 255, z: 0)
      if _has_queue?
        @draw_queue << { type: :draw_sub, z: z, x: x, y: y, image: image, alpha: alpha }
      else
        _render_draw_sub(x, y, image, alpha)
      end
    end

    # 4-point perspective warp: corners are (x1,y1)=TL, (x2,y2)=TR, (x3,y3)=BR, (x4,y4)=BL
    # Approximated with two affine-mapped triangles (Canvas 2D has no projective transform).
    # option accepts DXRuby-compatible hash keys: :alpha, :blend, :z, :color
    # (:dividex/:dividey are accepted but ignored — we always use 2-triangle approximation)
    def draw_morph(x1, y1, x2, y2, x3, y3, x4, y4, image, option = nil)
      option ||= {}
      alpha = option[:alpha] || 255
      z     = option[:z]     || 0
      if _has_queue?
        @draw_queue << { type: :draw_morph, z: z,
                         x1: x1, y1: y1, x2: x2, y2: y2,
                         x3: x3, y3: y3, x4: x4, y4: y4,
                         image: image, alpha: alpha }
      else
        _render_draw_morph(x1, y1, x2, y2, x3, y3, x4, y4, image, alpha)
      end
    end

    def draw_tile(x, y, map, chips, offset_x, offset_y, count_x, count_y, z: 0)
      if _has_queue?
        @draw_queue << { type: :draw_tile, z: z, x: x, y: y, map: map, chips: chips,
                         offset_x: offset_x, offset_y: offset_y,
                         count_x: count_x, count_y: count_y }
      else
        _render_draw_tile(x, y, map, chips, offset_x, offset_y, count_x, count_y)
      end
    end

    # -------------------------------------------------------------------------
    # Queue flush — called by Window._tick_with after the user block
    # -------------------------------------------------------------------------

    def _flush_draw_queue
      return unless @draw_queue && !@draw_queue.empty?
      sorted = _stable_sort_by_z(@draw_queue)
      sorted.each { |cmd| _dispatch_render(cmd) }
      @draw_queue = []
    end

    private

    def _has_queue?
      defined?(@draw_queue) && !@draw_queue.nil?
    end

    # Stable insertion sort (ascending z)
    def _stable_sort_by_z(queue)
      sorted = []
      queue.each { |cmd| sorted << cmd }
      n = sorted.length
      i = 1
      while i < n
        key = sorted[i]
        key_z = key[:z] || 0
        j = i - 1
        while j >= 0 && (sorted[j][:z] || 0) > key_z
          sorted[j + 1] = sorted[j]
          j -= 1
        end
        sorted[j + 1] = key
        i += 1
      end
      sorted
    end

    def _dispatch_render(cmd)
      case cmd[:type]
      when :draw
        _render_draw(cmd[:x], cmd[:y], cmd[:image])
      when :draw_box
        _render_draw_box(cmd[:x1], cmd[:y1], cmd[:x2], cmd[:y2], cmd[:color])
      when :draw_box_fill
        _render_draw_box_fill(cmd[:x1], cmd[:y1], cmd[:x2], cmd[:y2], cmd[:color])
      when :draw_font
        _render_draw_font(cmd[:x], cmd[:y], cmd[:str], cmd[:font_or_color], cmd[:color_or_size])
      when :draw_font_ex
        _render_draw_font_ex(cmd[:x], cmd[:y], cmd[:str], cmd[:font_or_color], cmd[:options_or_size])
      when :draw_line
        _render_draw_line(cmd[:x1], cmd[:y1], cmd[:x2], cmd[:y2], cmd[:color])
      when :draw_pixel
        _render_draw_pixel(cmd[:x], cmd[:y], cmd[:color])
      when :draw_circle
        _render_draw_circle(cmd[:x], cmd[:y], cmd[:r], cmd[:color])
      when :draw_circle_fill
        _render_draw_circle_fill(cmd[:x], cmd[:y], cmd[:r], cmd[:color])
      when :draw_scale
        _render_draw_scale(cmd[:x], cmd[:y], cmd[:image], cmd[:scale_x], cmd[:scale_y], cmd[:cx], cmd[:cy])
      when :draw_rot
        _render_draw_rot(cmd[:x], cmd[:y], cmd[:image], cmd[:angle], cmd[:cx], cmd[:cy])
      when :draw_alpha
        _render_draw_alpha(cmd[:x], cmd[:y], cmd[:image], cmd[:alpha])
      when :draw_ex
        _render_draw_ex(cmd[:x], cmd[:y], cmd[:image], cmd[:options])
      when :draw_tile
        _render_draw_tile(cmd[:x], cmd[:y], cmd[:map], cmd[:chips],
                          cmd[:offset_x], cmd[:offset_y], cmd[:count_x], cmd[:count_y])
      when :draw_add
        _render_draw_add(cmd[:x], cmd[:y], cmd[:image], cmd[:alpha])
      when :draw_sub
        _render_draw_sub(cmd[:x], cmd[:y], cmd[:image], cmd[:alpha])
      when :draw_morph
        _render_draw_morph(cmd[:x1], cmd[:y1], cmd[:x2], cmd[:y2],
                           cmd[:x3], cmd[:y3], cmd[:x4], cmd[:y4],
                           cmd[:image], cmd[:alpha])
      end
    end

    # -------------------------------------------------------------------------
    # Immediate rendering primitives (used by _dispatch_render and RenderTarget)
    # -------------------------------------------------------------------------

    def _render_draw(x, y, image)
      @ctx.drawImage(image.canvas, x, y)
    end

    def _render_draw_box(x1, y1, x2, y2, color)
      @ctx[:strokeStyle] = _css(color)
      @ctx.strokeRect(x1, y1, x2 - x1, y2 - y1)
    end

    def _render_draw_box_fill(x1, y1, x2, y2, color)
      @ctx[:fillStyle] = _css(color)
      @ctx.fillRect(x1, y1, x2 - x1, y2 - y1)
    end

    def _render_draw_font(x, y, str, font_or_color, color_or_size = nil)
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

    def _render_draw_font_ex(x, y, str, font_or_color, options_or_size = nil)
      if font_or_color.is_a?(Font)
        font         = font_or_color
        options      = options_or_size.is_a?(Hash) ? options_or_size : {}
        color        = options[:color]        || [255, 255, 255]
        edge_color   = options[:edge_color]
        edge_width   = options[:edge_width]   || 2
        shadow       = options[:shadow]       || false
        shadow_color = options[:shadow_color] || [0, 0, 0]
        shadow_x     = options[:shadow_x]     || 1
        shadow_y     = options[:shadow_y]     || 1
        css_font     = font._css_font
      else
        color        = font_or_color
        size         = options_or_size.is_a?(Integer) ? options_or_size : 16
        edge_color   = nil
        edge_width   = 2
        shadow       = false
        shadow_color = [0, 0, 0]
        shadow_x     = 1
        shadow_y     = 1
        css_font     = "#{size}px monospace"
      end

      @ctx.save
      @ctx[:font]         = css_font
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

    def _render_draw_line(x1, y1, x2, y2, color)
      @ctx.beginPath
      @ctx[:strokeStyle] = _css(color)
      @ctx.moveTo(x1, y1)
      @ctx.lineTo(x2, y2)
      @ctx.stroke
    end

    def _render_draw_pixel(x, y, color)
      @ctx[:fillStyle] = _css(color)
      @ctx.fillRect(x, y, 1, 1)
    end

    def _render_draw_circle(x, y, r, color)
      @ctx.beginPath
      @ctx[:strokeStyle] = _css(color)
      @ctx.arc(x, y, r, 0, 6.283185307179586)
      @ctx.stroke
    end

    def _render_draw_circle_fill(x, y, r, color)
      @ctx.beginPath
      @ctx[:fillStyle] = _css(color)
      @ctx.arc(x, y, r, 0, 6.283185307179586)
      @ctx.fill
    end

    def _render_draw_scale(x, y, image, scale_x, scale_y, cx = nil, cy = nil)
      cx = image.width  / 2 if cx.nil?
      cy = image.height / 2 if cy.nil?
      @ctx.save
      @ctx.translate(x, y)
      @ctx.scale(scale_x, scale_y)
      @ctx.drawImage(image.canvas, -cx, -cy)
      @ctx.restore
    end

    def _render_draw_rot(x, y, image, angle, cx = nil, cy = nil)
      cx = image.width  / 2 if cx.nil?
      cy = image.height / 2 if cy.nil?
      rad = angle * Math::PI / 180.0
      @ctx.save
      @ctx.translate(x, y)
      @ctx.rotate(rad)
      @ctx.drawImage(image.canvas, -cx, -cy)
      @ctx.restore
    end

    def _render_draw_alpha(x, y, image, alpha)
      @ctx.save
      @ctx[:globalAlpha] = alpha.to_f / 255
      @ctx.drawImage(image.canvas, x, y)
      @ctx.restore
    end

    def _render_draw_ex(x, y, image, options = {})
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

    def _render_draw_tile(x, y, map, chips, offset_x, offset_y, count_x, count_y)
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
          @ctx.drawImage(chip._ctx[:canvas], x + col * tw - px_ox, y + row * th - px_oy)
        end
      end
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

    def _render_draw_add(x, y, image, alpha = 255)
      @ctx.save
      @ctx[:globalCompositeOperation] = "lighter"
      @ctx[:globalAlpha] = alpha.to_f / 255 if alpha && alpha != 255
      @ctx.drawImage(image.canvas, x, y)
      @ctx.restore
    end

    def _render_draw_sub(x, y, image, alpha = 255)
      # Canvas 2D has no true subtraction; "difference" gives ABS(dst-src).
      @ctx.save
      @ctx[:globalCompositeOperation] = "difference"
      @ctx[:globalAlpha] = alpha.to_f / 255 if alpha && alpha != 255
      @ctx.drawImage(image.canvas, x, y)
      @ctx.restore
    end

    def _render_draw_morph(x1, y1, x2, y2, x3, y3, x4, y4, image, alpha = 255)
      w = image.width.to_f
      h = image.height.to_f
      src = image.canvas
      @ctx.save
      @ctx[:globalAlpha] = alpha.to_f / 255 if alpha && alpha != 255

      # Triangle 1: TL(x1,y1) TR(x2,y2) BL(x4,y4)  ← image (0,0)(w,0)(0,h)
      @ctx.save
      @ctx.beginPath
      @ctx.moveTo(x1, y1)
      @ctx.lineTo(x2, y2)
      @ctx.lineTo(x4, y4)
      @ctx.closePath
      @ctx.clip
      a1 = (x2 - x1) / w; b1 = (y2 - y1) / w
      c1 = (x4 - x1) / h; d1 = (y4 - y1) / h
      @ctx.transform(a1, b1, c1, d1, x1, y1)
      @ctx.drawImage(src, 0, 0)
      @ctx.restore

      # Triangle 2: TR(x2,y2) BR(x3,y3) BL(x4,y4)  ← image (w,0)(w,h)(0,h)
      @ctx.save
      @ctx.beginPath
      @ctx.moveTo(x2, y2)
      @ctx.lineTo(x3, y3)
      @ctx.lineTo(x4, y4)
      @ctx.closePath
      @ctx.clip
      a2 = (x3 - x4) / w; b2 = (y3 - y4) / w
      c2 = (x3 - x2) / h; d2 = (y3 - y2) / h
      e2 = x4 - x3 + x2;  f2 = y4 - y3 + y2
      @ctx.transform(a2, b2, c2, d2, e2, f2)
      @ctx.drawImage(src, 0, 0)
      @ctx.restore

      @ctx.restore
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
