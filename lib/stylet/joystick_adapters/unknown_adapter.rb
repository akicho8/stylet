# -*- coding: utf-8 -*-
class Stylet::UnknownAdapter < Stylet::JoystickAdapter
  cattr_accessor(:lever_button_assigns) do
    {}
  end

  cattr_accessor(:button_assigns) do
    {}
  end
end
