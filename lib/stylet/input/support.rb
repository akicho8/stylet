# -*- coding: utf-8 -*-
#
# ボタン同士の優先順位を得るユーティリティ
#
module Stylet
  module Input
    # FIXME: KeyOneの特異メソッドとした方が自然かもしれない。ただ KeyOne という名前がよくない
    module Support
      extend self

      # 2つのキーの優先順位を得る
      #
      #   a = KeyOne.new
      #   b = KeyOne.new
      #
      #   1フレーム目。aだけ押されたのでaが返る
      #   a.update(true)
      #   b.update(false)
      #   InputSupport.preference_key(a, b) #=> a
      #
      #   2フレーム目。aは押しっぱなしだが、bの方が若いのでbが返る
      #   a.update(true)
      #   b.update(true)
      #   InputSupport.preference_key(a, b) #=> b
      #
      #   3つ以上のキーで比較する場合の麗
      #   list.sort_by{|e|(e.count.zero? ? Float::INFINITY : e.count)}.first
      #
      def preference_key(lhv, rhv, if_collision: lhv)
        case
        when rhv.press? && lhv.press?
          case
          when rhv.count < lhv.count
            rhv
          when lhv.count < rhv.count
            lhv
          else
            if_collision
          end
        when rhv.press?
          rhv
        when lhv.press?
          lhv
        else
          nil
        end
      end

      # 3つ以上のキーの優先順位を得る
      def preference_keys(list)
        if v = list.sort_by{|e|(e.count.zero? ? Float::INFINITY : e.count)}.first
          if v.press?
            v
          end
        end
      end

      # 2つのキーのどちらかの溜めが完了しているか？(次の状態から使えるか？)
      #
      #        1 2 3 4 5 6 __frame__
      #   lhv  0 0 0 0 0 0
      #   rhv  1 0 0 2 3 4
      #
      #   3フレーム目で key_power_effective?(lhv, rhv, 2) #=> true になる
      #
      def key_power_effective?(lhv, rhv, power_delay)
        if key = preference_key(lhv, rhv)
          key.repeat(power_delay - 1) > 1
        end
      end
    end
  end
end
