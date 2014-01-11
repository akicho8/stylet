# -*- coding: utf-8 -*-
#
# 正規乱数と標準偏差の可視化
# https://www.google.co.jp/search?q=%E6%AD%A3%E8%A6%8F%E5%88%86%E5%B8%83&lr=lang_ja&hl=ja&tbs=lr:lang_1ja&tbm=isch&tbo=u&source=univ&sa=X&ei=enmsUsPLNI_qlAWZooC4Bw&ved=0CDoQsAQ&biw=1280&bih=638
#
require_relative "helper"

class App < Stylet::Base
  include Helper::Cursor

  setup do
    @sd = 20                    # 標準偏差初期値(68%の値がある)
  end

  update do
    @sd += button.btA.repeat_0or1 - button.btB.repeat_0or1
    list = 100.times.collect { rnorm(mean: 80, sd: @sd) } # このプログラムだと平均(mean)の値は重要じゃない

    # 配列から標準偏差を求める
    avg = list.inject(&:+).to_f / list.size
    _sd = Math.sqrt(list.collect{|v|(v - avg) ** 2}.reduce(:+).to_f / list.size)

    k = 24                      # 瓶の数(片方)
    h = 4                       # 瓶の幅
    r = (-k..k).collect{|i|
      range = (avg + i * h) ... (avg + i.next * h)
      count = list.count{|v|range.include?(v)}
      bar(i, count)
    }

    # 実際の標準偏差の位置確認
    pos = _sd / h
    bar(pos, -1, "orange")
    bar(-pos, -1, "orange")

    vputs "指定の標準偏差: #{@sd}"
    vputs "実際の標準偏差: #{_sd}"

    # ±標準偏差の中にデータが約68%、2倍な95%、3倍なら0.997含まれるのは本当なのか？
    vputs ["±1*σ割合(0.6826): ", (list.count{|v|(-(_sd*1)..(_sd*1)).include?(v - avg)}.to_f / list.size)].join
    vputs ["±2*σ割合(0.9544): ", (list.count{|v|(-(_sd*2)..(_sd*2)).include?(v - avg)}.to_f / list.size)].join
    vputs ["±3*σ割合(0.9974): ", (list.count{|v|(-(_sd*3)..(_sd*3)).include?(v - avg)}.to_f / list.size)].join
  end

  def bar(pos, length, color = "white")
    p0 = rect.center + Stylet::Vector.new(pos * 4, rect.h / 4)
    p1 = p0 + Stylet::Vector.new(0, -length * 8)
    draw_line(p0, p1, :color => color)
  end

  def rnorm(mean: 0.0, sd: 1.0)
    # こっちは一様乱数
    # return rand((mean - sd*2) .. (mean + sd*2))

    # こっちでもだいたい同じになる(ただしrandの呼び出しが2倍)
    # return mean + sd * Math.sqrt(-2 * Math.log(rand)) * Math.sin(2 * Math::PI * rand)

    if @next_value
      v = @next_value
      @next_value = nil
    else
      a = Math.sqrt(-2.0 * Math.log(rand))
      b = 2 * Math::PI * rand
      z1 = a * Math.cos(b)
      z2 = a * Math.sin(b)
      @next_value = z2
      v = z1
    end
    mean + sd * v
  end

  run
end
