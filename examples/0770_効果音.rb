# -*- coding: utf-8 -*-
require_relative "helper"

class App < Stylet::Base
  include Helper::Cursor

  setup do
    Stylet::SE.load_file("assets/nc26792_coin.ogg")
  end

  update do
    if button.btA.trigger? || count == 0
      Stylet::SE[:nc26792_coin].play
    end
  end

  run
end
