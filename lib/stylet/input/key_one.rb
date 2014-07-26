# -*- coding: utf-8 -*-
#
# ボタン1つの押し下げ管理
#
module Stylet
  module Input
    #
    # ボタン一つの情報を管理するクラス
    #
    #   state をセットして update することでカウンタが更新される
    #
    class KeyOne
      class << self
        # キーリピート2としたときの挙動
        # 3フレーム目に押された場合
        #
        #        2 3 4 5 6 7 (__frame__)
        #  count 0 1 2 3 4 5
        # repeat 0 1 0 0 2 3
        #            ^ ^  の数(1と2の間がの数)がkey_repeat
        #
        def repeat(count, key_repeat)
          repeat = 0
          if count == 1
            repeat = 1
          elsif count > key_repeat + 1
            repeat = count - key_repeat
          else
            repeat = 0
          end
          repeat
        end
      end

      attr_accessor :name, :match_chars, :store_char, :index
      attr_accessor :state
      attr_reader :count, :free_count

      def initialize(name:, match_chars: nil, store_char: nil, index: nil)
        @name        = name
        @match_chars = match_chars
        @store_char  = store_char
        @index       = index

        @count = 0
        @free_count = 0
        @state = false
      end

      # 直近フラグを設定。falseにはできない。
      #
      #   フラグが有効になる条件が複数ある場合に使うと便利
      #
      #   有効になるもの
      #     obj << "A" # 同じマーク
      #     obj << 1
      #     obj << true
      #
      def <<(value)
        case value
        when String
          value = @match_chars.any?{|m|value.include?(m)}
        when Integer
          value = (value & _bit_value).nonzero?
        end
        @state |= value
      end

      # 更新する前のon/off状態を取得(廃止予定)
      def state_to_s
        @state ? @store_char : ""
      end

      # @state の状態を @count に反映する
      #   引数が指定されていればそれを直近の状態に設定して更新する
      def counter_update(state = nil)
        if state
          self << state
        end
        if @state
          @count += 1
          @free_count = 0
        else
          @count = 0
          @free_count += 1
        end
        @state = false
      end

      # キーリピート2としたときの挙動
      # 3フレーム目に押された場合
      #
      #        2 3 4 5 6 7 (__frame__)
      #  count 0 1 2 3 4 5
      # repeat 0 1 0 0 2 3
      #            ^ ^  の数(1と2の間がの数)がkey_repeat
      #
      def repeat(key_repeat = 12) # FIXME
        self.class.repeat(@count, key_repeat)
      end

      # 押されていない？
      def free?
        @count == 0
      end

      # 押しっぱなし？
      def press?
        @count >= 1
      end

      # 押した瞬間？
      def trigger?
        @count == 1
      end

      # 押していないとき 0.0 で押している間は 1.0 を返す
      def repeat_0or1
        if repeat >= 1
          1.0
        else
          0.0
        end
      end

      # 離した瞬間？
      def free_trigger?
        @free_count == 1
      end

      def inspect
        "#{self}#{@count}"
      end

      # # 押されているときだけ自分のマークを返す
      # def to_s2
      #   if press?
      #     @store_char
      #   end
      # end

      def press_bit_value
        if press?
          _bit_value
        else
          0
        end
      end

      begin
        private
        def _bit_value
          1 << @index
        end
      end
    end
  end
end

if $0 == __FILE__
  key_one = Stylet::Input::KeyOne.new("A")
  key_one.update("A")
  p key_one.state_to_s
  p key_one.press?
  p key_one.trigger?
  p key_one.free?
  p key_one.free_trigger?
  p key_one.to_s
end
