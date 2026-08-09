module PicoDX
  class Sound
    def initialize(filename)
      @playing    = false
      @disposed   = false
      @volume     = 1.0
      @pan        = 0.0
      @loop       = false
      @loop_start = 0.0
      @loop_end   = 0.0
      @play_start = 0.0
      @frequency  = nil
      @source     = nil
      @gain_node  = nil
      @pan_node   = nil

      JS.eval("window.__picodx_audio_ctx = window.__picodx_audio_ctx || new AudioContext()")
      @buffer = JS.eval(
        "fetch('#{filename}')" \
        ".then(r=>r.arrayBuffer())" \
        ".then(buf=>window.__picodx_audio_ctx.decodeAudioData(buf))"
      ).await
    end

    def play
      return if @disposed || @buffer.nil?
      stop if @playing

      ctx = JS.eval("window.__picodx_audio_ctx")
      JS.eval("window.__picodx_audio_ctx.state === 'suspended' && window.__picodx_audio_ctx.resume()")

      @gain_node = ctx.createGain
      @gain_node[:gain][:value] = @volume

      @pan_node = ctx.createStereoPanner
      @pan_node[:pan][:value] = @pan

      @source = ctx.createBufferSource
      @source[:buffer] = @buffer
      @source[:loop] = @loop
      if @loop
        @source[:loopStart] = @loop_start
        @source[:loopEnd]   = @loop_end if @loop_end > 0
      end
      if @frequency
        orig_rate = @buffer[:sampleRate].to_f
        @source[:playbackRate][:value] = @frequency / orig_rate if orig_rate > 0
      end

      @source.connect(@gain_node)
      @gain_node.connect(@pan_node)
      @pan_node.connect(ctx[:destination])

      @source.start(@play_start)
      @playing = true

      @source.addEventListener('ended') do |_|
        @playing = false
        @source  = nil
      end
    end

    def stop
      return unless @playing
      @source.stop rescue nil
      @source  = nil
      @playing = false
    end

    def playing?
      @playing
    end

    def start=(position)
      @play_start = position.to_f
    end

    def loop_count=(n)
      @loop = (n == 0 || n < 0)
    end

    def loop_start=(pos)
      @loop_start = pos.to_f
    end

    def loop_end=(pos)
      @loop_end = pos.to_f
    end

    def set_volume(vol)
      @volume = vol.to_f / 255
      @gain_node[:gain][:value] = @volume if @gain_node
    end

    def pan=(val)
      @pan = val.to_f
      @pan_node[:pan][:value] = @pan if @pan_node
    end

    def frequency=(hz)
      @frequency = hz.to_f
      if @source && @buffer
        orig_rate = @buffer[:sampleRate].to_f
        @source[:playbackRate][:value] = @frequency / orig_rate if orig_rate > 0
      end
    end

    def dispose
      stop if @playing
      @disposed = true
    end

    def disposed?
      @disposed
    end
  end
end
