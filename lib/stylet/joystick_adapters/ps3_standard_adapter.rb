# 純正 or 純正風ぱちもん
module Stylet
  module JoystickAdapters
    class Ps3StandardAdapter < JoystickAdapter
      cattr_accessor(:lever_button_assigns) do
        {
          :up    => 4,
          :right => 5,
          :down  => 6,
          :left  => 7,
        }
      end

      cattr_accessor(:button_assigns) do
        {
          :btA      => 15,
          :btB      => 12,
          :btC      => 13,
          :btD      => 14,

          :btR1     => 11,
          :btR2     => 9,
          :btL1     => 10,
          :btL2     => 8,

          :btSelect => 0,
          :btStart  => 3,
          :btPS     => 16,
        }
      end

      def available_analog_levers
        {
          :left  => [axis(0), axis(1)],
          :right => [axis(2), axis(3)],
        }
      end
    end
  end
end
