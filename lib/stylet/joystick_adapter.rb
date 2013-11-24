# -*- coding: utf-8 -*-

require 'active_support/core_ext/module/delegation'
require "active_support/core_ext/class/attribute_accessors"
require "active_support/core_ext/string/inflections"

module Stylet
  class JoystickAdapter
    cattr_accessor(:adapters) do
      {
        "USB Gamepad"                => :elecom_usb_pad,
        "PLAYSTATION(R)3 Controller" => :arashi,
      }
    end

    def self.create(object)
      name = SDL::Joystick.index_name(object.index).strip
      Stylet.logger.info [object.index, name].inspect if Stylet.logger
      adapter = "#{adapters[name]}_adapter"
      require_relative "joystick_adapters/#{adapter}"
      "stylet/#{adapter}".classify.constantize.new(object)
    end

    attr_reader :object

    delegate :index, :axis, :button, :to => :object

    def initialize(object)
      @object = object
    end

    def lever_on?(dir)
      raise NotImplementedError, "#{__method__} is not implemented"
    end

    def button_on?(key)
      raise NotImplementedError, "#{__method__} is not implemented"
    end

    def analog_lever
      raise NotImplementedError, "#{__method__} is not implemented"
    end

    def name
      SDL::Joystick.index_name(index)
    end

    def button_str
      @object.num_buttons.times.collect{|index|
        if @object.button(index)
          index
        end
      }.join
    end

    def axis_str
      [:up, :down, :right, :left].collect{|dir|
        if lever_on?(dir)
          dir.to_s.slice(/^(.)/).upcase
        end
      }.join
    end

    def inspect
      "#{index}: #{name.slice(/^.{8}/)} #{unit_str}"
    end

    def analog_lever_str
      analog_lever.collect{|k, v|"#{k}(%+6d %+6d)" % v}.join(" ")
    end

    def unit_str
      "AXIS:#{axis_str} BTN:#{button_str} #{analog_lever_str}"
    end

    ANALOG_LEVER_MAX = 32767
    ANALOG_LEVER_MAGNITUDE_MAX = Math.sqrt(ANALOG_LEVER_MAX**2 + ANALOG_LEVER_MAX**2)

    # 調整済みアナログレバー
    def adjusted_analog_lever
      analog_lever.inject({}) do |hash, (key, xy)|
        v = Vector.new(*xy)
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
