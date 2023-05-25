# require "./setup"

require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "ruby-sdl2", require: "sdl2"
end

SDL2::MessageBox.show({
    flags: SDL2::MessageBox::INFORMATION,
    title: "",
    message: "アイテムを選択してください",
    buttons: [
      { flags: 0, id: 1,  text: "アイテム1" },
      { flags: 0, id: 2,  text: "アイテム2" },
      { flags: 0, id: 3,  text: "アイテム3" },
    ],
  })                            # => 


selected_id = SDL2::MessageBox.show({
    flags: SDL2::MessageBox::WARNING,
    title: "最終確認",
    message: "本当に削除してもよろしいですか？",
    buttons: [
      { flags: 0,                                          id: 1,  text: "削除する" },
      { flags: SDL2::MessageBox::BUTTON_RETURNKEY_DEFAULT, id: 0,  text: "戻る"     },
    ],
  })
selected_id                     # => 

selected_id = SDL2::MessageBox.show({
    flags: SDL2::MessageBox::WARNING,
    title: "最終確認",
    message: "本当に削除してもよろしいですか？",
    buttons: [
      { flags: 0,                                          id: 1,  text: "削除する"                },
      { flags: SDL2::MessageBox::BUTTON_RETURNKEY_DEFAULT, id: 0,  text: "戻る"                    },
      { flags: SDL2::MessageBox::BUTTON_ESCAPEKEY_DEFAULT, id: -1, text: "[esc]にも反応するボタン" },
    ],
  })
selected_id                     # => 
