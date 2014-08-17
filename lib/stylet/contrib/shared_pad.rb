# -*- coding: utf-8 -*-
# すべてのジョイスティックに反応

require "stylet"

module Stylet
  module Input
    class SharedPad
      include Base
      include ExtensionButton
      include StandardKeybordBind
      include HjklKeyboardBind
      include JoystickBindMethod

      def key_bit_update_all(*)
        super
        Stylet::Base.active_frame.joys.each do |joy|
          bit_update_by_joy(joy)
        end
      end
    end
  end
end

if $0 == __FILE__
  require_relative "../../stylet"
  shared_pad = Stylet::Input::SharedPad.new
  Stylet.run {
    shared_pad.key_bit_update_all
    shared_pad.key_counter_update_all
    vputs shared_pad
  }
end
