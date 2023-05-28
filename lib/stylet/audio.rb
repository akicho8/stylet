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
# ・SE.preparation_channels SE自由席の数。
# ・チャンネルは先頭から [自由席] → [指定席] の順で使うようにしている。これ重要。
#   もし自由席の方が後だったらおかしなことになる。
#   SDLは《先頭から》空いているチャンネルを探して使う。
#   開始合図のラッパが0チャンネルが空いてるからと思って使った直後に0チャンネルを使う予定のSEが鳴ったらラッパの音消えてしまう。
#   したがってチャンネルは[自由席][指定席]の順になっている
#
require 'pathname'
require 'singleton'
require 'active_support/core_ext/module/delegation' # Defines Module#delegate.
require 'active_support/core_ext/module/attribute_accessors' # Defines Module#mattr_accessor

module Stylet
  class Audio
    include Singleton

    # 全体のフィイドアウト秒数
    cattr_accessor :fade_out_default
    self.fade_out_default = 2

    class << self
      alias setup_once instance

      delegate :halt, :to => "Stylet::Audio.instance"

      def volume_cast(v)
        raise if v.is_a? Integer
        (Stylet::Chore.clamp(v) / 1.0 * 128).to_i
      end
    end

    def initialize
      if SDL2.inited_system(SDL2::INIT_AUDIO).zero?
        SDL2.initSubSystem(SDL2::INIT_AUDIO)
        SDL2::Mixer.open(Stylet.config.sound_freq, SDL2::Mixer::DEFAULT_FORMAT, 2, 512) # デフォルトの4096では効果音が遅延する
        spec_check
      end
    end

    def halt
      Music.halt
      SE.halt
    end

    def spec_check
      return unless Stylet.logger
      Stylet.logger.debug "SDL2::Mixer.driver_name: #{SDL2::Mixer.driver_name.inspect}"
      Stylet.logger.debug "SDL2::Mixer.spec: #{Hash[[:frequency, :format, :channels].zip(SDL2::Mixer.spec)]}"
    end
  end

  module Music
    extend self

    # 最後に再生したファイル
    mattr_accessor :last_music_file
    self.last_music_file = nil

    # ボリュームの倍率
    mattr_accessor :volume_magnification
    self.volume_magnification = 1.0

    def play_by(params)
      play(params[:filename], **params)
    end

    def play(filename, volume: nil, loop: true, fade_in_sec: nil, **unsed_options)
      return if Stylet.config.music_mute || Stylet.config.mute

      Audio.setup_once

      filename = Pathname(filename).expand_path
      if filename.exist?
        Stylet.logger.debug "play: #{filename}" if Stylet.logger
        bin = load(filename)
        loop = loop ? -1 : 0
        if fade_in_sec
          SDL2::Mixer.fade_in_music(bin, loop, fade_in_sec * 1000.0)
        else
          SDL2::Mixer.play_music(bin, loop)
        end
        self.volume = volume if volume
      end
    end

    def volume=(v)
      SDL2::Mixer.set_volume_music(Audio.volume_cast(v * volume_magnification))
    end

    def play?
      SDL2::Mixer.play_music?
    end

    def wait_if_play?
      SDL2.delay(1) while SDL2::Mixer.play_music?
    end

    def halt(fade_out_sec: nil)
      if fade_out_sec
        SDL2::Mixer.fade_out_music(fade_out_sec * 1000.0)
      else
        SDL2::Mixer.halt_music
      end
    end

    def fade_out(fade_out_sec: Audio.fade_out_default)
      halt(fade_out_sec: fade_out_sec)
    end

    def last_music_file?(filename)
      last_music_file == Pathname(filename).expand_path.to_s
    end

    private

    def load(filename)
      destroy
      filename = Pathname(filename).expand_path.to_s
      self.last_music_file = filename
      @muisc = SDL2::Mixer::Music.load(filename)
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

    # 予約チャンネル数 (channel_auto を使うときに関係してくる)
    mattr_accessor :preparation_channels
    self.preparation_channels = 0

    # チャンネルボリュームの初期値
    # SDL2 は何もしないと 1.0 だけど音が大きすぎるため全チャンネルを 0.5 としている
    # WAVE毎にボリュームを設定できるため、この値は固定しておいた方がシンプルになる
    # この設定は不要かもしれない
    mattr_accessor :default_master_volume
    self.default_master_volume = 0.5

    # ボリューム倍率
    # アプリケーションのオプションなどで効果音の音量を設定するときはこの値を変更する
    # 実際に反映するのはボリュームを設定したときなので注意
    mattr_accessor :volume_magnification
    self.volume_magnification = 1.0

    def [](key)
      se_hash.fetch(key.to_sym) { NullEffect.new }
    end

    def exist?(key)
      se_hash[key.to_sym]
    end

    def load_once(params = {})
      return if exist?(params[:key])
      load(params[:filename], **params.except(:filename))
    end

    def load(filename, volume: 1.0, key: nil, channel_group: nil, channel_auto: false, preload: false)
      return if Stylet.config.mute

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

      SoundEffect.new(key: key, :channel_group => channel_group, filename: filename, volume: volume, channel_auto: channel_auto, preload: preload)
    end

    def destroy_all(keys = se_hash.keys)
      Array(keys).collect(&:to_sym).uniq.each do |key|
        if se = se_hash[key]
          se.destroy
        end
      end
      channel_reset
    end

    def channel_reset
      raise if SE.channel_groups.any? {|_, e|e[:counter] < 0}
      SE.channel_groups.delete_if {|_, e|e[:counter] == 0}
      allocate_channels
      channel_groups.each_value.with_index {|e, index|e[:channel] = SE.preparation_channels + index}
    end

    def allocate_channels
      self.allocated_channels = SDL2::Mixer.allocate_channels(SE.preparation_channels + channel_groups.size)
      SE.master_volume = SE.default_master_volume
    end

    # nil while se_hash.values.any? {|e| e.play? } と同等
    def wait_if_play?
      SDL2.delay(1) while play_any?
    end

    def play_any?
      SDL2::Mixer.playing_channels.nonzero?
    end

    def play_none?
      !play_any?
    end

    def halt(fade_out_sec: nil)
      if fade_out_sec
        SDL2::Mixer.fade_out(-1, fade_out_sec * 1000.0)
      else
        SDL2::Mixer.halt(-1)
      end
    end

    def fade_out(fade_out_sec: Audio.fade_out_default)
      halt(fade_out_sec: fade_out_sec)
    end

    def master_volume=(v)
      Audio.setup_once
      @master_volume = v
      # チャンネル数が0の状態で呼ぶとエラーになるため1以上としている
      if allocated_channels >= 1
        SDL2::Mixer.set_volume(-1, Audio.volume_cast(v))
      end
    end

    class Base
      def play(*)
      end

      def play?
        false
      end

      def halt(*)
      end

      def fade_out(fade_out_sec: Audio.fade_out_default)
        halt(fade_out_sec: fade_out_sec)
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
      attr_reader :filename, :key, :channel_group, :volume, :channel_auto

      def initialize(filename:, key:, channel_group:, volume:, channel_auto: false, preload: false)
        raise if channel_group && channel_auto

        @filename     = Pathname(filename).expand_path
        @key          = key
        @channel_auto = channel_auto
        @volume       = volume

        unless @channel_auto
          @channel_group = channel_group || key
        end

        unless @channel_auto
          SE.channel_groups[@channel_group] ||= {:channel => SE.preparation_channels + SE.channel_groups.size, :counter => 0}
          SE.channel_groups[@channel_group][:counter] += 1
        end

        Audio.setup_once
        SE.allocate_channels
        SE.se_hash[@key] = self

        if preload
          preload!
        end

        Stylet.logger.debug "new: #{spec}" if Stylet.logger
      end

      def play(loop: false)
        SDL2::Mixer.play_channel(channel, wave, loop ? -1 : 0)
      rescue SDL2::Error => error
        Stylet.logger.debug "ERROR: #{error.inspect}" if Stylet.logger
      end

      def play?
        SDL2::Mixer.play?(channel)
      end

      def halt(fade_out_sec: nil)
        if fade_out_sec
          SDL2::Mixer.fade_out(channel, fade_out_sec * 1000)
        else
          SDL2::Mixer.halt(channel)
        end
      end

      def volume=(v)
        @volume = v
        if @wave
          wave_volume_set(@wave)
        end
      end

      def channel
        if @channel_auto
          if SE.allocated_channels == 0
            raise "SE.preparation_channels でチャンネル数を指定してください"
          end
          -1
        else
          SE.channel_groups.fetch(@channel_group)[:channel]
        end
      end

      def destroy
        raise unless SE.se_hash[@key]
        unless @channel_auto
          SE.channel_groups[@channel_group][:counter] -= 1
        end
        if @wave
          raise if @wave.destroyed?
          @wave.destroy
          @wave = nil
        end
        Stylet.logger.debug "destroy: #{@key.inspect}" if Stylet.logger
        SE.se_hash.delete(@key)
      end

      def wave
        @wave ||= SDL2::Mixer::Wave.load(@filename.to_s).tap do |wave|
          wave_volume_set(wave)
          Stylet.logger.debug "disk_load: #{@key.inspect}" if Stylet.logger
        end
      end
      alias preload! wave

      def spec
        "[channel:#{channel}/#{SE.allocated_channels}] [#{@wave ? :loaded : :new}] [volume:#{@volume}] [#{@channel_group}] [#{@key}] #{@filename.basename}"
      end

      private

      def wave_volume_set(wave)
        wave.set_volume(Audio.volume_cast(@volume * SE.volume_magnification))
      end
    end
  end
