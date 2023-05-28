# -*- compile-command: "bundle exec rsdl sdl1_benchmark.rb" -*-
require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "rubysdl", require: "sdl"
  gem "rsdl"
end

CELL_N = 20
SDL.init(SDL::INIT_EVERYTHING)
flags = 0
flags |= SDL::HWSURFACE
flags |= SDL::DOUBLEBUF
flags |= SDL::HWACCEL
# flags |= SDL::NOFRAME
# flags |= SDL::FULLSCREEN
screen = SDL.set_video_mode(640, 480, 16, flags)
w = screen.w / CELL_N
h = screen.h / CELL_N
seconds = 3
i = 0
seconds.times do
  while SDL::Event2.poll
  end
  t = SDL.get_ticks + 1000
  loop do
    if SDL.get_ticks >= t
      break
    end
    rgb = [rand(256), rand(256), rand(256)]
    screen.fill_rect(w * rand(CELL_N), h * rand(CELL_N), w, h, rgb)
    i += 1
  end
  screen.flip
end
p i / (seconds * 60)
