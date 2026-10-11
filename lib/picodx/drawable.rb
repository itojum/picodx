module PicoDX
  # 色配列を CSS の色文字列に変換する唯一の窓口。
  # 4 要素は DXRuby と同じ [A, R, G, B]、3 要素は [R, G, B]（不透明）。
  def self._css_color(color)
    if color.length == 4
      a, r, g, b = color
      "rgba(#{r},#{g},#{b},#{a.to_f / 255})"
    else
      r, g, b = color
      "rgb(#{r},#{g},#{b})"
    end
  end

  module Drawable
    # -------------------------------------------------------------------------
    # Queue-aware public draw methods
    # Each method pushes a descriptor onto @draw_queue when available
    # (Window), or falls through to the immediate _render_* variant
    # (RenderTarget, which has no queue).
    #
    # z は DXRuby と同じく末尾の位置引数で受け取る（例: draw(x, y, image, z)）。
    # 互換のため z: キーワードも受け付け、両方あれば位置引数を優先する。
    # -------------------------------------------------------------------------

    def draw(x, y, image, pos_z = nil, z: 0)
      z = pos_z unless pos_z.nil?
      _ensure_ready
      if _has_queue?
        @draw_queue << { type: :draw, z: z, x: x, y: y, image: image }
      else
        _render_draw(x, y, image)
      end
    end

    def draw_box(x1, y1, x2, y2, color, pos_z = nil, z: 0)
      z = pos_z unless pos_z.nil?
      _ensure_ready
      if _has_queue?
        @draw_queue << { type: :draw_box, z: z, x1: x1, y1: y1, x2: x2, y2: y2, color: color }
      else
        _render_draw_box(x1, y1, x2, y2, color)
      end
    end

    def draw_box_fill(x1, y1, x2, y2, color, pos_z = nil, z: 0)
      z = pos_z unless pos_z.nil?
      _ensure_ready
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
      _ensure_ready
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
      _ensure_ready
      if _has_queue?
        @draw_queue << { type: :draw_font_ex, z: z, x: x, y: y, str: str,
                         font_or_color: font_or_color, options_or_size: options_or_size }
      else
        _render_draw_font_ex(x, y, str, font_or_color, options_or_size)
      end
    end

    def draw_line(x1, y1, x2, y2, color, pos_z = nil, z: 0)
      z = pos_z unless pos_z.nil?
      _ensure_ready
      if _has_queue?
        @draw_queue << { type: :draw_line, z: z, x1: x1, y1: y1, x2: x2, y2: y2, color: color }
      else
        _render_draw_line(x1, y1, x2, y2, color)
      end
    end

    def draw_pixel(x, y, color, pos_z = nil, z: 0)
      z = pos_z unless pos_z.nil?
      _ensure_ready
      if _has_queue?
        @draw_queue << { type: :draw_pixel, z: z, x: x, y: y, color: color }
      else
        _render_draw_pixel(x, y, color)
      end
    end

    def draw_circle(x, y, r, color, pos_z = nil, z: 0)
      z = pos_z unless pos_z.nil?
      _ensure_ready
      if _has_queue?
        @draw_queue << { type: :draw_circle, z: z, x: x, y: y, r: r, color: color }
      else
        _render_draw_circle(x, y, r, color)
      end
    end

    def draw_circle_fill(x, y, r, color, pos_z = nil, z: 0)
      z = pos_z unless pos_z.nil?
      _ensure_ready
      if _has_queue?
        @draw_queue << { type: :draw_circle_fill, z: z, x: x, y: y, r: r, color: color }
      else
        _render_draw_circle_fill(x, y, r, color)
      end
    end

    def draw_scale(x, y, image, scale_x, scale_y, cx = nil, cy = nil, pos_z = nil, z: 0)
      z = pos_z unless pos_z.nil?
      _ensure_ready
      if _has_queue?
        @draw_queue << { type: :draw_scale, z: z, x: x, y: y, image: image,
                         scale_x: scale_x, scale_y: scale_y, cx: cx, cy: cy }
      else
        _render_draw_scale(x, y, image, scale_x, scale_y, cx, cy)
      end
    end

    def draw_rot(x, y, image, angle, cx = nil, cy = nil, pos_z = nil, z: 0)
      z = pos_z unless pos_z.nil?
      _ensure_ready
      if _has_queue?
        @draw_queue << { type: :draw_rot, z: z, x: x, y: y, image: image,
                         angle: angle, cx: cx, cy: cy }
      else
        _render_draw_rot(x, y, image, angle, cx, cy)
      end
    end

    def draw_alpha(x, y, image, alpha, pos_z = nil, z: 0)
      z = pos_z unless pos_z.nil?
      _ensure_ready
      if _has_queue?
        @draw_queue << { type: :draw_alpha, z: z, x: x, y: y, image: image, alpha: alpha }
      else
        _render_draw_alpha(x, y, image, alpha)
      end
    end

    def draw_ex(x, y, image, options = {})
      z = options[:z] || 0
      _ensure_ready
      if _has_queue?
        @draw_queue << { type: :draw_ex, z: z, x: x, y: y, image: image, options: options }
      else
        _render_draw_ex(x, y, image, options)
      end
    end

    def draw_add(x, y, image, pos_z = nil, z: 0)
      z = pos_z unless pos_z.nil?
      _ensure_ready
      if _has_queue?
        @draw_queue << { type: :draw_add, z: z, x: x, y: y, image: image }
      else
        _render_draw_add(x, y, image)
      end
    end

    def draw_sub(x, y, image, pos_z = nil, z: 0)
      z = pos_z unless pos_z.nil?
      _ensure_ready
      if _has_queue?
        @draw_queue << { type: :draw_sub, z: z, x: x, y: y, image: image }
      else
        _render_draw_sub(x, y, image)
      end
    end

    # draw_morph: 2画像間の線形補間（rate: 0.0=image1のみ, 1.0=image2のみ）
    # DXRubyの4コーナー変換とは異なり、Canvas 2D でのアルファブレンドで近似する
    def draw_morph(x, y, image1, image2, rate, pos_z = nil, z: 0)
      z = pos_z unless pos_z.nil?
      _ensure_ready
      if _has_queue?
        @draw_queue << { type: :draw_morph, z: z, x: x, y: y, image1: image1, image2: image2, rate: rate }
      else
        _render_draw_morph(x, y, image1, image2, rate)
      end
    end

    def draw_tile(x, y, map, chips, offset_x, offset_y, count_x, count_y, pos_z = nil, z: 0)
      z = pos_z unless pos_z.nil?
      _ensure_ready
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

    # 描画先の準備が必要なら行うフック。Window は未接続なら canvas に自動接続する。
    def _ensure_ready
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
      when :draw_add
        _render_draw_add(cmd[:x], cmd[:y], cmd[:image])
      when :draw_sub
        _render_draw_sub(cmd[:x], cmd[:y], cmd[:image])
      when :draw_morph
        _render_draw_morph(cmd[:x], cmd[:y], cmd[:image1], cmd[:image2], cmd[:rate])
      when :draw_tile
        _render_draw_tile(cmd[:x], cmd[:y], cmd[:map], cmd[:chips],
                          cmd[:offset_x], cmd[:offset_y], cmd[:count_x], cmd[:count_y])
      end
    end

    # -------------------------------------------------------------------------
    # Immediate rendering primitives (used by _dispatch_render and RenderTarget)
    # -------------------------------------------------------------------------

    def _render_draw(x, y, image)
      @ctx.drawImage(image._canvas, x, y)
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

    # DXRuby の座標系: (x, y) は変形前の画像の左上、(cx, cy) は画像内の
    # 拡縮・回転の中心（既定は画像中央）。
    def _render_draw_scale(x, y, image, scale_x, scale_y, cx = nil, cy = nil)
      cx = image.width  / 2 if cx.nil?
      cy = image.height / 2 if cy.nil?
      @ctx.save
      @ctx.translate(x + cx, y + cy)
      @ctx.scale(scale_x, scale_y)
      @ctx.drawImage(image._canvas, -cx, -cy)
      @ctx.restore
    end

    def _render_draw_rot(x, y, image, angle, cx = nil, cy = nil)
      cx = image.width  / 2 if cx.nil?
      cy = image.height / 2 if cy.nil?
      rad = angle * Math::PI / 180.0
      @ctx.save
      @ctx.translate(x + cx, y + cy)
      @ctx.rotate(rad)
      @ctx.drawImage(image._canvas, -cx, -cy)
      @ctx.restore
    end

    def _render_draw_alpha(x, y, image, alpha)
      @ctx.save
      @ctx[:globalAlpha] = alpha.to_f / 255
      @ctx.drawImage(image._canvas, x, y)
      @ctx.restore
    end

    def _render_draw_ex(x, y, image, options = {})
      angle   = options[:angle]   || 0
      scale_x = options[:scale_x] || 1.0
      scale_y = options[:scale_y] || 1.0
      alpha   = options[:alpha]
      blend   = options[:blend]
      return if alpha && alpha <= 0
      w = image.width
      h = image.height

      if angle == 0 && scale_x == 1 && scale_y == 1
        return unless _on_screen?(x, y, x + w, y + h)
        # 変形・半透明・合成なしなら save / restore を省いて drawImage 1 回で描く
        if (alpha.nil? || alpha >= 255) && (blend.nil? || blend == :alpha)
          @ctx.drawImage(image._canvas, x, y)
          return
        end
      end

      cx = options[:cx] || w / 2
      cy = options[:cy] || h / 2
      rad = angle * Math::PI / 180.0
      if angle == 0 && scale_x == 1 && scale_y == 1
        bounds = blend == :sub ? [x, y, x + w, y + h] : nil
      else
        bounds = _transformed_bounds(x + cx, y + cy, -cx * scale_x, -cy * scale_y,
                                     (w - cx) * scale_x, (h - cy) * scale_y, rad)
        return unless _on_screen?(bounds[0], bounds[1], bounds[2], bounds[3])
      end

      # 減算は「反転 → 加算 → 反転」で表す（_invert_rect のコメント参照）
      _invert_rect(bounds) if blend == :sub
      @ctx.save
      @ctx[:globalCompositeOperation] = _blend_op(blend) if blend
      @ctx[:globalAlpha] = alpha.to_f / 255 if alpha
      @ctx.translate(x + cx, y + cy)
      @ctx.rotate(rad)
      @ctx.scale(scale_x, scale_y)
      @ctx.drawImage(image._canvas, -cx, -cy)
      @ctx.restore
      _invert_rect(bounds) if blend == :sub
    end

    def _render_draw_add(x, y, image)
      @ctx.save
      @ctx[:globalCompositeOperation] = "lighter"
      @ctx.drawImage(image._canvas, x, y)
      @ctx.restore
    end

    def _render_draw_sub(x, y, image)
      bounds = [x, y, x + image.width, y + image.height]
      _invert_rect(bounds)
      @ctx.save
      @ctx[:globalCompositeOperation] = "lighter"
      @ctx.drawImage(image._canvas, x, y)
      @ctx.restore
      _invert_rect(bounds)
    end

    # Canvas 2D には減算合成がないので、描画範囲を反転してから加算し、もう一度反転する。
    #   1 - min(1, (1 - dst) + src) = max(0, dst - src)
    # 反転は白の difference 合成（|1 - dst| = 1 - dst）で行う。範囲は描画先のピクセル境界
    # （平行移動を足した座標）で整数に広げて、端のピクセルが半端に反転されないようにする
    # （ox / oy が小数でもずれない）。範囲内の描画先は不透明になる。
    def _invert_rect(bounds)
      vx = _view_ox
      vy = _view_oy
      x1 = (bounds[0] + vx).floor - vx
      y1 = (bounds[1] + vy).floor - vy
      x2 = (bounds[2] + vx).ceil  - vx
      y2 = (bounds[3] + vy).ceil  - vy
      @ctx.save
      @ctx[:globalCompositeOperation] = "difference"
      @ctx[:fillStyle] = "#fff"
      @ctx.fillRect(x1, y1, x2 - x1, y2 - y1)
      @ctx.restore
    end

    def _render_draw_morph(x, y, image1, image2, rate)
      r = rate.to_f
      w = [image1.width,  image2.width ].max
      h = [image1.height, image2.height].max
      if @_morph_canvas.nil? || @_morph_canvas[:width].to_i != w || @_morph_canvas[:height].to_i != h
        @_morph_canvas = JS.eval("new OffscreenCanvas(#{w}, #{h})")
        @_morph_ctx    = @_morph_canvas.getContext('2d')
      end
      @_morph_ctx.clearRect(0, 0, w, h)
      @_morph_ctx[:globalCompositeOperation] = "source-over"
      @_morph_ctx[:globalAlpha] = 1.0 - r
      @_morph_ctx.drawImage(image1._canvas, 0, 0)
      @_morph_ctx[:globalCompositeOperation] = "lighter"
      @_morph_ctx[:globalAlpha] = r
      @_morph_ctx.drawImage(image2._canvas, 0, 0)
      @_morph_ctx[:globalCompositeOperation] = "source-over"
      @_morph_ctx[:globalAlpha] = 1.0
      @ctx.drawImage(@_morph_canvas, x, y)
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
          @ctx.drawImage(chip._canvas, x + col * tw - px_ox, y + row * th - px_oy)
        end
      end
    end

    # 描画範囲 (x1, y1)-(x2, y2) が描画先に少しでも掛かるか（画面外の描画を省くため）
    def _on_screen?(x1, y1, x2, y2)
      w = @width
      h = @height
      return true if w.nil? || h.nil?
      ox = _view_ox
      oy = _view_oy
      x2 + ox > 0 && x1 + ox < w && y2 + oy > 0 && y1 + oy < h
    end

    # 中心 (px, py) まわりに拡縮済みの矩形 (ax1, ay1)-(ax2, ay2) を rad だけ回転したときの
    # 外接矩形 [x1, y1, x2, y2]
    def _transformed_bounds(px, py, ax1, ay1, ax2, ay2, rad)
      c = Math.cos(rad)
      s = Math.sin(rad)
      x_a = ax1 * c; x_b = ax2 * c; y_a = ay1 * s; y_b = ay2 * s
      min_x = (x_a < x_b ? x_a : x_b) - (y_a > y_b ? y_a : y_b)
      max_x = (x_a > x_b ? x_a : x_b) - (y_a < y_b ? y_a : y_b)
      x_a = ax1 * s; x_b = ax2 * s; y_a = ay1 * c; y_b = ay2 * c
      min_y = (x_a < x_b ? x_a : x_b) + (y_a < y_b ? y_a : y_b)
      max_y = (x_a > x_b ? x_a : x_b) + (y_a > y_b ? y_a : y_b)
      [px + min_x, py + min_y, px + max_x, py + max_y]
    end

    # 描画時に掛かっている平行移動量。Window はループ内で (ox, oy) だけずらして描く
    def _view_ox
      0
    end

    def _view_oy
      0
    end

    def _css(color)
      PicoDX._css_color(color)
    end

    def _blend_op(blend)
      case blend
      when :add then "lighter"
      when :sub then "lighter"  # 前後で描画範囲を反転して減算にする（_invert_rect）
      else "source-over"
      end
    end
  end
end
