# Stylet::Base 側のループで描画されるのではなくPlayer側のタイミングで描画するとみせかけて、やっぱり Stylet::Base 側のループで描画する
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

  def update(player)
    next_frame
    vputs player
  end
end

player = Player.new
Window.new(player)
(60 * 3).times do
  player.render
end
