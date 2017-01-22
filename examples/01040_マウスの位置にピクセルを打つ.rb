# マウスの位置にピクセルを打つ
require_relative "helper"

class App < Stylet::Base
  setup do
    SDL::Mouse.hide
  end

  update do
    rgb = 3.times.collect { rand(256) }
    screen[*mouse.point] = screen.format.map_rgb(*rgb)
  end

  def background_clear
  end

  run
end
