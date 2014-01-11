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

class Window
  def initialize(player)
    Stylet::Base.instance.sdl_initialize
    player.add_observer(self)
  end

  def update(player)
    Stylet::Base.instance.next_frame do
      vputs player
    end
  end
end

player = Player.new
Window.new(player)
loop do
  player.render
end
