module PicoDX
  class Sprite
    attr_accessor :x, :y, :z, :angle, :scale_x, :scale_y, :center_x, :center_y
    attr_accessor :alpha, :blend, :visible, :image, :collision, :target

    def initialize(x = 0, y = 0, image = nil)
      @x        = x.to_f
      @y        = y.to_f
      @z        = 0
      @angle    = 0
      @scale_x  = 1.0
      @scale_y  = 1.0
      @center_x = nil
      @center_y = nil
      @alpha    = 255
      @blend    = :alpha
      @visible  = true
      @image    = image
      @collision = nil
      @vanished  = false
      @target    = nil
    end

    def draw
      return if @vanished || !@visible || @image.nil?
      cx = @center_x || (@image.width  / 2)
      cy = @center_y || (@image.height / 2)
      t  = @target || Window
      t.draw_ex(@x.to_i, @y.to_i, @image, {
        angle:   @angle,
        scale_x: @scale_x,
        scale_y: @scale_y,
        alpha:   @alpha,
        cx:      cx,
        cy:      cy,
        blend:   @blend
      })
    end

    def update
    end

    def vanish
      @vanished = true
    end

    def vanished?
      @vanished
    end

    def check(other)
      return [] if @vanished || @collision.nil?
      targets = other.is_a?(Array) ? other : [other]
      result = []
      targets.each do |sp|
        next if sp.nil? || sp.vanished? || sp.collision.nil?
        result << sp if _collide?(sp)
      end
      result
    end

    def ===(other)
      return false if @vanished || @collision.nil?
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
      ac = @collision
      bc = other.collision
      al = ac.length
      bl = bc.length

      if al == 4
        ax1 = @x + ac[0]; ay1 = @y + ac[1]
        ax2 = @x + ac[2]; ay2 = @y + ac[3]
      elsif al == 3
        acx = @x + ac[0]; acy = @y + ac[1]; ar = ac[2]
      else
        apx = @x + ac[0]; apy = @y + ac[1]
      end

      if bl == 4
        bx1 = other.x + bc[0]; by1 = other.y + bc[1]
        bx2 = other.x + bc[2]; by2 = other.y + bc[3]
      elsif bl == 3
        bcx = other.x + bc[0]; bcy = other.y + bc[1]; br = bc[2]
      else
        bpx = other.x + bc[0]; bpy = other.y + bc[1]
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
  end
end
