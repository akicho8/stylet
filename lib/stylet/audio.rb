# -*- coding: utf-8 -*-
#
# 曲と効果音の管理
#
#   曲
#
#     Music.play("path/to/foo.wav")
#
#   効果音
#
#     SE.load("path/to/foo.wav")
#     SE[:foo].play
#
# ・表示系のライブラリとは独立
# ・チャンネルとWAVの音量は独立している
# ・SEの解放時、対応チャンネルを誰も使わなくなっていたら消して再割り当てする
#
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

    def play(filename, volume: nil, loop: true, fade_in_sec: nil)
      return if Stylet.config.silent_music || Stylet.config.silent_all

      Audio.setup_once
      filename = Pathname(filename).expand_path
      if filename.exist?
        Stylet.logger.debug "play: #{filename}" if Stylet.logger
        bin = load(filename)
        loop = loop ? -1 : 0
        if fade_in_sec
          SDL::Mixer.fade_in_music(bin, loop, fade_in_sec * 1000.0)
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

    def wait_if_play?
      SDL.delay(1) while SDL::Mixer.play_music?
    end

    # すべてのサウンド停止
    def halt(fade_out_sec: nil)
      if fade_out_sec
        SDL::Mixer.fade_out_music(fade_out_sec * 1000.0)
      else
        SDL::Mixer.halt_music
      end
    end

    def fade_out(fade_out_sec: 2)
      halt(fade_out_sec: fade_out_sec)
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

  module SE
    extend self

    mattr_accessor :allocated_channels
    self.allocated_channels = 0

    mattr_accessor :se_hash
    self.se_hash = {}

    mattr_accessor :channel_groups
    self.channel_groups = {}

    mattr_accessor :preparation_channels
    self.preparation_channels = 0

    def [](key)
      se_hash[key.to_sym] || NullEffect.new
    end

    def exist?(key)
      se_hash[key.to_sym]
    end

    def load(filename, volume: 1.0, key: nil, channel_group: nil, preload: false, auto_assign: false)
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

      unless auto_assign
        channel_group ||= key
        channel_groups[channel_group] ||= {:channel => channel_groups.size, :counter => 0}
        channel_groups[channel_group][:counter] += 1
      end

      Audio.setup_once
      allocate_channels
      se_hash[key] = SoundEffect.new(key: key, :channel_group => channel_group, filename: filename, volume: volume, preload: preload, auto_assign: auto_assign)
    end

    def destroy_all(keys = se_hash.keys)
      Array(keys).collect(&:to_sym).each do |key|
        if se = se_hash.delete(key)
          unless se.auto_assign
            SE.channel_groups[se.channel_group][:counter] -= 1
          end
          se.destroy
        end
      end
      channel_reset
    end

    def channel_reset
      raise if SE.channel_groups.any?{|k, e|e[:counter] < 0}
      SE.channel_groups.delete_if{|k, e|e[:counter] == 0}
      allocate_channels
      channel_groups.each_value.with_index{|e, index|e[:channel] = index}
    end

    def allocate_channels
      self.allocated_channels = SDL::Mixer.allocate_channels(preparation_channels + channel_groups.size)
    end

    # nil while se_hash.values.any? {|e| e.play? }
    def wait_if_play?
      SDL.delay(1) until SDL::Mixer.playing_channels.zero?
    end

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

      def spec
      end
    end

    class NullEffect < Base
    end

    class SoundEffect < Base
      attr_reader :filename, :key, :channel_group, :volume, :auto_assign

      def initialize(filename:, key:, channel_group:, volume:, preload: false, auto_assign: false)
        raise if channel_group && auto_assign

        @filename = Pathname(filename).expand_path
        @key = key
        @channel_group = channel_group
        @volume = volume
        @auto_assign = auto_assign

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

      def halt(fade_out_sec: nil)
        if fade_out_sec
          SDL::Mixer.fade_out(channel, fade_out_sec * 1000)
        else
          SDL::Mixer.halt(channel)
        end
      end

      def volume=(v)
        @volume = v
        if @wave
          @wave.set_volume(Audio.volume_cast(v))
        end
      end

      def channel
        if @auto_assign
          if SE.allocated_channels == 0
            raise "SE.preparation_channels でチャンネル数を指定してください"
          end
          -1
        else
          SE.channel_groups.fetch(@channel_group)[:channel]
        end
      end

      def destroy
        if @wave
          raise if @wave.destroyed_
          @wave.destroy
          @wave = nil
        end
      end

      def wave
        @wave ||= SDL::Mixer::Wave.load(@filename.to_s).tap do |obj|
          obj.set_volume(Audio.volume_cast(@volume))
        end
      end

      alias preload wave

      def spec
        "#{@filename} volume:#{@volume} channel:#{channel}/#{SE.allocated_channels} #{@wave ? :loaded : :new}"
      end
    end
  end
end

if $0 == __FILE__
  require_relative "../stylet"
  require "rspec/autorun"

  describe do
    before do
      Stylet::SE.destroy_all
    end

    it do
      Stylet::Music.play("#{__dir__}/assets/bgm.wav")
      expect(Stylet::Music.play?).to eq true
      sleep(1)
      Stylet::Music.halt(fade_out_sec: 3)
      nil while Stylet::Music.play?
    end

    it do
      Stylet::SE.load("#{__dir__}/../../sound_effects/pc_puyo_puyo_fever/VOICE/CH00VO00.WAV", :key => :a, :channel_group => :x, :volume => 0.1)
      Stylet::SE.load("#{__dir__}/../../sound_effects/pc_puyo_puyo_fever/VOICE/CH00VO01.WAV", :key => :b,                       :volume => 0.1)
      Stylet::SE.load("#{__dir__}/../../sound_effects/pc_puyo_puyo_fever/VOICE/CH00VO02.WAV", :key => :c, :channel_group => :x, :volume => 0.1)

      expect(Stylet::SE[:a].spec).to match(/new/)    # ロードしていない
      Stylet::SE[:a].preload                         # 明示的にロードする
      expect(Stylet::SE[:a].spec).to match(/loaded/) # ロード済み

      expect(Stylet::SE.se_hash.values.collect(&:channel)).to eq [0, 1, 0] # a と c が同じチャンネルを共有していることがわかる

      Stylet::SE[:a].play       # a を再生するが
      sleep(0.2)
      Stylet::SE[:c].play       # c も同じチャンネルを使っているため a をキャンセルする
      Stylet::SE[:b].play       # b は別のチャンネルなので同時に再生できる
      Stylet::SE.wait_if_play?
      Stylet::SE.destroy_all(:a) # a を消しても c が 0 を利用しているため 0 チャンネルは残っている
      expect(Stylet::SE.se_hash.values.collect(&:channel)).to eq [1, 0]
      Stylet::SE.destroy_all(:c)             # c を消すと 0 チャンネルが消えて
      expect(Stylet::SE[:b].channel).to eq 0 # 再割り当てするため 1 チャンネルが消えて 0 チャンネルのみになる
    end

    it do
      Stylet::SE.preparation_channels = 10
      Stylet::SE.load("#{__dir__}/../../sound_effects/pc_puyo_puyo_fever/VOICE/CH00VO00.WAV", :key => :a, :auto_assign => true, :volume => 0.1)
      expect(Stylet::SE[:a].spec).to match("-1/10")
    end
  end
end
