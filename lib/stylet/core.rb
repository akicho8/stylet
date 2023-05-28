require "active_support/isolated_execution_state"

module Stylet
  module Core
    extend ActiveSupport::Concern

    included do
      include Singleton

      cattr_accessor :_active_instance
    end

    class_methods do
      # run{|win| win.vputs 'Hello' }
      # run{ vputs 'Hello' }
      def run(*args, &block)
        active_frame.run(*args, &block)
      end

      # run_initializers 実行済みの active_frame
      def active_frame
        @active_frame ||= active_instance.tap(&:run_initializers)
      end

      # すでにどこかで実行済みの場合は instance ではなく
      # 先に実行された _active_instance の方を返す
      # これで何度も初期化したり _active_instance が上書きされることがなくなる
      def active_instance
        @active_instance ||= _active_instance || instance
      end
    end

    def initialize
      raise "Singletonなのに再び初期化されている。ということは Stylet::Base を継承したクラスを複数作っている可能性があります。" if _active_instance
      self._active_instance = self
      @init_code = 0
      @initialized = []
    end

    def logger
      Stylet.logger
    end

    def run_initializers
      init_on(:core) do
        # SDL2.init(SDL2::INIT_VIDEO)
        SDL2.init(SDL2::INIT_EVERYTHING)
      end
    end

    def setup
    end

    def event_loop
      while @sdl_event = SDL2::Event.poll
        event_receive
      end
    end

    def event_receive
    end

    def polling
    end

    def before_update
    end

    def update
    end

    def screen_flip
    end

    def after_run
    end

    def run(title: nil, &block)
      self.title = title
      run_initializers          # SDL2.init(@init_code)
      setup                     # for user
      main_loop(&block)
    ensure
      after_run
    end

    def main_loop(&block)
      catch :exit do
        loop do
          next_frame(&block)
        end
      end
    end

    def next_frame(&block)
      raise "SDL2 is not initialized" if @initialized.empty?
      event_loop
      polling
      if pause? || !screen_active
        return
      end
      screen_flip               # @screen.flip
      before_draw               # @console_current_line = 0
      background_clear
      before_update             # vputs(system_infos)

      # ここからユーザーの処理
      # ということは next_frame の中のブロックから呼ぶ必要はない？

      update                    # for user

      if block_given?
        if block.arity == 1
          block.call(self)
        else
          instance_eval(&block)
        end
      end
    end

    private

    def init_on(key)
      unless @initialized.include?(key)
        yield
        @initialized << key
        logger.debug "init: #{key}"
      end
    end
  end
end
