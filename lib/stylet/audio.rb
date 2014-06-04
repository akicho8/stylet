# -*- coding: utf-8 -*-
# 表示系のライブラリとは独立
#
# ・チャンネルとWAVの音量は独立している
# ・チャンネルとWAVを1:1で割り当てている
# ・WAVを削除したときに再割り当て

require "pathname"
require "singleton"
require "forwardable"
require 'active_support/core_ext/module/delegation' # Defines Module#delegate.
require 'active_support/core_ext/module/attribute_accessors' # Defines Module#mattr_accessor

module Stylet
  class Audio
    include Singleton

    class << self
      alias setup_once instance

      delegate :halt, :to => "Stylet::Audio.instance"

      def volume_cast(v)
        if v.kind_of? Float
          (v / 1.0 * 128).to_i
        else
          v
        end
      end
    end

    def initialize
      if SDL.inited_system(SDL::INIT_AUDIO).zero?
        SDL.initSubSystem(SDL::INIT_AUDIO)
        SDL::Mixer.open(Stylet.config.sound_freq, SDL::Mixer::DEFAULT_FORMAT, 2, 512) # デフォルトの4096では効果音が遅延する
        if Stylet.logger
          Stylet.logger.debug "SDL::Mixer.driver_name: #{SDL::Mixer.driver_name.inspect}"
          Stylet.logger.debug "SDL::Mixer.spec: #{Hash[[:frequency, :format, :channels].zip(SDL::Mixer.spec)]}"
        end
      end
    end

    def halt
      SDL::Mixer.halt(-1)
      SDL::Mixer.halt_music
    end
  end

  module Music
    extend self

    mattr_accessor :current_music_file # 最後に再生したファイル

    # mp3,wav,mod等を再生する(再生できるチャンネルは1つだけ)
    def play(filename, volume: nil, loop: false, fade_in_ms: nil)
      return if Stylet.config.silent_music || Stylet.config.silent_all
      Audio.setup_once
      filename = Pathname(filename).expand_path
      if filename.exist?
        Stylet.logger.debug "play: #{filename}" if Stylet.logger
        bin = load(filename)
        loop = loop ? -1 : 0
        if fade_in_ms
          SDL::Mixer.fade_in_music(bin, loop, fade_in_ms)
        else
          SDL::Mixer.play_music(bin, loop)
        end
        self.volume = volume if volume
      end
    end

    def volume=(v)
      SDL::Mixer.set_volume_music(Audio.volume_cast(v))
    end

    # 曲の再生中？
    def play?
      SDL::Mixer.play_music?
    end

    # すべてのサウンド停止
    def halt
      SDL::Mixer.halt_music
    end

    # フェイドアウト
    def fade_out(ms=1000)
      SDL::Mixer.fade_out_music(ms)
    end

    def load(filename)
      destroy
      filename = Pathname(filename).expand_path.to_s
      self.current_music_file = filename
      @muisc = SDL::Mixer::Music.load(filename)
    end

    def destroy
      if @muisc
        @muisc.destroy
        @muisc = nil
      end
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

    mattr_accessor :allocated_channels
    self.allocated_channels = 0

    mattr_accessor :se_hash
    self.se_hash = {}

    def [](key)
      se_hash[key.to_sym] || NullEffect.new
    end

    def exist?(key)
      se_hash[key.to_sym]
    end

    def load_file(filename, volume: nil, key: nil)
      return if Stylet.config.silent_all

      filename = Pathname(filename).expand_path
      unless filename.exist?
        Stylet.logger.debug "#{filename} not found" if Stylet.logger
        return
      end
      key ||= filename.basename(".*").to_s
      key = key.to_sym
      if se_hash[key]
        return
      end

      Audio.setup_once
      self.allocated_channels = SDL::Mixer.allocate_channels(se_hash.size.next)
      se = SoundEffect.new(channel: se_hash.size, wave: SDL::Mixer::Wave.load(filename.to_s))
      se.volume = volume if volume
      Stylet.logger.debug "load_file: #{filename} volume:#{volume} allocated_channels:#{allocated_channels}" if Stylet.logger
      se_hash[key] = se
    end

    def destroy_all(keys = se_hash.keys)
      Array(keys).each{|key|
        if se = se_hash.delete(key.to_sym)
          se.destroy
        end
      }
      self.allocated_channels = SDL::Mixer.allocate_channels(se_hash.size)
      se_hash.each_value.with_index{|se, i|se.channel = i}
    end

    # nil while se_hash.values.any? {|e| e.play? }
    def wait
      nil until SDL::Mixer.playing_channels.zero?
    end

    def inspect
      out = ""
      out << "spec=#{SDL::Mixer.spec.inspect}\n"
      out << "self.allocated_channels=#{allocated_channels.inspect}\n"
      out << "se_hash.keys=#{se_hash.keys.inspect}"
    end

    # すべてのチャンネルを停止する
    def channel_all_stop
      SDL::Mixer.halt(-1)
    end

    class Base
      def play(*)
      end

      def play?
        false
      end

      def halt
      end

      def fade_out
      end

      def volume=(v)
      end
    end

    class NullEffect < Base
    end

    class SoundEffect < Base
      attr_accessor :channel, :wave

      def initialize(channel:, wave:)
        @channel = channel
        # @channel = -1
        @wave = wave
      end

      def play(loop: false)
        SDL::Mixer.play_channel(@channel, @wave, loop ? -1 : 0)
      end

      def play?
        SDL::Mixer.play?(@channel)
      end

      def halt
        SDL::Mixer.halt(@channel)
      end

      def fade_out(ms=1000)
        SDL::Mixer.fade_out(@channel, ms)
      end

      def volume=(v)
        @wave.set_volume(Audio.volume_cast(v))
      end

      def destroy
        if @wave
          halt
          @wave.destroy
          @wave = nil
        end
      end
    end
  end
end

if $0 == __FILE__
  require_relative "../stylet"

  # Stylet::Music.play("#{__dir__}/assets/bgm.wav")
  # p Stylet::Music.play?
  # sleep(3)
  # p Stylet::Music.fade_out
  # nil while Stylet::Music.play?

  Stylet::SE.load_file("#{__dir__}/../../sound_effects/pc_puyo_puyo_fever/VOICE/CH00VO00.WAV", :key => :a)
  Stylet::SE.load_file("#{__dir__}/../../sound_effects/pc_puyo_puyo_fever/VOICE/CH00VO01.WAV", :key => :b)
  p Stylet::SE.se_hash.keys
  Stylet::SE[:a].play
  Stylet::SE.wait
  Stylet::SE[:b].play
  Stylet::SE.wait
  Stylet::SE.destroy_all(:a)
  p Stylet::SE.se_hash.keys
  p Stylet::SE.se_hash[:b].channel # a が消されたので 1 から 0 に変わっている
  Stylet::SE[:a].play              # NullEffect
  Stylet::SE[:b].play
  Stylet::SE.wait
end
