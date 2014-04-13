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

class Window < SimpleDelegator
  def initialize(player)
    super(Stylet::Base.active_frame)
    player.add_observer(self)
  end

  def update(player)          # observer として呼ばれる update
    next_frame                # Stylet::Base#update を呼ぶ。干渉しない。
    vputs player
  end
end

player = Player.new
Window.new(player)
loop do
  player.render
end
