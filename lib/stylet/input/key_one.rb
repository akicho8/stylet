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
        #         1 2 3 4 5 6 7 (Frames)
        # counter 0 0 1 2 3 4 5
        # repeat  0 0 1 0 0 2 3
        #               ^ ^  の数(1と2の間がの数)が key_repeat_first_delay 値
        #
        def repeat(counter, key_repeat_first_delay)
          case
          when counter == 1
            1
          when counter > key_repeat_first_delay + 1
            counter - key_repeat_first_delay
          else
            0
          end
        end
      end

      attr_accessor :name, :match_chars, :store_char, :index
      attr_accessor :state
      attr_reader :counter, :free_counter

      def initialize(name:, match_chars: nil, store_char: nil, index: nil)
        @name        = name
        @match_chars = match_chars
        @store_char  = store_char
        @index       = index

        @counter = 0
        @free_counter = 0
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
          if @match_chars
            value = @match_chars.chars.any? {|m| value.include?(m) }
          else
            value = nil
          end
        when Integer
          value = (value & _bit_value).nonzero?
        end
        @state |= value
      end

      # 更新する前のon/off状態を取得(廃止予定)
      def state_to_s
        @state ? @store_char : ""
      end

      # @state の状態を @counter に反映する
      #   引数が指定されていればそれを直近の状態に設定して更新する
      def counter_update(state = nil)
        if state
          self << state
        end
        if @state
          @counter += 1
          @free_counter = 0
        else
          @counter = 0
          @free_counter += 1
        end
        @state = false
      end

      # キーリピート2としたときの挙動
      # 3フレーム目に押された場合
      #
      #        2 3 4 5 6 7 (Frames)
      #  counter 0 1 2 3 4 5
      # repeat 0 1 0 0 2 3
      #            ^ ^  の数(1と2の間がの数)がkey_repeat
      #
      def repeat(key_repeat_first_delay = 12) # FIXME
        self.class.repeat(@counter, key_repeat_first_delay)
      end

      # 押してない？
      def free?
        @counter == 0
      end

      # 押している？
      def press?
        @counter >= 1
      end

      # 押した瞬間？
      def trigger?
        @counter == 1
      end

      # 離した瞬間？
      def free_trigger?
        @free_counter == 1
      end

      # 押していないとき 0.0 で押している間は 1.0 を返す
      def repeat_0or1
        if repeat >= 1
          1.0
        else
          0.0
        end
      end

      def inspect
        "#{self}#{@counter}"
      end

      def to_s2
        if press?
          @store_char
        end
      end

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
