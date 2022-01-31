require "./setup"

SDL2.init(SDL2::INIT_EVERYTHING)

window = SDL2::Window.create("(WindowTitle)", SDL2::Window::POS_CENTERED, SDL2::Window::POS_CENTERED, 640, 480, 0)
window.size             # => [640, 480]
window.gl_drawable_size # => [640, 480]
window.maximum_size     # => [0, 0]
