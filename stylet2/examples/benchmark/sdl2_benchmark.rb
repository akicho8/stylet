# -*- coding: utf-8; compile-command: "bundle exec ruby sdl2_benchmark.rb" -*-
require "bundler/setup"
require "sdl2"
CELL_N = 20
SDL2.init(SDL2::INIT_EVERYTHING)
flags = 0
# flags |= SDL2::Window::Flags::FULLSCREEN
# flags |= SDL2::Window::Flags::FULLSCREEN_DESKTOP
pos = SDL2::Window::POS_CENTERED
window = SDL2::Window.create("(Title)", pos, pos, 640, 480, flags)
flags = 0
flags |= SDL2::Renderer::Flags::ACCELERATED
# flags |= SDL2::Renderer::Flags::PRESENTVSYNC
renderer = window.create_renderer(-1, flags)

w = window.size[0] / CELL_N
h = window.size[1] / CELL_N
seconds = 3
i = 0
seconds.times do
  while ev = SDL2::Event.poll
  end
  t = SDL2.get_ticks + 1000
  loop do
    if SDL2.get_ticks >= t
      break
    end
    renderer.draw_color = [rand(256), rand(256), rand(256)]
    renderer.fill_rect(SDL2::Rect.new(w * rand(CELL_N), h * rand(CELL_N), w, h))
    i += 1
  end
  renderer.present
end
p i / (seconds * 60)
