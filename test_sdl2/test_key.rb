require "./setup"

# SDL2.init(SDL2::INIT_EVERYTHING)

SDL2::Key.keycode_from_name("A")     # => 97
SDL2::Key.keycode_from_name("Space") # => 32
SDL2::Key.keycode_from_scancode(SDL2::Key::Scan::SPACE)   # => 0
SDL2::Key.name_of(32)                # => "Space"
SDL2::Key.pressed?(32)               # => false

# Shiftキーなどを押した状態をシミュレートする？？？
SDL2::Key::Mod::SHIFT                # => 3
SDL2::Key::Mod.state                 # => 0
SDL2::Key::Mod.state = SDL2::Key::Mod::SHIFT                 # => 3
SDL2::Key::Mod.state                 # => 3

SDL2::Key::Scan::SPACE               # => 44
SDL2::Key::Scan.from_keycode(97)     # => 0
SDL2::Key::Scan.from_name("A")       # => 4
SDL2::Key::Scan.name_of(4)           # => "A"
