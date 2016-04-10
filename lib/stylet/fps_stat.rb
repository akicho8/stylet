module Stylet
  # FPSの計測
  #
  # Example:
  #
  #   obj = FpsStat.new
  #   loop do
  #     obj.update
  #     obj.fps # => 60
  #     screen.flip
  #   end
  #
  class FpsStat
    attr_reader :fps

    def initialize
      @fps = 0
      @counter = 0
      @old_time = SDL.get_ticks
    end

    def update
      @counter += 1
      now = SDL.get_ticks
      if now >= @old_time + 1000.0
        @old_time = now
        @fps = @counter
        @counter = 0
      end
    end
  end
end

if $0 == __FILE__
  obj = Stylet::FpsStat.new
  sleep(0.5)
  obj.update
  sleep(0.5)
  obj.update
  p obj.fps
end
