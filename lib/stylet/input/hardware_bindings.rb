# -*- coding: utf-8 -*-
#
# ボタンのアサイン
#
module Stylet
  module Input
    module StandardKeybordBind
      def key_bit_update_all(*args)
        super if defined? super
        @axis.up    << SDL::Key.press?(SDL::Key::UP)
        @axis.down  << SDL::Key.press?(SDL::Key::DOWN)
        @axis.left  << SDL::Key.press?(SDL::Key::LEFT)
        @axis.right << SDL::Key.press?(SDL::Key::RIGHT)
        @button.btA << SDL::Key.press?(SDL::Key::Z)
        @button.btB << SDL::Key.press?(SDL::Key::X)
        @button.btC << SDL::Key.press?(SDL::Key::C)
        @button.btD << SDL::Key.press?(SDL::Key::V)
      end
    end

    module MouseButtonBind
      def key_bit_update_all(*args)
        super if defined? super
        @button.btA << @mouse.button.a
        @button.btB << @mouse.button.b
        @button.btC << @mouse.button.c
      end
    end

    module HjklKeyboardBind
      def key_bit_update_all(*args)
        super if defined? super
        @axis.up    << SDL::Key.press?(SDL::Key::K)
        @axis.down  << SDL::Key.press?(SDL::Key::J)
        @axis.left  << SDL::Key.press?(SDL::Key::H)
        @axis.right << SDL::Key.press?(SDL::Key::L)
        @button.btA << SDL::Key.press?(SDL::Key::U)
        @button.btB << SDL::Key.press?(SDL::Key::I)
        @button.btC << SDL::Key.press?(SDL::Key::O)
        @button.btD << SDL::Key.press?(SDL::Key::P)
      end
    end

    module JoystickBindMethod
      def bit_update_by_joy(joy)
        return unless joy
        @axis.up    << joy.lever_on?(:up)
        @axis.down  << joy.lever_on?(:down)
        @axis.left  << joy.lever_on?(:left)
        @axis.right << joy.lever_on?(:right)
        @button.btA << joy.button_on?(:btA)
        @button.btB << joy.button_on?(:btB)
        @button.btC << joy.button_on?(:btC)
        @button.btD << joy.button_on?(:btD)
        if @ext_button
          @ext_button.btR1 << joy.button_on?(:btR1)
          @ext_button.btR2 << joy.button_on?(:btR2)
          @ext_button.btL1 << joy.button_on?(:btL1)
          @ext_button.btL2 << joy.button_on?(:btL2)
          @ext_button.btSelect << joy.button_on?(:btSelect)
          @ext_button.btStart  << joy.button_on?(:btStart)
          @ext_button.btPS     << joy.button_on?(:btPS)
        end
      end
    end
  end
end
