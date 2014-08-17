# -*- coding: utf-8 -*-
require "benchmark"
require "active_support/core_ext/benchmark"

module Stylet
  # CPU率の測定
  #
  #   * 余力とCPUは反比例の関係
  #   * なので余力を測定することでCPU率を得る
  #   * 1フレーム毎に計算すると誤差が多いため1秒毎に計算
  #
  # Example:
  #
  #   stat = CpuStat.new
  #   loop do
  #     stat.benchmark { screen.flip }       # 余力測定
  #     stat.cpu_ratio # => 80.0
  #   end
  #
  # CPU率の求め方
  #
  #    flip   余力    CPU
  #   -------------------
  #   16 ms   100 %    0%
  #   15 ms    90 %   10%
  #    1 ms    10 %   90%
  #    0 ms     0 %  100%
  #
  #   free =       ms  / 16 * 100
  #   cpu  = (16 - ms) / 16 * 100
  #
  # 1秒単位で測定すれば / 16 は不要になる
  class CpuStat
    def initialize
      @free_ms = 1000.0

      @old_time = SDL.get_ticks
      @total_ms = 0
    end

    def benchmark
      @total_ms += Benchmark.ms { yield }
      now = SDL.get_ticks
      if now >= @old_time + 1000.0
        @old_time = now
        @free_ms = @total_ms
        @total_ms = 0
      end
    end

    def cpu_ms
      1000.0 - @free_ms
    end

    def cpu_ratio
      cpu_ms * 100.0 / 1000.0
    end
  end
end
