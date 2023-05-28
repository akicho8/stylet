require "active_support/core_ext/module/delegation"

module Stylet
  class FpsAdjust
    delegate :fps, :to => "Stylet.config"

    def initialize
      @old_time = SDL2.get_ticks
    end

    def delay
      return unless fps

      loop do
        now = SDL2.get_ticks
        if now > @old_time + 1000.0 / fps
          @old_time = now
          break
        end
      end
    end
  end
end
