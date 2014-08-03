# -*- coding: utf-8 -*-
module Stylet
  #
  # フレーム数を指定してウェイトを取る
  #
  class FpsAdjust
    def self.slow_loop(fps)
      if fps
        object = new(fps)
        loop do
          yield
          object.wait
        end
      else
        loop { yield }
      end
    end

    #
    # blockにはミリ秒単位で現在の時間を返すブロックを指定する
    #
    def initialize(fps = Stylet.config.fps, &block)
      @fps = fps
      @block = block || -> { (Time.now.to_f * 1000).to_i }
      @old_time = @block.call
    end

    #
    # Vsync待ち相当のウェイト
    #
    def wait
      return unless @fps
      loop do
        v = @block.call
        t = v - @old_time
        if t > 1000 / @fps
          @old_time = v
          break
        end
        if block_given?
          yield
        end
      end
    end
  end
end

if $0 == __FILE__
  count = 3
  puts "#{count}秒間カウントするテスト"
  puts "Timeクラス使用版"
  x = Stylet::FpsAdjust.new(1)
  count.times{|i| puts i; x.wait}

  puts "SDL関数使用版"
  require "rubygems"
  require "sdl"
  x = Stylet::FpsAdjust.new(1) {SDL.get_ticks}
  count.times{|i| puts i; x.wait}

  puts "time_out試用版"
  i = 0
  Stylet::FpsAdjust.slow_loop(1){
    puts i
    i += 1
    break if i == count
  }
end
