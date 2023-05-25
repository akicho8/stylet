# require "./setup"

require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "ruby-sdl2", require: "sdl2"
end

selected_id = SDL2::MessageBox.show({
    flags: SDL2::MessageBox::WARNING,
    window: nil,
    title: "タイトル",
    message: "メッセージ",
    buttons: [
      {
        # flags is ignored
        id: 0,
        text: "No",
      },
      {
        flags: SDL2::MessageBox::BUTTON_RETURNKEY_DEFAULT,
        id: 100,
        text: "Yes",
      },
      {
        flags: SDL2::MessageBox::BUTTON_ESCAPEKEY_DEFAULT,
        id: 2,
        text: "Cancel",
      },
    ],
    color_scheme: {
      bg: [255, 0, 0],
      text: [0, 255, 0],
      button_border: [255, 0, 0],
      button_bg: [0, 0, 255],
      button_selected: [255, 0, 0]
    },
  })
selected_id                     # => 100
