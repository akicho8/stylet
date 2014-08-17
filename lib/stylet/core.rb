# -*- coding: utf-8 -*-
module Stylet
  module Core
    extend ActiveSupport::Concern

    included do
      include Singleton

      cattr_accessor :_active_instance
    end

    module ClassMethods
      # run{|win| win.vputs 'Hello' }
      # run{ vputs 'Hello' }
      def run(*args, &block)
        active_frame.run(*args, &block)
      end

      # run_initializers 実行済みの active_frame
      def active_frame
        @active_frame ||= active_instance.tap {|e| e.run_initializers }
      end

      # すでにどこかで実行済みの場合は instance ではなく
      # 先に実行された _active_instance の方を返す
      # これで何度も初期化したり _active_instance が上書きされることがなくなる
      def active_instance
        @active_instance ||= _active_instance || instance
      end
    end

    def initialize
      raise "Singletonなのに再び初期化されている。Stylet::Base を継承したクラスを複数作っている？" if _active_instance
      self._active_instance = self
      @init_code = 0
      @initialized = []
    end

    def logger
      Stylet.logger
    end

    def run_initializers
      init_on(:core) do
        SDL.init(SDL::INIT_VIDEO)
      end
    end

    def setup
    end

    def polling
    end

    def before_update
    end

    def update
    end

    def after_draw
    end

    def after_run
    end

    def run(*args, &block)
      options = {
      }.merge(args.extract_options!)
      if options[:title]
        @title = options[:title]
      end
      run_initializers                # SDL.init(@init_code)
      setup                         # for user
      main_loop(&block)
      # after_run                 # @screen.destroy
    end

    def main_loop(&block)
      catch :exit do
        loop do
          next_frame(&block)
        end
      end
    end

    def next_frame(&block)
      raise "SDL is not initialized" if @initialized.empty?
      polling
      if pause? || !screen_active
        return
      end
      after_draw            # @screen.flip
      before_draw           # @console_current_line = 0
      background_clear
      before_update         # vputs(system_infos)

      # ここからユーザーの処理
      # ということは next_frame の中のブロックから呼ぶ必要はない？

      update                # for user

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
