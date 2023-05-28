require_relative "joystick_adapter"

module Stylet
  module Joystick
    attr_reader :joys

    def run_initializers
      super
      init_on(:joystick) do
        # if SDL2.inited_system(SDL2::INIT_JOYSTICK).zero?
        #   SDL2.initSubSystem(SDL2::INIT_JOYSTICK)
        count = SDL2::Joystick.num_connected_joysticks
        logger.debug "SDL2::Joystick.num: #{count}" if logger
        @joys = count.times.collect do |i|
          JoystickAdapter.create(SDL2::Joystick.open(i))
        end
        # end
      end
    end

    # def polling
    #   super
    #   SDL2::Joystick.update_all
    # end

    def before_update
      super
      return if Stylet.production
      @joys.each {|joy| vputs(joy.inspect) }
    end
  end
end
