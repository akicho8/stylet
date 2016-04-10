
require_relative "../axis_support"

module Stylet
  module Input
    # このモジュールをプレイヤーや人工無能相当に直接includeしてaxisとbuttonの情報を持たせるようにする
    module Base
      Axis   = Struct.new(:up, :down, :left, :right)
      Button = Struct.new(:btA, :btB, :btC, :btD)

      attr_reader :axis, :button
      attr_reader :key_objects

      def initialize(*)
        super if defined? super

        @key_objects = []

        @axis = Axis.new(*[
            factory(name: "u", match_chars: "u", store_char: "u"),
            factory(name: "d", match_chars: "d", store_char: "d"),
            factory(name: "l", match_chars: "l", store_char: "l"),
            factory(name: "r", match_chars: "r", store_char: "r"),
          ])

        @button = Button.new(*[
            factory(:name => "A", :match_chars => "AL", store_char: "A"),
            factory(:name => "B", :match_chars => "BR", store_char: "B"),
            factory(:name => "C", :match_chars => "C", store_char: "C"),
            factory(:name => "D", :match_chars => "D", store_char: "D"),
          ])
      end

      def factory(attrs)
        KeyOne.new(attrs.merge(:index => @key_objects.size)).tap do |e|
          @key_objects << e
        end
      end

      # レバーの更新前のビット状態を取得
      #   更新前であることに注意
      def axis_state_str
        @axis.values.collect(&:state_to_s).join
      end

      def key_objs_dump
        key_objects.inject(0) {|a, e| a + e.press_bit_value }
      end

      def key_objs_load(obj)
        key_objects.each {|v| v << obj }
      end

      # def to_s
      #   key_objects.join
      # end

      # 左右の溜めが完了しているか?(次の状態から使えるか?)
      def key_power_effective?(power_delay)
        Input::Support.key_power_effective?(@axis.left, @axis.right, power_delay)
      end

      # ボタンとレバーのカウンタを更新する
      #   実行後に state は false になる
      def key_counter_update_all
        key_objects.each(&:counter_update)
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
            factory(name: "R1",     match_chars: nil, store_char: nil),
            factory(name: "R2",     match_chars: nil, store_char: nil),
            factory(name: "L1",     match_chars: nil, store_char: nil),
            factory(name: "L2",     match_chars: nil, store_char: nil),
            factory(name: "SELECT", match_chars: nil, store_char: nil),
            factory(name: "START",  match_chars: nil, store_char: nil),
            factory(name: "PS",     match_chars: nil, store_char: nil),
          ])
      end
    end
  end
end

if $0 == __FILE__
  require_relative "../../stylet"
  Stylet.run
end
