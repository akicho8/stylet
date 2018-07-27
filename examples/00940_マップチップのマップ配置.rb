require_relative "helper"

Stylet::Palette[:background] = [107, 140, 255]
Stylet::Palette[:font]       = [0, 0, 0]

class App < Stylet::Base
  include Helper::Cursor

  setup do
    @cursor.display = false

    @map_tip = SDL::Surface.load("../assets/images/dlmap/castle2.png")
    @map_tip.set_color_key(SDL::SRCCOLORKEY, 0)
    @map_tip = @map_tip.display_format
    @tip = vec2[16, 16]

    @object_info = {
      "草"    => {:src => [7,  0]},
      "・"    => {:src => [8,  0]},
      "赤"    => {:src => [28, 1], :base => "草"},
      "青"    => {:src => [28, 2], :base => "草"},
      :player => {:src => [19, 9]},
    }

    @field = [
      "草草草草草草草草草草草草草草草",
      "草・・・・・・・・・・・・・草",
      "草・赤・青・赤・青・赤・青・草",
      "草・・・・・・・・・・・・・草",
      "草・赤・青・赤・青・赤・青・草",
      "草・・・・・・・・・・・・・草",
      "草・赤・青・赤・青・赤・青・草",
      "草・・・・・・・・・・・・・草",
      "草・赤・青・赤・青・赤・青・草",
      "草・・・・・・・・・・・・・草",
      "草草草草草草草草草草草草草草草",
    ]

    @map_rect = vec2[@field.first.chars.size, @field.size]

    @player = vec2[1, 1]
  end

  update do
    @player.x += -Stylet.context.axis.left.repeat_0or1 + Stylet.context.axis.right.repeat_0or1
    @player.y += -Stylet.context.axis.up.repeat_0or1 + Stylet.context.axis.down.repeat_0or1
    @player.x = Stylet::Chore.clamp(@player.x, (0...@map_rect.x))
    @player.y = Stylet::Chore.clamp(@player.y, (0...@map_rect.y))

    @field.each_with_index do |row, y|
      row.chars.each_with_index do |key, x|
        draw_tip(key, x, y)
      end
    end

    draw_tip(:player, *@player)

    vputs "pos: #{@pos}"
  end

  def draw_tip(key, x, y)
    info = @object_info[key]
    src = vec2[*info[:src]]
    if info[:base]
      draw_tip(info[:base], x, y)
    end
    SDL.blit_surface(@map_tip, @tip.x * src.x, @tip.y * src.y, @tip.x, @tip.y, screen, x * @tip.x, y * @tip.y)
  end

  run
end
