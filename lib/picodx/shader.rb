module PicoDX
  # Shader / Shader::Core are HLSL-based and cannot be implemented on Canvas 2D.
  # All methods raise NotImplementedError. See docs/compatibility.md for details.
  class Shader
    NOT_IMPLEMENTED = "Shader is not supported on the Canvas 2D backend (picodx). See docs/compatibility.md"

    def initialize(*_); raise NotImplementedError, NOT_IMPLEMENTED; end
    def [](*_);         raise NotImplementedError, NOT_IMPLEMENTED; end
    def []=(*_);        raise NotImplementedError, NOT_IMPLEMENTED; end

    class Core
      def initialize(*) = raise NotImplementedError, Shader::NOT_IMPLEMENTED
    end
  end
end
