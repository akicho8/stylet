require "./setup"

SDL2.init(SDL2::INIT_EVERYTHING)

loop do
  while ev = SDL2::Event.poll
    p ev
    if ev.kind_of?(SDL2::Event::KeyDown)
      p ev.scancode
      if ev.scancode == SDL2::Key::Scan::ESCAPE
        exit
      end
      if ev.scancode == SDL2::Key::Scan::Q
        exit
      end
    end
  end
end

