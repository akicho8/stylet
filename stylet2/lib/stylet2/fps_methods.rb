module Stylet2
  module FpsMethods
    attr_reader :fps

    def setup
      super

      @fps = 0
      @fps_counter = 0
      @old_ticks = SDL2.get_ticks
    end

    def update
      super

      @fps_counter += 1
      v = SDL2.get_ticks
      t = v - @old_ticks
      if t >= 1000
        @fps = @fps_counter

        @old_ticks = v
        @fps_counter = 0
        if params[:fps_console_print]
          p fps
        end
      end
    end
  end

  Base.prepend FpsMethods
end
