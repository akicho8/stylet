require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "ruby-sdl2", require: "sdl2"
end

# rb_define_const(mMessageBox, "BUTTON_RETURNKEY_DEFAULT",
# rb_define_const(mMessageBox, "BUTTON_ESCAPEKEY_DEFAULT",

# SDL2::MessageBox.show_simple_box(SDL2::MessageBox::INFORMATION, "(title)", "(message)", nil)
# SDL2::MessageBox.show_simple_box(SDL2::MessageBox::WARNING, "(title)", "(message)", nil)
# SDL2::MessageBox.show_simple_box(SDL2::MessageBox::ERROR, "(title)", "(message)", nil)

# def simple_message(body = nil, title: "", message: "", type: :information)
#   type = SDL2::MessageBox.const_get(type.upcase)
#   message = body || message
#   SDL2::MessageBox.show_simple_box(type, title, message, nil)
# end
#
# simple_message
# simple_message("PAUSE")
# simple_message(type: :error, title: "エラー", message: "あのイーハトーヴォのすきとおった風、夏でも底に冷たさをもつ青いそら、うつくしい森で飾られたモリーオ市、郊外のぎらぎらひかる草の波。")

button = SDL2::MessageBox.show(flags: SDL2::MessageBox::WARNING,
                               window: nil,
                               title: "警告ウインドウ",
                               message: "ここに警告文が出ます",
                               buttons: [ { # flags is ignored
                                           id: 0,
                                           text: "いいえ",
                                          },
                                         {flags: SDL2::MessageBox::BUTTON_RETURNKEY_DEFAULT,
                                          id: 1,
                                          text: "はい",
                                         },
                                         {flags: SDL2::MessageBox::BUTTON_ESCAPEKEY_DEFAULT,
                                          id: 2,
                                          text: "キャンセル",
                                         },
                                        ],
                               color_scheme: {
                                              bg: [255, 0, 0],
                                              text: [0, 255, 0],
                                              button_border: [255, 0, 0],
                                              button_bg: [0, 0, 255],
                                              button_selected: [255, 0, 0]
                                             }
                              )
p button
