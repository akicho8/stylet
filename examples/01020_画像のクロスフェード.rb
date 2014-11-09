# -*- coding: utf-8 -*-
# 画像のクロスフェード
require_relative "helper"
require "pathname"

class App < Stylet::Base
  include Helper::CursorWithObjectCollection

  setup do
    @images = Pathname.glob(Pathname("assets/bg*.png").expand_path).collect do |file|
      SDL::Surface.load(file.to_s).display_format
    end
    @index = 0
    @alpha = 0
  end

  update do
    a = @images[(@index + 0).modulo(@images.size)]
    b = @images[(@index + 1).modulo(@images.size)]

    a.set_alpha(SDL::SRCALPHA, 255)
    screen.put(a, 0, 0)

    b.set_alpha(SDL::SRCALPHA, @alpha)
    screen.put(b, 0, 0)

    @alpha += 4
    if @alpha >= 255
      @index += 1
      @alpha = 0
    end
  end

  def background_clear
  end

  run
end
