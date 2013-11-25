# -*- coding: utf-8 -*-
class Stylet::UnknownAdapter < Stylet::JoystickAdapter
  def lever_on?(dir)
    false
  end

  def button_on?(key)
    false
  end
end
