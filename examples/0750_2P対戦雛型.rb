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
    super if defined? super
    update_by_joy(joys[@joystick_index])
    key_counter_update_all

    if angle = axis_angle
      @pos += Stylet::Vector.angle_at(angle) * 4
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
    @players << Player1.new(Stylet::Vector.new(rect.half_w - rect.half_w * 0.5, rect.half_h))
    @players << Player2.new(Stylet::Vector.new(rect.half_w + rect.half_w * 0.5, rect.half_h))
    @objects += @players
  end

  run
end
