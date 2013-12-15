# -*- coding: utf-8 -*-
require_relative "helper"

class App < Stylet::Base
  include Helper::Cursor

  setup do
    s = SDL::Surface.load("mario.png")
    s.set_color_key(SDL::SRCCOLORKEY, 0)
    @image = s.display_format
  end

  update do
    screen.put(@image, *cursor.point.to_a)
  end

  run
end
