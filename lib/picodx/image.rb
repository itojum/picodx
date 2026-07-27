module PicoDX
  class Image
    attr_reader :width, :height, :color

    def initialize(width, height, color = [0, 0, 0])
      @width  = width
      @height = height
      @color  = color
    end
  end
end
