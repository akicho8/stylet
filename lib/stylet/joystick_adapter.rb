require 'active_support/core_ext/module/delegation'
require "active_support/core_ext/class/attribute_accessors"
require "active_support/core_ext/string/inflections"

module Stylet
  class JoystickAdapter
    cattr_accessor :adapter_assigns do
      {
        "PLAYSTATION(R)3 Controller"  => :ps3_standard,   # 純正
        "PS(R) Gamepad"               => :ps3_standard,   # 純正風ぱちもん
        "USB Gamepad"                 => :elecom_usb_pad, # ELECOM ゲームパッド JC-U2410TBK http://www.amazon.co.jp/dp/B000FO600A
        "REAL ARCADE Pro.V3"          => :hori_rap_v3_sa, # リアルアーケードPro.V3 SA(PS3用) http://www.amazon.co.jp/dp/B002YT9PSI
        "USB,2-axis 8-button gamepad" => :buffalo_snes,   # iBUFFALO USBゲームパッド 8ボタン スーパーファミコン風 http://www.amazon.co.jp/dp/B002B9XB0E
      }
    end

    def self.create(object)
      name = SDL2::Joystick.index_name(object.index).strip
      key = adapter_assigns[name] || :ps3_standard
      adapter = "#{key}_adapter"
      require_relative "joystick_adapters/#{adapter}"
      Stylet.logger.info [object.index, name, adapter].inspect if Stylet.logger
      "stylet/joystick_adapters/#{adapter}".classify.constantize.new(object)
    end

    attr_reader :object

    delegate :axis, :button, :to => :object

    def initialize(object)
      @object = object
    end

    # 抽象シリーズ
    begin
      def lever_on?(dir)
        if i = lever_button_assigns[dir]
          button(i)
        end
      end

      def button_on?(key)
        if i = button_assigns[key]
          button(i)
        end
      end

      def available_analog_levers
        {}
      end

      def adjusted_axes
        [:up, :down, :right, :left].collect { |dir|
          if lever_on?(dir)
            dir.to_s.slice(/^(.)/).upcase
          end
        }.compact
      end

      def adjusted_buttons
        button_assigns.keys.collect {|key|
          if button_on?(key)
            key.to_s.sub("bt", "").upcase
          end
        }.compact
      end
    end

    # ハードウェアの値をそのまま返すシリーズ
    begin
      def name
        SDL2::Joystick.index_name(@object.index)
      end

      def raw_active_button_numbers
        @object.num_buttons.times.collect {|i|
          if @object.button(i)
            i
          end
        }.compact
      end

      def raw_analog_lever_status
        @object.num_axes.times.collect {|i| @object.axis(i) }
      end
    end

    def inspect
      "#{@object.index}: #{unit_str}"
    end

    def unit_str
      [
        adjusted_axes.join,
        adjusted_buttons.join,
        raw_active_button_numbers,
        # available_analog_levers.values,
        raw_analog_lever_status,
      ].collect(&:to_s).join
    end

    ANALOG_LEVER_MAX           = 32767
    ANALOG_LEVER_MAGNITUDE_MAX = Math.sqrt(ANALOG_LEVER_MAX**2 + ANALOG_LEVER_MAX**2)

    # 調整済みアナログレバー
    def adjusted_analog_levers
      available_analog_levers.inject({}) do |hash, (key, xy)|
        v = vec2[*xy]
        m = v.magnitude
        if false
          # 取得した値をそのまま使うと斜めのベクトルが強くなりすぎる
          # たんなる方向を示したいときはこれで問題ない
          r = m.to_f / ANALOG_LEVER_MAGNITUDE_MAX
        else
          # 斜めのベクトルが強くなりすぎないように制限を加えた例
          if m >= ANALOG_LEVER_MAX
            m = ANALOG_LEVER_MAX
          end
          r = m.to_f / ANALOG_LEVER_MAX
        end
        hash.merge(key => v.normalize * r)
      end
    end
  end
end

if $0 == __FILE__
  require_relative "../stylet"
  Stylet.run
end
