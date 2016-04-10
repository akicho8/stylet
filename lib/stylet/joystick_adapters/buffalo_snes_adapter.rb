# iBUFFALO USBゲームパッド 8ボタン スーパーファミコン風
# http://www.amazon.co.jp/dp/B002B9XB0E
#
#   4              5
#   -y             2
# -x  +x   6 7    3 0
#   +y             1
#
# x: axis(0)
# y: axis(1)
#
module Stylet
  module JoystickAdapters
    class BuffaloSnesAdapter < JoystickAdapter
      cattr_accessor :button_assigns do
        {
          :btA      => 3,
          :btB      => 2,
          :btC      => 1,
          :btD      => 0,

          :btR1     => 4,
          :btL1     => 5,

          :btSelect => 6,
          :btStart  => 7,
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
