module PicoDX
  class Shader
    def initialize(*) = raise NotImplementedError, "Shader is not supported in PicoDX (Canvas 2D backend)"
    class Core
      def initialize(*) = raise NotImplementedError, "Shader::Core is not supported in PicoDX (Canvas 2D backend)"
    end
  end

  class Window
    class << self
      def hWnd             = raise NotImplementedError, "Window.hWnd is not supported (desktop-only API)"
      def get_screen_modes = raise NotImplementedError, "Window.get_screen_modes is not supported (desktop-only API)"
      def get_current_modes = raise NotImplementedError, "Window.get_current_modes is not supported (desktop-only API)"
      def load_icon(*)     = raise NotImplementedError, "Window.load_icon is not supported (desktop-only API)"
      def open_filename(*) = raise NotImplementedError, "Window.open_filename is not supported (desktop-only API)"
      def save_filename(*) = raise NotImplementedError, "Window.save_filename is not supported (desktop-only API)"
      def folder_dialog(*) = raise NotImplementedError, "Window.folder_dialog is not supported (desktop-only API)"
      def draw_shader(*)   = raise NotImplementedError, "Window.draw_shader is not supported (HLSL shader not available in Canvas 2D)"

      def full_screen=(*)
        raise NotImplementedError, "Window.full_screen= is not supported (desktop-only API)"
      end

      def windowed=(*)
        raise NotImplementedError, "Window.windowed= is not supported (desktop-only API)"
      end

      def x=(*)
        raise NotImplementedError, "Window.x= is not supported (no window position in browser)"
      end

      def y=(*)
        raise NotImplementedError, "Window.y= is not supported (no window position in browser)"
      end
    end
  end

  class RenderTarget
    def draw_shader(*) = raise NotImplementedError, "RenderTarget#draw_shader is not supported (HLSL shader not available in Canvas 2D)"
  end

  class Sprite
    def shader=(*)
      raise NotImplementedError, "Sprite#shader= is not supported (HLSL shader not available in Canvas 2D)"
    end
  end
end
