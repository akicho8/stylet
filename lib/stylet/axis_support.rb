#
# レバーの状態から方向を返す便利メソッド
#

module Stylet
  module AxisSupport
    extend self

    # レバーの状態から8方向の番号インデックスに変換
    #        [U]
    #         6
    #       5   7
    #  [L]4       0[R]
    #       3   1
    #         2
    #        [D]
    def axis_angle_index(axis)
      case
      when axis.up.press?
        case
        when axis.right.press?
          7
        when axis.left.press?
          5
        else
          6
        end
      when axis.down.press?
        case
        when axis.right.press?
          1
        when axis.left.press?
          3
        else
          2
        end
      when axis.right.press?
        0
      when axis.left.press?
        4
      end
    end

    # 8方向レバーの状態から一周を1.0としたときの方向を返す
    #            [U]
    #           0.750
    #        0.625 0.875
    #   [L] 0.500   0.000 [R]
    #        0.375 0.125
    #           0.250
    #            [D]
    def axis_angle(axis)
      if dir = axis_angle_index(axis)
        1.0 * dir / 8
      end
    end
  end
end

if $0 == __FILE__
  require_relative "../stylet"
end
