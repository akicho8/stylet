require "./setup"

class MouseApp < Stylet2::Base
  def view
    super
    mouse_state = SDL2::Mouse.state
    mouse_pos = vec2(mouse_state.x, mouse_state.y)
    vputs mouse_pos
    renderer.draw_line(*(window_rect / 2), *mouse_pos)
  end

  run
end