end

if $0 == __FILE__
  require_relative "../stylet"
  require "rspec/autorun"

  RSpec.configure do |_config|
  end

  sub_test_case do
    setup do
      Stylet::Audio.setup_once
      Stylet::SE.destroy_all
    end

    it do
      Stylet::Music.volume = 0.2
      Stylet::Music.play("#{__dir__}/assets/bgm.wav")

      expect(Stylet::Music.play?).to eq true
      sleep(1)
      Stylet::Music.halt(fade_out_sec: 3)
      nil while Stylet::Music.play?
    end

    it do
      Stylet::SE.master_volume = 0.2
      Stylet::SE.load("#{__dir__}/../../assets/audios/pc_puyo_puyo_fever/VOICE/CH00VO00.WAV", :key => :a, :channel_group => :x, :volume => 0.1)
      Stylet::SE.load("#{__dir__}/../../assets/audios/pc_puyo_puyo_fever/VOICE/CH00VO01.WAV", :key => :b,                       :volume => 0.1)
      Stylet::SE.load("#{__dir__}/../../assets/audios/pc_puyo_puyo_fever/VOICE/CH00VO02.WAV", :key => :c, :channel_group => :x, :volume => 0.1)

      expect(Stylet::SE[:a].spec).to match(/new/)    # ロードしていない
      Stylet::SE[:a].preload!                        # 明示的にロードする
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

    it "効果音を複数同時にフェイドアウトできる" do
      Stylet::SE.master_volume = 0.2
      Stylet::SE.load("#{__dir__}/../../assets/audios/pc_puyo_puyo_fever/VOICE/CH03VO09.WAV", :key => :a, :preload => true, :volume => 0.1)
      Stylet::SE.load("#{__dir__}/../../assets/audios/pc_puyo_puyo_fever/VOICE/CH04VO20.WAV", :key => :b, :preload => true, :volume => 0.1)
      Stylet::SE[:a].play
      Stylet::SE[:b].play
      Stylet::SE.halt(:fade_out_sec => 1)
      Stylet::SE.wait_if_play?
    end

    it do
      Stylet::SE.preparation_channels = 10
      Stylet::SE.load("#{__dir__}/../../assets/audios/pc_puyo_puyo_fever/VOICE/CH00VO00.WAV", :key => :a, :channel_auto => true, :volume => 0.1)
      expect(Stylet::SE[:a].spec).to match("-1/10")
    end
  end
end
