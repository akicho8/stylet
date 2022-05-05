require "bundler/setup"
Bundler.require(:default)

SDL2.init(SDL2::INIT_EVERYTHING)
pos = SDL2::Window::POS_CENTERED
window = SDL2::Window.create("(title)", pos, pos, 640, 480, 0)
flags = 0
flags |= SDL2::Renderer::Flags::PRESENTVSYNC
renderer = window.create_renderer(-1, flags)

120.times do
  SDL2::Event.poll
  renderer.present
end
