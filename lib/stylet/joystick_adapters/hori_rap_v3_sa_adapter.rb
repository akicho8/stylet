# リアルアーケードPro.V3 SA(PS3用) http://www.amazon.co.jp/dp/B002YT9PSI
#
#    12(PS) 8(SELECT)
#
# ＋ 0 3 5 4
#    1 2 7 6  9(START)
#
# ▼スイッチと axis(インデックス) の対応
#
#   LS -> 0, 1
#   PR -> 2, 3
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
        # 以前まではニュートラルが0だったのでこの方法でよかった
        # case dir
        # when :up
        #   axis(1).negative?
        # when :down
        #   axis(1).positive?
        # when :right
        #   axis(0).positive?
        # when :left
        #   axis(0).negative?
        # else
        #   false
        # end

        # macOS Sierra にしたらニュートラルが 128 になってしまったので汎用的な判別方法に変更。
        case dir
        when :up
          axis(1) <= -32768
        when :down
          axis(1) >= 32767
        when :right
          axis(0) >= 32767
        when :left
          axis(0) <= -32768
        else
          false
        end
      end
    end
  end
end
