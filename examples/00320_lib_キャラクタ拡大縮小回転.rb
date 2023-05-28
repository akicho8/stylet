require_relative "helper"

class App < Stylet::Base
  include Helper::Cursor

  setup do
    s = SDL2::Surface.load("assets/mario.png")
    s.set_color_key(SDL2::SRCCOLORKEY, 0)
    @image = s.display_format
  end

  update do
    SDL2::Surface.transform_blit(@image, screen,
      Stylet::Magic.rsin(1.0 / 256 * frame_counter) * 180,
      Stylet::Magic.rsin(1.0 / 256 * frame_counter * 7 / 5) * 24,
      Stylet::Magic.rsin(1.0 / 256 * frame_counter * 8 / 5) * 24,
      @image.w / 2, @image.h / 2, *cursor.point, 0)
  end

  run
end
