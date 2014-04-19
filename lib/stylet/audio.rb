# -*- coding: utf-8 -*-
# 表示系のライブラリとは独立

require "pathname"
require "singleton"
require "forwardable"

module Stylet
  class Audio
    include Singleton

    class << self
      alias setup_once instance
    end

    def initialize
      if SDL.inited_system(SDL::INIT_AUDIO).zero?
        SDL.initSubSystem(SDL::INIT_AUDIO)
        SDL::Mixer.open(Stylet.config.sound_freq)
        Stylet.logger.debug "driver_name: #{SDL::Mixer.driver_name}" if Stylet.logger
      end
    end
  end

  module Music
    extend self

    # mp3,wav,mod等を再生する(再生できるチャンネルは1つだけ)
    def play(filename, volume: nil)
      return if Stylet.config.silent_music
      Audio.setup_once
      filename = Pathname(filename).expand_path
      if filename.exist?
        Stylet.logger.debug "play: #{filename}" if Stylet.logger
        SDL::Mixer.play_music(load(filename), -1)
        self.volume = volume if volume
      end
    end

    def volume=(v)
      v = (v / 1.0 * 128).to_i if v.kind_of? Float
      SDL::Mixer.set_volume_music(v)
    end

    # 曲の再生中？
    def play?
      SDL::Mixer.play_music?
    end

    # すべてのサウンド停止
    def halt
      SDL::Mixer.halt_music
    end

    # フェイドインで入れる
    def fade_in(filename, ms=1000)
      return if Stylet.config.silent_music
      SDL::Mixer.fade_in_music(load(filename), -1, ms)
    end

    # フェイドアウト
    def fade_out(ms=1000)
      SDL::Mixer.fade_out_music(ms)
    end

    def load(filename)
      SDL::Mixer::Music.load(Pathname(filename).expand_path.to_s)
    end
  end

  # 複数の効果音
  #
  # Stylet::SE.load_file("path/to/foo.ogg")
  # Stylet::SE[:foo].play
  #
  # Stylet::SE.load_file("path/to/foo.ogg", :key => :attack)
  # Stylet::SE[:attack].play
  #
  module SE
    extend self

    @data = {}

    def [](key)
      @data[key.to_sym] || NullEffect.new
    end

    def load_file(filename, volume: nil, key: nil)
      filename = Pathname(filename).expand_path
      unless filename.exist?
        Stylet.logger.debug "#{filename} not found" if Stylet.logger
        return
      end
      key ||= filename.basename(".*").to_s
      key = key.to_sym
      if @data[key]
        return
      end

      Audio.setup_once
      index = @data.size
      @channel_count = SDL::Mixer.allocate_channels(index.next)
      se = SoundEffect.new(index, SDL::Mixer::Wave.load(filename.to_s))
      se.volume = volume if volume
      Stylet.logger.debug "load_file: #{filename} volume:#{volume} channel_count:#{@channel_count}" if Stylet.logger
      @data[key] = se
    end

    def wait
      nil while @data.values.any? {|e| e.play? }
    end

    def inspect
      out = ""
      out << "spec=#{SDL::Mixer.spec.inspect}\n"
      out << "@channel_count=#{@channel_count.inspect}\n"
      out << "@data.keys=#{@data.keys.inspect}"
    end

    class Base
      def play
      end

      def play_if_halt
        unless play?
          play
        end
      end

      def play?
        false
      end

      def halt
      end

      def volume=(v)
      end
    end

    class NullEffect < Base
    end

    class SoundEffect < Base
      cattr_accessor(:volume_max) { 128 }

      def initialize(ch, wave)
        @ch = ch
        @wave = wave
      end

      def play
        SDL::Mixer.play_channel(@ch, @wave, 0)
      end

      def play?
        SDL::Mixer.play?(@ch)
      end

      def halt
        SDL::Mixer.halt(@ch)
      end

      def volume=(v)
        @wave.set_volume(volume_cast(v))
      end

      private

      def volume_cast(v)
        if v.kind_of? Float
          (v / 1.0 * volume_max).to_i
        else
          v
        end
      end
    end
  end
end

if $0 == __FILE__
  require_relative "../stylet"

  Stylet::Music.play("#{__dir__}/assets/bgm.wav")
  p Stylet::Music.play?
  sleep(3)
  p Stylet::Music.fade_out
  nil while Stylet::Music.play?

  Stylet::SE.load_file("#{__dir__}/assets/se.wav")
  Stylet::SE["se"].play
  Stylet::SE.wait
end
