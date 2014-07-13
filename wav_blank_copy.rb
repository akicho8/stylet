# -*- coding: utf-8 -*-
# 58バイトの WAV を blank.wav で置き換える
require "pathname"
require "shellwords"
path = "sound_effects/replacement/**/*.{WAV,wav}"
Pathname.glob(Pathname(path).expand_path){|in_file|
  if in_file.size == 58
    system "cp -v blank.wav #{in_file.to_s.shellescape}"
  end
}
