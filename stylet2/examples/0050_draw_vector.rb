require "./setup"

class DrawVectorApp < Stylet2::Base
  def view
    super

    # draw_arrow(srect.center, srect.center + [50, 50])
    # draw_vector(vec2[100, -100], :origin => srect.center, :label => "ok")
    # draw_vector(vec2[100, 0], :origin => vec2[50, 50], :label => "ok")

    # mouse_state = SDL2::Mouse.state
    # mouse_pos = vec2(mouse_state.x, mouse_state.y)
    # vputs mouse_pos
    # renderer.draw_line(*(window_rect / 2), *mouse_pos)

    draw_arrow(window_rect * 0.5, (window_rect * 0.5) + vec2(100, 100))
  end

  run
end
