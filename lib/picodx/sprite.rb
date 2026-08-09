module PicoDX
  class Sprite
    attr_accessor :x, :y, :z, :angle, :scale_x, :scale_y, :center_x, :center_y
    attr_accessor :alpha, :blend, :visible, :image, :collision, :target, :offset_sync

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
      @vanished    = false
      @target      = nil
      @offset_sync = false
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
      aox = @offset_sync       ? -(@center_x || 0) : 0
      aoy = @offset_sync       ? -(@center_y || 0) : 0
      box = other.offset_sync  ? -(other.center_x || 0) : 0
      boy = other.offset_sync  ? -(other.center_y || 0) : 0

      ax1 = @x + aox + @collision[0]
      ay1 = @y + aoy + @collision[1]
      ax2 = @x + aox + @collision[2]
      ay2 = @y + aoy + @collision[3]
      bx1 = other.x + box + other.collision[0]
      by1 = other.y + boy + other.collision[1]
      bx2 = other.x + box + other.collision[2]
      by2 = other.y + boy + other.collision[3]
      ax1 < bx2 && ax2 > bx1 && ay1 < by2 && ay2 > by1
    end
  end
end
