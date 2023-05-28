require_relative "helper"

class App < Stylet::Base
  include Helper::Cursor

  setup do
    s = SDL2::Surface.load("assets/mario.png")
    s.set_color_key(SDL2::SRCCOLORKEY, 0)
    @image = s.display_format
  end

  update do
    screen.put(@image, *cursor.point)
  end

  run
end
