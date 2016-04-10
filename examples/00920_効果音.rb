require_relative "helper"

class App < Stylet::Base
  include Helper::Cursor

  setup do
    Stylet::SE.load("assets/nc26792_coin.ogg")
  end

  update do
    if button.btA.trigger? || frame_counter == 0
      Stylet::SE[:nc26792_coin].play
    end
  end

  run
end
