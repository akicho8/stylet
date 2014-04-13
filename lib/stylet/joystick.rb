require_relative "joystick_adapter"

module Stylet
  module Joystick
    attr_reader :joys

    def initialize
      super
      @init_code |= SDL::INIT_JOYSTICK
    end

    def run_initializers
      super
      init_on(:joystick) do
        logger.debug "SDL::Joystick.num: #{SDL::Joystick.num}" if logger
        @joys = SDL::Joystick.num.times.collect{|i|JoystickAdapter.create(SDL::Joystick.open(i))}
      end
    end

    def polling
      super
      SDL::Joystick.updateAll
    end

    def before_update
      super
      return if Stylet.production
      @joys.each{|joy|vputs(joy.inspect)}
    end
  end
end
