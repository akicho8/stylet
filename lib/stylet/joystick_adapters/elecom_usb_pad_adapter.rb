# ELECOM ゲームパッド JC-U2410TBK http://www.amazon.co.jp/dp/B000FO600A
module Stylet
  module JoystickAdapters
    class ElecomUsbPadAdapter < JoystickAdapter
      cattr_accessor :button_assigns do
        {
          :btA => 0,
          :btB => 1,
          :btC => 3,
          :btD => 2,
        }
      end

      def lever_on?(dir)
        case dir
        when :up
          axis(4) <= -32768
        when :down
          axis(4) >= 32767
        when :right
          axis(3) <= -32768
        when :left
          axis(3) >= 32767
        else
          false
        end
      end
    end
  end
end
