# https://ohai.github.io/ruby-sdl2/doc-en/SDL2/Display.html
require "./setup"

SDL2.init(SDL2::INIT_EVERYTHING)
SDL2::Display.displays          # => [#<SDL2::Display:0x00007fded482cfe8 @index=0, @name="Color LCD">]

display = SDL2::Display.displays.first
display.index                   # => 0
display.name                    # => "Color LCD"
display.bounds                  # => <SDL2::Rect: x=0 y=0 w=1680 h=1050>
# display.closet_mode           # => <SDL2::Rect: x=0 y=0 w=1680 h=1050>
display.current_mode            # => <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=1680 h=1050 refresh_rate=60>
display.desktop_mode            # => <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=1680 h=1050 refresh_rate=60>

mode = display.modes.first
mode.format                     # => <SDL2::PixelFormat: SDL_PIXELFORMAT_ARGB8888 type=6 order=3 layout=6 bits=32 bytes=4 indexed=false alpha=true fourcc=false>
mode.h                          # => 1800
mode.w                          # => 2880
mode.refresh_rate               # => 60

tp display.modes.collect(&:inspect)
# >> |--------------------------------------------------------------------------------------|
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=2880 h=1800 refresh_rate=60> |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=2560 h=1600 refresh_rate=60> |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=2048 h=1280 refresh_rate=60> |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=1680 h=1050 refresh_rate=60> |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=1650 h=1050 refresh_rate=60> |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=1440 h=900 refresh_rate=60>  |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=1280 h=800 refresh_rate=60>  |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=1152 h=720 refresh_rate=60>  |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=1024 h=768 refresh_rate=60>  |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=1024 h=640 refresh_rate=60>  |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=840 h=524 refresh_rate=60>   |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=825 h=525 refresh_rate=60>   |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=800 h=600 refresh_rate=60>   |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=720 h=450 refresh_rate=60>   |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=640 h=480 refresh_rate=60>   |
# >> |--------------------------------------------------------------------------------------|
