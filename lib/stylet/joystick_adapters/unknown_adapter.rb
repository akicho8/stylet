# -*- coding: utf-8 -*-
module Stylet
  module JoystickAdapters
    class UnknownAdapter < JoystickAdapter
      cattr_accessor :lever_button_assigns do
        {}
      end

      cattr_accessor :button_assigns do
        {}
      end
    end
  end
end
