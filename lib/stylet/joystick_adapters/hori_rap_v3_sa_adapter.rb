# リアルアーケードPro.V3 SA(PS3用) http://www.amazon.co.jp/dp/B002YT9PSI
#
#    12(PS) 8(SELECT)
#
# ＋ 0 3 5 4
#    1 2 7 6  9(START)
#
module Stylet
  module JoystickAdapters
    class HoriRapV3SaAdapter < JoystickAdapter
      cattr_accessor :button_assigns do
        {
          :btA      => 3,
          :btB      => 5,
          :btC      => 4,
          :btD      => 2,

          :btSelect => 8,
          :btStart  => 9,
          :btPS     => 12,
        }
      end

      def lever_on?(dir)
        case dir
        when :up
          axis(1).negative?
        when :down
          axis(1).positive?
        when :right
          axis(0).positive?
        when :left
          axis(0).negative?
        else
          false
        end
      end
    end
  end
end
