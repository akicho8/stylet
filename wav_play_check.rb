#!/usr/local/var/rbenv/shims/ruby
# -*- coding: utf-8 -*-
require "sdl"

SDL::init(SDL::INIT_AUDIO)
SDL::Mixer.open(44100 / 2)

2.times do
  music = SDL::Mixer::Music.load("_out48000.wav")
  SDL::Mixer.play_music(music, 0)
  nil while SDL::Mixer::play_music?

  music = SDL::Mixer::Music.load("_out44100.wav")
  SDL::Mixer.play_music(music, 0)
  nil while SDL::Mixer::play_music?
end

