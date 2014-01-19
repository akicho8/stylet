# -*- coding: utf-8 -*-
module Stylet
  module JoystickAdapters
    class ArashiAdapter < JoystickAdapter
      cattr_accessor :lever_button_assigns do
        {
          :up    => 4,
          :right => 5,
          :down  => 6,
          :left  => 7,
        }
      end

      cattr_accessor :button_assigns do
        {
          :btA => 15,
          :btB => 12,
          :btC => 11,
          :btD => 10,
        }
      end
    end
  end
end
