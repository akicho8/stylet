require "./setup"

SDL2.init(SDL2::INIT_EVERYTHING)

loop do
  while ev = SDL2::Event.poll
    p ev
    case ev
    when SDL2::Event::KeyDown
      p ev.scancode
      if ev.scancode == SDL2::Key::ESCAPE
        exit
      end
      if ev.scancode == SDL2::Key::Q
        exit
      end
    end
  end
end
