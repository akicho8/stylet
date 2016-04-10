require_relative "helper"

class App < Stylet::Base
  include Helper::Cursor

  setup do
    @map_tip = SDL::Surface.load("../assets/images/dlmap/castle2.png")
    @map_tip.set_color_key(SDL::SRCCOLORKEY, 0)
    @map_tip = @map_tip.display_format
    @tip = vec2[16, 16]

    @object_info = {
      "草" => {:src => [7,  0]},
    }
  end

  update do
    draw_tip("草", *srect.center)
  end

  def draw_tip(key, x, y)
    info = @object_info[key]
    src = vec2[*info[:src]]
    SDL.blit_surface(@map_tip, @tip.x * src.x, @tip.y * src.y, @tip.x, @tip.y, screen, x, y)
  end

  run
end
