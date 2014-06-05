# -*- coding: utf-8 -*-
# 曲と効果音の管理
#
# ・表示系のライブラリとは独立
# ・チャンネルとWAVの音量は独立している
# ・SEの解放時、対応チャンネルを誰も使わなくなっていたら消して再割り当てする

require 'pathname'
require 'singleton'
require 'forwardable'
require 'active_support/core_ext/module/delegation' # Defines Module#delegate.
require 'active_support/core_ext/module/attribute_accessors' # Defines Module#mattr_accessor

module Stylet
  class Audio
    include Singleton

    class << self
      alias setup_once instance

      delegate :halt, :to => "Stylet::Audio.instance"

      def volume_cast(v)
        raise if v.kind_of? Integer
        (v / 1.0 * 128).to_i
      end
    end

    def initialize
      if SDL.inited_system(SDL::INIT_AUDIO).zero?
        SDL.initSubSystem(SDL::INIT_AUDIO)
        SDL::Mixer.open(Stylet.config.sound_freq, SDL::Mixer::DEFAULT_FORMAT, 2, 512) # デフォルトの4096では効果音が遅延する
        spec_check
      end
    end

    def halt
      SDL::Mixer.halt(-1)
      SDL::Mixer.halt_music
    end

    def spec_check
      return unless Stylet.logger
      Stylet.logger.debug "SDL::Mixer.driver_name: #{SDL::Mixer.driver_name.inspect}"
      Stylet.logger.debug "SDL::Mixer.spec: #{Hash[[:frequency, :format, :channels].zip(SDL::Mixer.spec)]}"
    end
  end

  module Music
    extend self

    mattr_accessor :current_music_file # 最後に再生したファイル

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
    def halt(fade_out_ms: nil)
      if fade_out_ms
        SDL::Mixer.fade_out_music(fade_out_ms)
      else
        SDL::Mixer.halt_music
      end
    end

    def fade_out(fade_out_ms: 1000)
      halt(fade_out_ms: fade_out_ms)
    end

    def load(filename)
      destroy
      filename = Pathname(filename).expand_path.to_s
      self.current_music_file = filename
      @muisc = SDL::Mixer::Music.load(filename)
    end

    def destroy
      if @muisc
        raise if @muisc.destroyed?
        @muisc.destroy
        @muisc = nil
      end
    end
  end

  # 複数の効果音
  #
  #   Stylet::SE.load_file("path/to/foo.wav")
  #   Stylet::SE[:foo].play
  #
  module SE
    extend self

    mattr_accessor :allocated_channels
    self.allocated_channels = 0

    mattr_accessor :se_hash
    self.se_hash = {}

    mattr_accessor :channel_groups
    self.channel_groups = {}

    def [](key)
      se_hash[key.to_sym] || NullEffect.new
    end

    def exist?(key)
      se_hash[key.to_sym]
    end

    def load_file(filename, volume: 1.0, key: nil, channel_group: nil, preload: false)
      return if Stylet.config.silent_all

      filename = Pathname(filename).expand_path
      unless filename.exist?
        Stylet.logger.debug "#{filename} が見つかりません" if Stylet.logger
        return
      end

      key ||= filename.basename(".*").to_s
      key = key.to_sym
      if se_hash[key]
        Stylet.logger.debug "すでに #{filename} (#{key.inspect}) が登録されています" if Stylet.logger
        return
      end

      channel_group ||= key
      channel_groups[channel_group] ||= {:channel => channel_groups.size, :counter => 0}
      channel_groups[channel_group][:counter] += 1

      Audio.setup_once
      self.allocated_channels = SDL::Mixer.allocate_channels(channel_groups.size)
      se_hash[key] = SoundEffect.new(key: key, :channel_group => channel_group, filename: filename, volume: volume, preload: preload)
    end

    # チャンネル利用者を減らしていき
    # 誰もチャンネルを利用していなければチャンネル自体を解放
    def destroy_all(keys = se_hash.keys)
      Array(keys).collect(&:to_sym).each do |key|
        if se = se_hash.delete(key)
          raise if channel_groups[se.channel_group][:counter] <= 0
          channel_groups[se.channel_group][:counter] -= 1
          if channel_groups[se.channel_group][:counter] == 0
            channel_groups.delete(se.channel_group)
          end
          se.destroy
        end
      end

      # 再割り当て
      self.allocated_channels = SDL::Mixer.allocate_channels(channel_groups.size)
      channel_groups.each_value.with_index{|e, i|e[:channel] = i}
    end

    # nil while se_hash.values.any? {|e| e.play? }
    def wait_if_playing?
      nil until SDL::Mixer.playing_channels.zero?
    end

    # すべてのチャンネルを停止する
    def halt_all
      SDL::Mixer.halt(-1)
    end

    class Base
      def play(*)
      end

      def play?
        false
      end

      def halt(*)
      end

      def volume
        0
      end

      def volume=(v)
      end
    end

    class NullEffect < Base
    end

    class SoundEffect < Base
      attr_accessor :filename, :key, :channel_group
      attr_reader :volume

      def initialize(filename:, key:, channel_group:, volume:, preload: false)
        @filename = Pathname(filename).expand_path
        @key = key
        @channel_group = channel_group

        self.volume = volume

        if preload
          preload()
        end

        Stylet.logger.debug spec if Stylet.logger
      end

      def play(loop: false)
        SDL::Mixer.play_channel(channel, wave, loop ? -1 : 0)
      end

      def play?
        SDL::Mixer.play?(channel)
      end

      def halt(fade_out_ms: nil)
        if fade_out_ms
          SDL::Mixer.fade_out(channel, fade_out_ms)
        else
          SDL::Mixer.halt(channel)
        end
      end

      def volume=(v)
        wave.set_volume(Audio.volume_cast(@volume = v))
      end

      def channel
        SE.channel_groups.fetch(@channel_group)[:channel]
      end

      def destroy
        if @wave
          raise if @wave.destroyed_
          @wave.destroy
          @wave = nil
        end
      end

      def preload
        wave
      end

      def wave
        @wave ||= SDL::Mixer::Wave.load(@filename.to_s)
      end

      def spec
        "#{@filename} volume:#{@volume} channel:#{channel}/#{SE.allocated_channels} #{@wave ? :loaded : :new}"
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

  Stylet::SE.load_file("#{__dir__}/../../sound_effects/pc_puyo_puyo_fever/VOICE/CH00VO00.WAV", :key => :a, :channel_group => :x, :volume => 0.1)
  Stylet::SE.load_file("#{__dir__}/../../sound_effects/pc_puyo_puyo_fever/VOICE/CH00VO01.WAV", :key => :b, :channel_group => :x, :volume => 0.1)
  Stylet::SE.load_file("#{__dir__}/../../sound_effects/pc_puyo_puyo_fever/VOICE/CH00VO02.WAV", :key => :c,                       :volume => 0.1)
  p Stylet::SE.se_hash[:a].channel
  p Stylet::SE.se_hash[:b].channel
  p Stylet::SE.se_hash[:c].channel
  Stylet::SE[:a].play
  Stylet::SE.wait_if_playing?
  Stylet::SE[:b].play
  Stylet::SE.wait_if_playing?
  Stylet::SE.destroy_all(:a)
  p Stylet::SE.se_hash.keys
  p Stylet::SE.se_hash[:b].channel # a が消されたので 1 から 0 に変わっている
  Stylet::SE[:a].play              # NullEffect
  Stylet::SE[:b].play
  p Stylet::SE[:b].spec
  Stylet::SE.wait_if_playing?
end
