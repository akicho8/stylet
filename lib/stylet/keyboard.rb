module Stylet
  module Keyboard
    def sdl_initialize
      super
      SDL::Key.scan
      p ["#{__FILE__}:#{__LINE__}", __method__]
    end

    def polling
      super if defined? super
      SDL::Key.scan
    end
  end
end
