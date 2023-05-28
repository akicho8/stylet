# -*- coding: utf-8; compile-command: "bundle exec rsdl benchmark.rb" -*-
require "bundler/setup"
Bundler.require(:default)

BLOCK_N = 4

SDL2.init(SDL2::INIT_EVERYTHING)

flags = 0
flags |= SDL2::HWSURFACE
flags |= SDL2::DOUBLEBUF
flags |= SDL2::HWACCEL
# flags |= SDL2::NOFRAME
# flags |= SDL2::FULLSCREEN
@screen = SDL2.set_video_mode(640, 480, 16, flags)
@window_rect = Vector2d(@screen.w, @screen.h)

@item_index = 0
@frame_counter = 0

@fps = 1
@fps_counter = 0
@old_time = SDL2.get_ticks

@cell_wh        = @window_rect * 0.9 / BLOCK_N
@inner_top_left = @window_rect * 0.5 - @cell_wh * BLOCK_N * 0.5

loop do
  while event = SDL2::Event2.poll
    case event
    when SDL2::Event2::Quit
      exit
    when SDL2::Event2::KeyDown
      if event.sym == SDL2::Key::Scan::ESCAPE || event.sym == SDL2::Key::Scan::Q
        exit
      end
      if event.sym == SDL2::Key::Scan::LEFT
        @item_index -= 1
      end
      if event.sym == SDL2::Key::Scan::RIGHT
        @item_index += 1
      end
    end
  end

  @fps_counter += 1
  v = SDL2.get_ticks
  t = v - @old_time
  if t >= 1000
    @fps = @fps_counter
    @old_time = v
    @fps_counter = 0
    p @fps
  end

  @screen.fill_rect(0, 0, *@window_rect, [0, 0, 0])

  BLOCK_N.times do |y|
    BLOCK_N.times do |x|
      center = @inner_top_left + @cell_wh * Vector2d(x, y) + @cell_wh * 0.5
      radius = @cell_wh * 0.5 * 0.95
      top_left = center - radius
      rgb = rand(2).zero? ? [255, 0, 0] : [255, 255, 255]
      @screen.fill_rect(*top_left, *(radius * 2), rgb)
    end
  end

  @frame_counter += 1
  @screen.flip
end
