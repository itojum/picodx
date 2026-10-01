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
      cx = center_x || (image.width  / 2)
      cy = center_y || (image.height / 2)
      t  = target || Window
      t.draw_ex(x.to_i, y.to_i, image, {
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
      img = image
      ecx = center_x || (img ? img.width  / 2 : 0)
      ecy = center_y || (img ? img.height / 2 : 0)
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
      return [] if vanished? || collision.nil? || !collision_enable
      targets = other.is_a?(Array) ? other : [other]
      result = []
      targets.each do |sp|
        next if sp.nil? || sp.vanished? || sp.collision.nil? || !sp.collision_enable
        result << sp if _collide?(sp)
      end
      result
    end

    def ===(other)
      return false if vanished? || collision.nil? || !collision_enable
      return false if other.nil? || other.vanished? || other.collision.nil? || !other.collision_enable
      _collide?(other)
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
        array_a.each do |a|
          next if a.nil? || a.vanished?
          hits = a.check(array_b)
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

    private

    def _collide?(other)
      aox = offset_sync       ? -(center_x || 0) : 0
      aoy = offset_sync       ? -(center_y || 0) : 0
      box = other.offset_sync ? -(other.center_x || 0) : 0
      boy = other.offset_sync ? -(other.center_y || 0) : 0
      ac = _scaled_collision(self, collision)
      bc = _scaled_collision(other, other.collision)
      al = ac.length
      bl = bc.length

      if al == 4
        ax1 = x + aox + ac[0]; ay1 = y + aoy + ac[1]
        ax2 = x + aox + ac[2]; ay2 = y + aoy + ac[3]
      elsif al == 3
        acx = x + aox + ac[0]; acy = y + aoy + ac[1]; ar = ac[2]
      else
        apx = x + aox + ac[0]; apy = y + aoy + ac[1]
      end

      if bl == 4
        bx1 = other.x + box + bc[0]; by1 = other.y + boy + bc[1]
        bx2 = other.x + box + bc[2]; by2 = other.y + boy + bc[3]
      elsif bl == 3
        bcx = other.x + box + bc[0]; bcy = other.y + boy + bc[1]; br = bc[2]
      else
        bpx = other.x + box + bc[0]; bpy = other.y + boy + bc[1]
      end

      if al == 4 && bl == 4
        ax1 < bx2 && ax2 > bx1 && ay1 < by2 && ay2 > by1
      elsif al == 4 && bl == 3
        _rect_circle?(ax1, ay1, ax2, ay2, bcx, bcy, br)
      elsif al == 4 && bl == 2
        bpx >= ax1 && bpx <= ax2 && bpy >= ay1 && bpy <= ay2
      elsif al == 3 && bl == 4
        _rect_circle?(bx1, by1, bx2, by2, acx, acy, ar)
      elsif al == 3 && bl == 3
        dx = acx - bcx; dy = acy - bcy; sr = ar + br
        dx * dx + dy * dy <= sr * sr
      elsif al == 3 && bl == 2
        dx = bpx - acx; dy = bpy - acy
        dx * dx + dy * dy <= ar * ar
      elsif al == 2 && bl == 4
        apx >= bx1 && apx <= bx2 && apy >= by1 && apy <= by2
      elsif al == 2 && bl == 3
        dx = apx - bcx; dy = apy - bcy
        dx * dx + dy * dy <= br * br
      else
        apx == bpx && apy == bpy
      end
    end

    def _rect_circle?(rx1, ry1, rx2, ry2, cx, cy, r)
      dx = cx < rx1 ? rx1 - cx : (cx > rx2 ? cx - rx2 : 0)
      dy = cy < ry1 ? ry1 - cy : (cy > ry2 ? cy - ry2 : 0)
      dx * dx + dy * dy <= r * r
    end

    def _scaled_collision(sp, c)
      return c unless sp.collision_sync
      sx    = sp.scale_x
      sy    = sp.scale_y
      angle = sp.angle
      origin_x = sp.center_x || (sp.image ? sp.image.width / 2.0 : 0.0)
      origin_y = sp.center_y || (sp.image ? sp.image.height / 2.0 : 0.0)
      rad      = angle * Math::PI / 180.0
      cos_a    = Math.cos(rad)
      sin_a    = Math.sin(rad)

      transform_point = lambda do |px, py|
        dx = px - origin_x
        dy = py - origin_y
        [
          origin_x + dx * sx * cos_a - dy * sy * sin_a,
          origin_y + dx * sx * sin_a + dy * sy * cos_a
        ]
      end

      if c.length == 4
        p1 = transform_point.call(c[0], c[1])
        p2 = transform_point.call(c[0], c[3])
        p3 = transform_point.call(c[2], c[1])
        p4 = transform_point.call(c[2], c[3])
        xs = [p1[0], p2[0], p3[0], p4[0]]
        ys = [p1[1], p2[1], p3[1], p4[1]]
        [xs.min, ys.min, xs.max, ys.max]
      elsif c.length == 3
        pcx, pcy = transform_point.call(c[0], c[1])
        scale = sx.abs > sy.abs ? sx.abs : sy.abs
        [pcx, pcy, c[2] * scale]
      else
        transform_point.call(c[0], c[1])
      end
    end
  end
end
