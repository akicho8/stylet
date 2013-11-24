# -*- coding: utf-8 -*-
class Stylet::ElecomUsbPadAdapter < Stylet::JoystickAdapter
  def lever_on?(dir)
    case dir
    when :up
      axis(4) == -32768
    when :down
      axis(4) == +32767
    when :right
      axis(3) == +32767
    when :left
      axis(3) == -32768
    else
      false
    end
  end

  def button_on?(key)
    pos = {
      :btA => 0,
      :btB => 1,
      :btC => 3,
      :btD => 2,
    }[key]
    if pos
      button(pos)
    end
  end

  def analog_lever
    {}
  end
end
