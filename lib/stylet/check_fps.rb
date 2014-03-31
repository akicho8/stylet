# -*- coding: utf-8 -*-
module Stylet
  #
  # FPSの計測
  #
  # Example:
  #
  #   obj = CheckFPS.new
  #   loop do
  #     obj.update
  #     obj.fps # => 60
  #     screen.flip
  #   end
  #
  class CheckFPS
    MSECOND = 1000.0

    attr_reader :fps

    # blockにはミリ秒単位で現在の時間を返すブロックを指定する
    def initialize(&block)
      @block = block || -> { Time.now.to_f * MSECOND }
      @old_time = @block.call
      @fps = 0
      @counter = 0
    end

    # 毎フレーム呼ぶことでフレーム数を調べられる
    def update
      @counter += 1
      v = @block.call
      t = v - @old_time
      if t > MSECOND
        @old_time = v
        @fps = @counter
        @counter = 0
      end
    end
  end
end

if $0 == __FILE__
  obj = Stylet::CheckFPS.new
  sleep(0.5)
  obj.update
  sleep(0.5)
  obj.update
  p obj.fps
end
