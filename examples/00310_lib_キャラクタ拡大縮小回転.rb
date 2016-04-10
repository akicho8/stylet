require_relative "helper"

class App < Stylet::Base
  include Helper::Cursor

  setup do
    s = SDL::Surface.load("assets/mario.png")
    s.set_color_key(SDL::SRCCOLORKEY, 0)
    @image = s.display_format
  end

  update do
    SDL::Surface.transform_blit(@image, screen,
      Stylet::Fee.rsin(1.0 / 256 * frame_counter) * 180,
      Stylet::Fee.rsin(1.0 / 256 * frame_counter * 7 / 5) * 24,
      Stylet::Fee.rsin(1.0 / 256 * frame_counter * 8 / 5) * 24,
      @image.w / 2, @image.h / 2, *cursor.point, 0)
  end

  run
end
