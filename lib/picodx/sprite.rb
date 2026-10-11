module PicoDX
  class Sprite
    attr_writer :x, :y, :z, :angle, :scale_x, :scale_y, :center_x, :center_y
    attr_writer :alpha, :blend, :visible, :image, :collision, :target, :offset_sync
    attr_writer :collision_sync

    def x;              @x              || 0;      end
    def y;              @y              || 0;      end
    def z;              @z              || 0;      end
    def angle;          @angle          || 0;      end
    def scale_x;        @scale_x        || 1.0;    end
    def scale_y;        @scale_y        || 1.0;    end
    def center_x;       @center_x;                end
    def center_y;       @center_y;                end
    def alpha;          @alpha          || 255;    end
    def blend;          @blend          || :alpha; end
    def visible;        @visible.nil? ? true : @visible; end
    def image;          @image;                    end
    def collision;      @collision;                end
    def target;         @target;                   end
    def offset_sync;    @offset_sync    || false;  end
    def collision_sync; @collision_sync.nil? ? true : @collision_sync; end

    def initialize(x = 0, y = 0, image = nil)
      @x           = x.to_f
      @y           = y.to_f
      @z           = 0
      @angle       = 0
      @scale_x     = 1.0
      @scale_y     = 1.0
      @center_x    = nil
      @center_y    = nil
      @alpha       = 255
      @blend       = :alpha
      @visible     = true
      @image       = image
      @collision   = nil
      @vanished          = false
      @target            = nil
      @offset_sync       = false
      @collision_enable  = true
      @collision_sync    = nil
    end

    def draw
      return if @vanished || !visible || image.nil?
      cx = _center_x
      cy = _center_y
      dx = offset_sync ? x - cx : x
      dy = offset_sync ? y - cy : y
      t  = target || Window
      t.draw_ex(dx.to_i, dy.to_i, image, {
        z:       z,
        angle:   angle,
        scale_x: scale_x,
        scale_y: scale_y,
        alpha:   alpha,
        cx:      cx,
        cy:      cy,
        blend:   blend
      })
    end

    def update
    end

    def vanish
      @vanished = true
    end

    def vanished?
      @vanished || false
    end

    def collision_enable
      @collision_enable.nil? ? true : @collision_enable
    end

    def collision_enable=(val)
      @collision_enable = val
    end

    def collision_sync
      @collision_sync.nil? ? true : @collision_sync
    end

    def collision_sync=(val)
      @collision_sync = val
    end

    def param_hash
      ecx = _center_x
      ecy = _center_y
      {
        x: x, y: y, z: z,
        angle: angle,
        scale_x: scale_x, scale_y: scale_y,
        cx: ecx, cy: ecy,
        alpha: alpha, blend: blend,
        visible: visible,
        collision: collision,
        collision_enable: collision_enable
      }
    end

    def check(other)
      targets = other.is_a?(Array) ? other : [other]
      _check_against(targets, nil)
    end

    def ===(other)
      return false if other.nil?
      a = _world_shape(self)
      return false if a.nil?
      b = _world_shape(other)
      return false if b.nil?
      _shapes_hit?(a, b)
    end

    class << self
      def update(array)
        array.each { |sp| sp.update if sp && !sp.vanished? }
      end

      def draw(array)
        sorted = _insertion_sort_by_z(array)
        sorted.each do |sp|
          sp.draw if sp && !sp.vanished?
        end
      end

      def check(array_a, array_b)
        results = []
        shapes_b = nil
        array_a.each do |a|
          next if a.nil? || a.vanished?
          # array_b の判定範囲はすべての a で共通なので 1 回だけ求める
          # （PicoRuby には protected がないため、private の計算を __send__ で呼ぶ）
          shapes_b ||= a.__send__(:_world_shapes, array_b)
          hits = a.__send__(:_check_against, array_b, shapes_b)
          results << [a, hits] unless hits.empty?
        end
        results
      end

      def clean(array)
        i = array.length - 1
        while i >= 0
          sp = array[i]
          array.delete_at(i) if sp.nil? || sp.vanished?
          i -= 1
        end
        array
      end

      private

      def _insertion_sort_by_z(array)
        sorted = []
        array.each { |sp| sorted << sp }
        n = sorted.length
        i = 1
        while i < n
          key   = sorted[i]
          key_z = key ? key.z : 0
          j = i - 1
          while j >= 0 && (sorted[j] ? sorted[j].z : 0) > key_z
            sorted[j + 1] = sorted[j]
            j -= 1
          end
          sorted[j + 1] = key
          i += 1
        end
        sorted
      end
    end

    # center_x / center_y が nil のときの実効値（画像中央、画像がなければ 0）
    def _center_x
      center_x || (image ? image.width  / 2 : 0)
    end

    def _center_y
      center_y || (image ? image.height / 2 : 0)
    end

    private

    # collision 未設定なら画像全体を判定範囲にする（画像もなければ nil）
    def _collision(sp)
      c = sp.collision
      return c if c
      img = sp.image
      img ? [0, 0, img.width, img.height] : nil
    end

    def _check_against(targets, shapes)
      result = []
      mine = _world_shape(self)
      return result if mine.nil?
      i = 0
      n = targets.length
      while i < n
        sp = targets[i]
        if sp
          other = shapes ? shapes[i] : _world_shape(sp)
          result << sp if other && _shapes_hit?(mine, other)
        end
        i += 1
      end
      result
    end

    def _world_shapes(sprites)
      sprites.map { |sp| sp ? _world_shape(sp) : nil }
    end

    # 判定範囲をワールド座標で返す。判定しない Sprite は nil。
    #   矩形 [x1, y1, x2, y2] / 円 [cx, cy, r] / 点 [px, py]
    # collision_sync が真なら、中心まわりに拡縮・回転する（矩形は外接矩形で近似）
    def _world_shape(sp)
      return nil if sp.vanished? || !sp.collision_enable
      c = _collision(sp)
      return nil if c.nil?

      cx = sp._center_x
      cy = sp._center_y
      bx = sp.x
      by = sp.y
      if sp.offset_sync
        bx -= cx
        by -= cy
      end

      sx = 1
      sy = 1
      angle = 0
      if sp.collision_sync
        sx = sp.scale_x
        sy = sp.scale_y
        angle = sp.angle
      end

      if angle == 0 && sx == 1 && sy == 1
        if c.length == 4
          return [bx + c[0], by + c[1], bx + c[2], by + c[3]]
        elsif c.length == 3
          return [bx + c[0], by + c[1], c[2]]
        else
          return [bx + c[0], by + c[1]]
        end
      end

      # 中心 (cx, cy) まわりに拡縮してから回転する
      ox = bx + cx
      oy = by + cy
      if angle == 0
        cos_a = 1.0
        sin_a = 0.0
      else
        rad   = angle * Math::PI / 180.0
        cos_a = Math.cos(rad)
        sin_a = Math.sin(rad)
      end

      if c.length == 4
        # 拡縮後の矩形 (u1..u2, v1..v2) を回転した外接矩形
        u1 = (c[0] - cx) * sx; u2 = (c[2] - cx) * sx
        v1 = (c[1] - cy) * sy; v2 = (c[3] - cy) * sy
        xa = u1 * cos_a; xb = u2 * cos_a; ya = v1 * sin_a; yb = v2 * sin_a
        min_x = (xa < xb ? xa : xb) - (ya > yb ? ya : yb)
        max_x = (xa > xb ? xa : xb) - (ya < yb ? ya : yb)
        xa = u1 * sin_a; xb = u2 * sin_a; ya = v1 * cos_a; yb = v2 * cos_a
        min_y = (xa < xb ? xa : xb) + (ya < yb ? ya : yb)
        max_y = (xa > xb ? xa : xb) + (ya > yb ? ya : yb)
        [ox + min_x, oy + min_y, ox + max_x, oy + max_y]
      else
        u = (c[0] - cx) * sx
        v = (c[1] - cy) * sy
        px = ox + u * cos_a - v * sin_a
        py = oy + u * sin_a + v * cos_a
        if c.length == 3
          asx = sx < 0 ? -sx : sx
          asy = sy < 0 ? -sy : sy
          [px, py, c[2] * (asx > asy ? asx : asy)]
        else
          [px, py]
        end
      end
    end

    def _shapes_hit?(a, b)
      al = a.length
      bl = b.length
      if al == 4
        if bl == 4
          a[0] < b[2] && a[2] > b[0] && a[1] < b[3] && a[3] > b[1]
        elsif bl == 3
          _rect_circle?(a[0], a[1], a[2], a[3], b[0], b[1], b[2])
        else
          b[0] >= a[0] && b[0] <= a[2] && b[1] >= a[1] && b[1] <= a[3]
        end
      elsif al == 3
        if bl == 4
          _rect_circle?(b[0], b[1], b[2], b[3], a[0], a[1], a[2])
        elsif bl == 3
          dx = a[0] - b[0]; dy = a[1] - b[1]; sr = a[2] + b[2]
          dx * dx + dy * dy <= sr * sr
        else
          dx = b[0] - a[0]; dy = b[1] - a[1]
          dx * dx + dy * dy <= a[2] * a[2]
        end
      else
        if bl == 4
          a[0] >= b[0] && a[0] <= b[2] && a[1] >= b[1] && a[1] <= b[3]
        elsif bl == 3
          dx = a[0] - b[0]; dy = a[1] - b[1]
          dx * dx + dy * dy <= b[2] * b[2]
        else
          a[0] == b[0] && a[1] == b[1]
        end
      end
    end

    def _rect_circle?(rx1, ry1, rx2, ry2, cx, cy, r)
      dx = cx < rx1 ? rx1 - cx : (cx > rx2 ? cx - rx2 : 0)
      dy = cy < ry1 ? ry1 - cy : (cy > ry2 ? cy - ry2 : 0)
      dx * dx + dy * dy <= r * r
    end
  end
end
