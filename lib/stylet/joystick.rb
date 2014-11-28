require_relative "joystick_adapter"

module Stylet
  module Joystick
    attr_reader :joys

    def run_initializers
      super
      init_on(:joystick) do
        if SDL.inited_system(SDL::INIT_JOYSTICK).zero?
          SDL.initSubSystem(SDL::INIT_JOYSTICK)
          logger.debug "SDL::Joystick.num: #{SDL::Joystick.num}" if logger
          @joys = SDL::Joystick.num.times.collect do |i|
            JoystickAdapter.create(SDL::Joystick.open(i))
          end
        end
      end
    end

    def polling
      super
      SDL::Joystick.update_all
    end

    def before_update
      super
      return if Stylet.production
      @joys.each {|joy| vputs(joy.inspect) }
    end
  end
end
