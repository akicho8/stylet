# -*- coding: utf-8 -*-
# 左右が繋がっている例
require_relative "helper"

Stylet::Palette[:background] = [107, 140, 255]
Stylet::Palette[:font]       = [0, 0, 0]

class App < Stylet::Base
  include Helper::CursorWithObjectCollection

  setup do
    @cursor.display = false

    s = SDL::Surface.load("assets/mario.png")
    s.set_color_key(SDL::SRCCOLORKEY, 0)
    @image = s.display_format
    @pos = Stylet::Vector.new(srect.min_x, srect.center.y)
  end

  update do
    @pos.x += -Stylet.context.axis.left.counter + Stylet.context.axis.right.counter
    @pos.x = @pos.x.modulo(srect.w)
    v = @pos + Stylet::Vector.new(-@image.w / 2, -@image.h / 2)
    screen.put(@image, *v)
    screen.put(@image, *(v - Stylet::Vector.new(srect.w, 0)))
    screen.put(@image, *(v + Stylet::Vector.new(srect.w, 0)))
  end

  run
end
