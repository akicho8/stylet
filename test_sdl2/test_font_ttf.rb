require "./setup"

SDL2.init(SDL2::INIT_EVERYTHING)

window = SDL2::Window.create("(WindowTitle)", SDL2::Window::POS_CENTERED, SDL2::Window::POS_CENTERED, 640, 480, 0)
renderer = window.create_renderer(-1, SDL2::Renderer::Flags::PRESENTVSYNC)

SDL2::TTF.init
font_file = Pathname("~/src/stylet/assets/fonts/ipag-mona.ttf").expand_path.to_s
point_size = 80                 # 解像度
@ttf = SDL2::TTF.open(font_file, point_size)

count = 0
loop do
  while ev = SDL2::Event.poll
    case ev
    when SDL2::Event::KeyDown
      if ev.scancode == SDL2::Key::Scan::ESCAPE
        exit
      end
      if ev.scancode == SDL2::Key::Scan::Q
        exit
      end
    end
  end

  renderer.draw_color = [0, 0, 0]
  renderer.clear

  # ttf -> surface -> texture として renderer.copy で描画する
  color = [0, 255, 255]
  surface = @ttf.render_solid("#{count}", color)                # ギザギザ
  surface = @ttf.render_shaded("#{count}", color, [128, 0, 0])  # なめらか + 背景色付き
  surface = @ttf.render_blended("#{count}", color)              # なめらか
  texture = renderer.create_texture_from(surface)
  rect = SDL2::Rect.new(0, 0, 64, 64)                           # 表示するエリア
  renderer.copy(texture, nil, nil)                              # 全体に表示
  renderer.copy(texture, nil, rect)                             # 表示するエリアを指定

  renderer.present
  count += 1
end
