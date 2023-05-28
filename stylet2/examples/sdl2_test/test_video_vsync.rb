require "./setup"

SDL2.init(SDL2::INIT_EVERYTHING)

window = SDL2::Window.create("(WindowTitle)", SDL2::Window::POS_CENTERED, SDL2::Window::POS_CENTERED, 640, 480, 0)
renderer = window.create_renderer(-1, SDL2::Renderer::Flags::PRESENTVSYNC)

fps = 0
old_time = SDL2.get_ticks

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

  fps += 1
  v = SDL2.get_ticks
  t = v - old_time
  if t >= 1000
    puts "#{fps} FPS"
    old_time = v
    fps = 0
  end
end
