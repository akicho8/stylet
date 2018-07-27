require_relative "helper"

class App < Stylet::Base
  include Helper::Cursor

  setup do
    SDL::Mouse.hide
    @cursor.display = false

    @x = 1.0
    @y = 1.0

    reset

    # @test_var = 0
    # @menu = Stylet::Menu::Basic.new(name: "[メニュー]", elements: [
    #     {name: "モード", safe_command: proc {}, :value => proc { @test_var }, :change => proc {|v| @test_var += v }},
    #   ])
  end

  update do
    # @menu.update

    if button.btD.trigger?
      simple_background_clear
    end

    @b += (button.btA.repeat - button.btB.repeat) * 0.1

    10000.times do
      xn = Math.sin(@a * @y) - @c * Math.cos(@a * @x)
      yn = Math.sin(@b * @x) - @d * Math.cos(@b * @y)
      @x = xn
      @y = yn
      p0 = srect.center + [@x * srect.w * 0.3, @y * srect.h * 0.3]

      case
      when true
        r, g, b = screen.get_rgb(screen[*p0])
        r = Stylet::Chore.max_clamp(r + 4*1, 255)
        g = Stylet::Chore.max_clamp(g + 4*1, 255)
        b = Stylet::Chore.max_clamp(b + 4*4, 255)
        screen[*p0] = screen.format.map_rgb(r, g, b)
      when false
        s = 1
        screen.draw_filled_rect_alpha(p0.x-s, p0.y-s, s*2+1, s*2+1, [0, 255, 255], 16)
      when false
        screen.draw_filled_rect_alpha(p0.x, p0.y, 1, 1, [255, 255, 255], 128)
      end
    end
  end

  def background_clear
  end

  def system_infos
    []
  end

  def reset
    @a = 1.88
    @b = -1.7
    @c = -0.43
    @d = -0.74
  end

  run
end
