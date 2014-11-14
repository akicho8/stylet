# -*- coding: utf-8 -*-
#
# 再帰曲線 ヒルベルト曲線(アルゴリズム)
# http://www.softist.com/programming/hilbert/hilbert.htm
#
# ヒルベルト曲線 - Wikipedia
# http://ja.wikipedia.org/wiki/%E3%83%92%E3%83%AB%E3%83%99%E3%83%AB%E3%83%88%E6%9B%B2%E7%B7%9A#
# Hilbert curve は、フラクタル図形の一つで
# 空間を覆い尽くす空間充填曲線の一つ。ドイツの数学者ダフィット・ヒルベルトが1891年に考案した
#
require_relative "helper"

class App < Stylet::Base
  include Helper::CursorWithObjectCollection
  include Helper::MovablePoint

  setup do
    self.title = "ヒルベルト曲線"
    @num = 4
    @delta = 24
  end

  update do
    @num += button.btA.repeat - button.btB.repeat
    @delta += (button.btC.repeat - button.btD.repeat)
    @current = vec2[srect.max_x - @delta, srect.min_y + @delta]
    @before_point = @current.clone
    ldr(@num)

    vputs "num: #{@num}"
    vputs "delta: #{@delta}"
  end

  def line_to(x, y)
    dir = vec2[x * @delta, y * @delta]
    @current += dir
    draw_line(@before_point, @current)
    @before_point = @current.clone
  end

  def ldr(n)
    if n > 0
      dlu(n-1); line_to(-1, 0) # ←
      ldr(n-1); line_to(0, 1)  # ↓
      ldr(n-1); line_to(1, 0)  # →
      urd(n-1)
    end
  end

  def urd(n)
    if n > 0
      rul(n-1); line_to(0, -1) # ↑
      urd(n-1); line_to(1, 0)  # →
      urd(n-1); line_to(0, 1)  # ↓
      ldr(n-1)
    end
  end

  def rul(n)
    if n > 0
      urd(n-1); line_to(1, 0)  # →
      rul(n-1); line_to(0, -1) # ↑
      rul(n-1); line_to(-1, 0) # ←
      dlu(n-1)
    end
  end

  def dlu(n)
    if n > 0
      ldr(n-1); line_to(0, 1)  # ↓
      dlu(n-1); line_to(-1, 0) # ←
      dlu(n-1); line_to(0, -1) # ↑
      rul(n-1)
    end
  end

  run
end
