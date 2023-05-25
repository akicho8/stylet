require "bundler/setup"
Bundler.require(:default)

SDL2.init(SDL2::INIT_EVERYTHING)
pos = SDL2::Window::POS_CENTERED
window = SDL2::Window.create("(title)", pos, pos, 640, 480, 0)
flags = 0
flags |= SDL2::Renderer::Flags::ACCELERATED
flags |= SDL2::Renderer::Flags::PRESENTVSYNC
renderer = window.create_renderer(-1, flags)

include Math

frame_counter = 0
loop do
  while ev = SDL2::Event.poll
    case ev
    when SDL2::Event::Quit
      exit
    when SDL2::Event::KeyDown
      case ev.scancode
      when SDL2::Key::Scan::ESCAPE
        exit
      when SDL2::Key::Scan::Q
        exit
      end
    end
  end

  renderer.draw_blend_mode = SDL2::BlendMode::BLEND
  renderer.draw_color = [0, 0, 64, 28]
  renderer.fill_rect(SDL2::Rect.new(0, 0, *window.size))

  renderer.draw_blend_mode = SDL2::BlendMode::NONE
  renderer.draw_color = [255, 255, 255]

  r = 64
  w, h = window.size
  x = w / 2 + cos(PI * frame_counter * 0.02 * 0.7) * w * 0.4
  y = h / 2 + sin(PI * frame_counter * 0.02 * 0.8) * h * 0.4
  renderer.fill_rect(SDL2::Rect.new(x - r, y - r, r * 2, r * 2))

  renderer.present
  frame_counter += 1
end
