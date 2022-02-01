require "./setup"

SDL2.init(SDL2::INIT_EVERYTHING)

SDL2::Clipboard.text = "foo"
SDL2::Clipboard.has_text?      # => true
SDL2::Clipboard.text           # => "foo"

# 空にしたいときは空文字列を入れる
SDL2::Clipboard.text = ""      # => ""
SDL2::Clipboard.has_text?      # => false
SDL2::Clipboard.text           # => nil
