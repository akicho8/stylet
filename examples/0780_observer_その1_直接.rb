# -*- coding: utf-8 -*-
# Stylet::Base 側のループで描画されるのではなくPlayer側のタイミングで描画する
require_relative "helper"

class Player
  include Observable
  def render
    changed
    notify_observers(self)
  end
end

class Window < Stylet::Base
  def initialize
    super
    sdl_initialize
  end

  def scene_update(player)
    next_frame do
      vputs player
    end
  end
end

player = Player.new
player.add_observer(Window.instance, :scene_update)
loop do
  player.render
end
