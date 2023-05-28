# https://ohai.github.io/ruby-sdl2/doc-en/SDL2/Display.html
require "./setup"

SDL2.init(SDL2::INIT_EVERYTHING)
SDL2::Display.displays          # => [#<SDL2::Display:0x000000010fe84648 @index=0, @name="0">]

SDL2::Display.displays.count # => 1
display = SDL2::Display.displays.first
display.index                   # => 0
display.name                    # => "0"
display.bounds                  # => <SDL2::Rect: x=0 y=0 w=1800 h=1169>
# display.closet_mode           # => 
display.current_mode            # => <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=1800 h=1169 refresh_rate=120>
display.desktop_mode            # => <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=1800 h=1169 refresh_rate=120>

mode = display.modes.first
mode.format                     # => <SDL2::PixelFormat: SDL_PIXELFORMAT_ARGB8888 type=6 order=3 layout=6 bits=32 bytes=4 indexed=false alpha=true fourcc=false>
mode.h                          # => 1964
mode.w                          # => 3024
mode.refresh_rate               # => 120

tp display.modes.collect(&:inspect)
# >> |---------------------------------------------------------------------------------------|
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=3024 h=1964 refresh_rate=120> |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=3024 h=1964 refresh_rate=60>  |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=3024 h=1964 refresh_rate=50>  |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=3024 h=1964 refresh_rate=48>  |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=3024 h=1890 refresh_rate=120> |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=3024 h=1890 refresh_rate=60>  |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=3024 h=1890 refresh_rate=50>  |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=3024 h=1890 refresh_rate=48>  |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=2704 h=1756 refresh_rate=120> |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=2704 h=1756 refresh_rate=60>  |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=2704 h=1756 refresh_rate=50>  |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=2704 h=1756 refresh_rate=48>  |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=2704 h=1690 refresh_rate=120> |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=2704 h=1690 refresh_rate=60>  |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=2704 h=1690 refresh_rate=50>  |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=2704 h=1690 refresh_rate=48>  |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=2560 h=1600 refresh_rate=120> |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=2560 h=1600 refresh_rate=60>  |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=2560 h=1600 refresh_rate=50>  |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=2560 h=1600 refresh_rate=48>  |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=2294 h=1490 refresh_rate=120> |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=2294 h=1490 refresh_rate=60>  |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=2294 h=1490 refresh_rate=50>  |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=2294 h=1490 refresh_rate=48>  |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=2294 h=1432 refresh_rate=120> |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=2294 h=1432 refresh_rate=60>  |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=2294 h=1432 refresh_rate=50>  |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=2294 h=1432 refresh_rate=48>  |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=2048 h=1330 refresh_rate=120> |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=2048 h=1330 refresh_rate=60>  |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=2048 h=1330 refresh_rate=50>  |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=2048 h=1330 refresh_rate=48>  |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=2048 h=1280 refresh_rate=120> |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=2048 h=1280 refresh_rate=60>  |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=2048 h=1280 refresh_rate=50>  |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=2048 h=1280 refresh_rate=48>  |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=1920 h=1200 refresh_rate=120> |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=1920 h=1200 refresh_rate=60>  |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=1920 h=1200 refresh_rate=50>  |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=1920 h=1200 refresh_rate=48>  |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=1800 h=1169 refresh_rate=120> |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=1800 h=1169 refresh_rate=60>  |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=1800 h=1169 refresh_rate=50>  |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=1800 h=1169 refresh_rate=48>  |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=1800 h=1125 refresh_rate=120> |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=1800 h=1125 refresh_rate=60>  |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=1800 h=1125 refresh_rate=50>  |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=1800 h=1125 refresh_rate=48>  |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=1512 h=982 refresh_rate=120>  |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=1512 h=982 refresh_rate=60>   |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=1512 h=982 refresh_rate=50>   |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=1512 h=982 refresh_rate=48>   |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=1512 h=945 refresh_rate=120>  |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=1512 h=945 refresh_rate=60>   |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=1512 h=945 refresh_rate=50>   |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=1512 h=945 refresh_rate=48>   |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=1352 h=878 refresh_rate=120>  |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=1352 h=878 refresh_rate=60>   |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=1352 h=878 refresh_rate=50>   |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=1352 h=878 refresh_rate=48>   |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=1352 h=845 refresh_rate=120>  |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=1352 h=845 refresh_rate=60>   |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=1352 h=845 refresh_rate=50>   |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=1352 h=845 refresh_rate=48>   |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=1280 h=800 refresh_rate=120>  |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=1280 h=800 refresh_rate=60>   |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=1280 h=800 refresh_rate=50>   |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=1280 h=800 refresh_rate=48>   |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=1147 h=745 refresh_rate=120>  |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=1147 h=745 refresh_rate=60>   |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=1147 h=745 refresh_rate=50>   |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=1147 h=745 refresh_rate=48>   |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=1147 h=716 refresh_rate=120>  |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=1147 h=716 refresh_rate=60>   |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=1147 h=716 refresh_rate=50>   |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=1147 h=716 refresh_rate=48>   |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=1024 h=665 refresh_rate=120>  |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=1024 h=665 refresh_rate=60>   |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=1024 h=665 refresh_rate=50>   |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=1024 h=665 refresh_rate=48>   |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=1024 h=640 refresh_rate=120>  |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=1024 h=640 refresh_rate=60>   |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=1024 h=640 refresh_rate=50>   |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=1024 h=640 refresh_rate=48>   |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=960 h=600 refresh_rate=120>   |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=960 h=600 refresh_rate=60>    |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=960 h=600 refresh_rate=50>    |
# >> | <SDL2::Display::Mode: format=SDL_PIXELFORMAT_ARGB8888 w=960 h=600 refresh_rate=48>    |
# >> |---------------------------------------------------------------------------------------|
