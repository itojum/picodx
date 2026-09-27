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
      @x              = x.to_f
      @y              = y.to_f
      @z              = 0
      @angle          = 0
      @scale_x        = 1.0
      @scale_y        = 1.0
      @center_x       = nil
      @center_y       = nil
      @alpha          = 255
      @blend          = :alpha
      @visible        = true
      @image          = image
      @collision      = nil
      @vanished       = false
      @target         = nil
      @offset_sync    = false
      @collision_sync = true
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

    def check(other)
      return [] if vanished? || collision.nil?
      targets = other.is_a?(Array) ? other : [other]
      result = []
      targets.each do |sp|
        next if sp.nil? || sp.vanished? || sp.collision.nil?
        result << sp if _collide?(sp)
      end
      result
    end

    def ===(other)
      return false if vanished? || collision.nil?
      return false if other.nil? || other.vanished? || other.collision.nil?
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
      ac = collision
      bc = other.collision

      if collision_sync
        ac  = _collide_transform(ac, aox, aoy, scale_x, scale_y, angle)
        aox = 0; aoy = 0
      end
      if other.collision_sync
        bc  = _collide_transform(bc, box, boy, other.scale_x, other.scale_y, other.angle)
        box = 0; boy = 0
      end

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

    # Applies offset_sync offset (ox, oy) and collision_sync scale/rotation to
    # collision array c. Returns a new array in the same format with values as
    # offsets from the sprite's screen (x, y) position.
    # The transform origin is the sprite's (x, y) screen position, which
    # corresponds to center_x/center_y in image space (same pivot as draw).
    def _collide_transform(c, ox, oy, sx, sy, ang)
      if ang == 0 && sx == 1.0 && sy == 1.0
        return c if ox == 0 && oy == 0
        l = c.length
        return l == 4 ? [c[0]+ox, c[1]+oy, c[2]+ox, c[3]+oy] :
               l == 3 ? [c[0]+ox, c[1]+oy, c[2]] :
                        [c[0]+ox, c[1]+oy]
      end

      if ang == 0
        l = c.length
        if l == 4
          x1 = (c[0]+ox)*sx; y1 = (c[1]+oy)*sy
          x2 = (c[2]+ox)*sx; y2 = (c[3]+oy)*sy
          [x1 < x2 ? x1 : x2, y1 < y2 ? y1 : y2,
           x1 < x2 ? x2 : x1, y1 < y2 ? y2 : y1]
        elsif l == 3
          sr = c[2] * (sx.abs > sy.abs ? sx.abs : sy.abs)
          [(c[0]+ox)*sx, (c[1]+oy)*sy, sr]
        else
          [(c[0]+ox)*sx, (c[1]+oy)*sy]
        end
      else
        rad   = ang * Math::PI / 180.0
        cos_a = Math.cos(rad)
        sin_a = Math.sin(rad)
        l = c.length
        if l == 4
          ax = (c[0]+ox)*sx; ay = (c[1]+oy)*sy
          bx = (c[2]+ox)*sx; by = (c[3]+oy)*sy
          r0x = ax*cos_a - ay*sin_a; r0y = ax*sin_a + ay*cos_a
          r1x = bx*cos_a - ay*sin_a; r1y = bx*sin_a + ay*cos_a
          r2x = bx*cos_a - by*sin_a; r2y = bx*sin_a + by*cos_a
          r3x = ax*cos_a - by*sin_a; r3y = ax*sin_a + by*cos_a
          mn_x = r0x; mx_x = r0x; mn_y = r0y; mx_y = r0y
          mn_x = r1x if r1x < mn_x; mx_x = r1x if r1x > mx_x
          mn_y = r1y if r1y < mn_y; mx_y = r1y if r1y > mx_y
          mn_x = r2x if r2x < mn_x; mx_x = r2x if r2x > mx_x
          mn_y = r2y if r2y < mn_y; mx_y = r2y if r2y > mx_y
          mn_x = r3x if r3x < mn_x; mx_x = r3x if r3x > mx_x
          mn_y = r3y if r3y < mn_y; mx_y = r3y if r3y > mx_y
          [mn_x, mn_y, mx_x, mx_y]
        elsif l == 3
          px = (c[0]+ox)*sx; py = (c[1]+oy)*sy
          sr = c[2] * (sx.abs > sy.abs ? sx.abs : sy.abs)
          [px*cos_a - py*sin_a, px*sin_a + py*cos_a, sr]
        else
          px = (c[0]+ox)*sx; py = (c[1]+oy)*sy
          [px*cos_a - py*sin_a, px*sin_a + py*cos_a]
        end
      end
    end
  end
end
