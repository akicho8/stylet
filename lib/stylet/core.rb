# -*- coding: utf-8 -*-
module Stylet
  module Core
    extend ActiveSupport::Concern

    included do
      include Singleton
      cattr_accessor :_active_frame
    end

    module ClassMethods
      # run{|win| win.vputs 'Hello' }
      # run{ vputs 'Hello' }
      def run(*args, &block)
        active_frame.run(*args, &block)
      end

      def active_frame
        _active_frame || instance
      end
    end

    def initialize
      @init_code = 0
      @initialized = false
      @@_active_frame = self
    end

    def logger
      Stylet.logger
    end

    def sdl_initialize
      # return if @initialized # 他の sdl_initialize は何度も呼ばれてるのであえて外してみる
      SDL.init(@init_code)
      logger.debug "SDL.init #{'%08x' % @init_code}" if logger
      @initialized = true
      p ["#{__FILE__}:#{__LINE__}", __method__]
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
      sdl_initialize                # SDL.init(@init_code)
      setup                         # for user
      main_loop(&block)
      after_run                 # @screen.destroy
    end

    def main_loop(&block)
      catch(:exit) do
        loop do
          next_frame(&block)
        end
      end
    end

    def next_frame(&block)
      raise "SDL is not initialized" unless @initialized
      polling
      if pause?
        return
      end
      after_draw            # @screen.flip
      before_draw           # @_console_lines = 0
      background_clear
      before_update         # vputs(system_line)

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
  end
end
