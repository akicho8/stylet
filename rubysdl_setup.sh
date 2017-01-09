#!/bin/sh
brew uninstall --ignore-dependencies libogg
brew uninstall --ignore-dependencies libvorbis
brew uninstall --ignore-dependencies libpng

brew uninstall --ignore-dependencies sdl
brew uninstall --ignore-dependencies sdl_ttf
brew uninstall --ignore-dependencies sdl_mixer
brew uninstall --ignore-dependencies sdl_image
brew uninstall --ignore-dependencies sdl_gfx
brew uninstall --ignore-dependencies sdl_net
brew uninstall --ignore-dependencies sdl_rtf
brew uninstall --ignore-dependencies sdl_sound
brew uninstall --ignore-dependencies sge

brew update

brew install libogg
brew install libvorbis
brew install libpng

brew install sdl
brew install sdl_mixer
brew install sdl_ttf
brew install sdl_image

# SGE install from gist
# brew install https://gist.github.com/mitmul/5410467/raw/c4fa716635e951b61f489726976b10f00dd41306/sge.rb

gem uninstall -ax rsdl
gem install rsdl

gem uninstall -ax rubysdl
gem install specific_install
# gem install rubysdl
# gem install rubysdl -- --enable-bundled-sge

# # いつのまにか効かなくなった
# gem specific_install ohai/rubysdl -- --enable-bundled-sge

gem git_install ohai/rubysdl -- --enable-bundled-sge

# Ruby/SDL 附属の SGE を使う
gem install rubysdl -- --enable-bundled-sge

# これは Gemfile 用
# 要は bundler の方も gem install rubysdl -- --enable-bundled-sge を実行してほしい。
# それには次の指定で ~/.bundle/config に BUNDLE_BUILD__RUBYSDL: "--enable-bundled-sge" を追加することで対応する。
bundle config --local build.rubysdl --enable-bundled-sge
bundle config | grep sge

# 確認
ruby -r sdl -e 'p SDL::VERSION'
ruby -r sdl -e 'p [:ttf, SDL.constants.include?(:TTF)]'
ruby -r sdl -e 'p [:mixer, SDL.constants.include?(:Mixer)]'
ruby -r sdl -e 'p [:sge, SDL.respond_to?(:auto_lock)]'
# ruby -r sdl -e 'p [:sge, SDL.defined?(:CollisionMap)]'

# ↓これが動かない
rsdl -r sdl -e 'SDL.init(SDL::INIT_EVERYTHING); SDL.set_video_mode(640, 480, 16, SDL::SWSURFACE); sleep(3)'

# rsdl -r stylet -e 'Stylet.run { vputs "Hello, world." }'
