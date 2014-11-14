# -*- coding: utf-8 -*-
# 2P対戦雛型
require_relative "helper"

class Player
  include Stylet::Delegators
  include Stylet::Input::Base
  include Stylet::Input::ExtensionButton

  def initialize(pos)
    super()
    @pos = pos
  end

  def update
    raise if defined? super
    bit_update_by_joy(joys[@joystick_index])
    key_bit_update_all
    key_counter_update_all

    if angle = axis_angle
      @pos += vec2.angle_at(angle) * 4
    end
    draw_circle(@pos, :vertex => 16, :radius => 32)
  end
end

class Player1 < Player
  include Stylet::Input::StandardKeybordBind
  include Stylet::Input::JoystickBindMethod
  def initialize(*)
    super
    @joystick_index = 0
  end
end

class Player2 < Player
  include Stylet::Input::HjklKeyboardBind
  include Stylet::Input::JoystickBindMethod
  def initialize(*)
    super
    @joystick_index = 1
  end
end

class App < Stylet::Base
  include Helper::CursorWithObjectCollection

  setup do
    self.title = "2P対戦雛型"
    cursor.display = false
    SDL::Mouse.hide

    @players = []
    @players << Player1.new(vec2[srect.half_w - srect.half_w * 0.5, srect.half_h])
    @players << Player2.new(vec2[srect.half_w + srect.half_w * 0.5, srect.half_h])
    @objects += @players
  end

  run
end
