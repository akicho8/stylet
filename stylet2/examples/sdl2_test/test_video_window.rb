require "./setup"

SDL2.init(SDL2::INIT_EVERYTHING)

window = SDL2::Window.create("(WindowTitle)", SDL2::Window::POS_CENTERED, SDL2::Window::POS_CENTERED, 640, 480, 0)
renderer = window.create_renderer(-1, SDL2::Renderer::Flags::PRESENTVSYNC)

loop do
  while ev = SDL2::Event.poll
    case ev
    when SDL2::Event::KeyDown
      if ev.scancode == SDL2::Key::ESCAPE
        exit
      end
      if ev.scancode == SDL2::Key::Q
        exit
      end
    end
  end
  renderer.present
end
