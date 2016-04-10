module Stylet
  module JoystickAdapters
    #
    #    12(PS) 8(SELECT)
    #
    # ＋ 0 3 5 4
    #    1 2 7 6  9(START)
    #
    class HoriRapV3SaAdapter < JoystickAdapter
      cattr_accessor :button_assigns do
        {
          :btA => 3,
          :btB => 5,
          :btC => 4,
          :btD => 2,

          :btSelect => 8,
          :btStart  => 9,
          :btPS     => 12,
        }
      end

      def lever_on?(dir)
        case dir
        when :up
          axis(1) == -32768
        when :down
          axis(1) == +32767
        when :right
          axis(0) == +32767
        when :left
          axis(0) == -32768
        else
          false
        end
      end
    end
  end
end
