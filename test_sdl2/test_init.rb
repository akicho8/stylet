require "./setup"
SDL2::INIT_TIMER          # => 1
SDL2::INIT_AUDIO          # => 16
SDL2::INIT_VIDEO          # => 32
SDL2::INIT_JOYSTICK       # => 512
SDL2::INIT_HAPTIC         # => 4096
SDL2::INIT_GAMECONTROLLER # => 8192
SDL2::INIT_EVENTS         # => 16384
SDL2::INIT_EVERYTHING     # => 62001
SDL2::INIT_NOPARACHUTE    # => 1048576
SDL2.init(SDL2::INIT_EVERYTHING)
