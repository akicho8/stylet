# -*- coding: utf-8 -*-

require_relative "../axis_support"

module Stylet
  module Input
    # このモジュールをプレイヤーや人工無能相当に直接includeしてaxisとbuttonの情報を持たせるようにする
    module Base
      Axis   = Struct.new(:up, :down, :left, :right)
      Button = Struct.new(:btA, :btB, :btC, :btD)

      attr_reader :axis, :button

      def initialize(*)
        super if defined? super
        @axis   = Axis.new(KeyOne.new("u"), KeyOne.new("d"), KeyOne.new("l"), KeyOne.new("r"))
        @button = Button.new(KeyOne.new("AL"), KeyOne.new("BR"), KeyOne.new("C"), KeyOne.new("D"))
      end

      # 上下左右とボタンの状態を配列で返す
      def key_objects
        @axis.values + @button.values
      end

      # レバーの更新前のビット状態を取得
      #   更新前であることに注意
      def axis_state_str
        @axis.values.collect{|e|e.state_to_s}.join
      end

      # # 適当に文字列化
      # def to_s(stype=nil)
      #   case stype.to_s
      #   when "axis"
      #     @axis.values.to_s
      #   when "button"
      #     @button.values.to_s
      #   when "ext_button"
      #     @ext_button.values.to_s
      #   else
      #     key_objects.to_s
      #   end
      # end

      def to_s
        key_objects.join
      end

      # 左右の溜めが完了しているか?(次の状態から使えるか?)
      def key_power_effective?(power_delay)
        Input::Support.key_power_effective?(@axis.left, @axis.right, power_delay)
      end

      # # ここで各ボタンを押す
      # def update
      #   # raise NotImplementedError, "#{__method__} is not implemented"
      # end

      # ボタンとレバーのカウンタを更新する
      #   実行後に state は false になる
      def key_counter_update_all
        key_objects.each{|e|e.update}
      end

      # レバーの状態から8方向の番号インデックスに変換
      def axis_angle_index
        AxisSupport.axis_angle_index(@axis)
      end

      # 8方向レバーの状態から一周を1.0としたときの方向を返す
      def axis_angle
        AxisSupport.axis_angle(@axis)
      end
    end

    # ジョイスティックの上とかにあるボタン類
    module ExtensionButton
      Button = Struct.new(:btR1, :btR2, :btL1, :btL2, :btSelect, :btStart, :btPS)

      attr_reader :ext_button

      def initialize(*)
        super if defined? super
        @ext_button = Button.new(*[
            KeyOne.new("R1", ""), # 第二引数は TextInputUnit が反応する文字
            KeyOne.new("R2", ""),
            KeyOne.new("L1", ""), # ホールド用 FIXME
            KeyOne.new("L2", ""),
            KeyOne.new("SELECT", ""),
            KeyOne.new("START", ""),
            KeyOne.new("PS", ""),
          ])
      end

      def key_objects
        super + @ext_button.values
      end
    end
  end
end

if $0 == __FILE__
  require_relative "../../stylet"
  Stylet.run
end
