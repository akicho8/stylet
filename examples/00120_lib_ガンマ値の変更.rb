# -*- coding: utf-8 -*-
# ガンマ値の変更
require_relative "helper"

class App < Stylet::Base
  include Helper::Cursor

  setup do
    s = SDL::Surface.load("assets/love_live.png")
    image = s.display_format
    screen.put(image, 0, 0)
  end

  update do
    b = 0.4 + rsin(1.0 / 256 * frame_counter * 2) * 0.3
    SDL::Screen.set_gamma(0, 0, b)
  end

  def background_clear
  end

  run
end
