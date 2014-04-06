# -*- coding: utf-8 -*-
module Stylet
  module DrawSupport
    # ベクトル確認用
    #   開始地点のデフォルトは画面中央になる
    #   開始地点がわかっている場合は origin を指定すること
    #
    #   draw_vector(vec2[100, 0], :origin => vec2[50, 50], :label => "ok")
    #
    #     p0 -----> p1 ok
    #
    #   p0: origin オプションで指定(指定しないと画面中央)
    #   p1: 第一引数
    #
    def draw_vector(vec, options = {})
      options = {
        :origin => rect.center, # 原点を画面の真中にしておく
      }.merge(options)

      p1 = options[:origin] + vec
      draw_arrow(options[:origin], p1, options)

      if options[:label]
        vputs options[:label], :vector => p1
      end
    end

    # p0 から p1 へ矢印の描画
    def draw_arrow(p0, p1, options = {})
      d = p0 - p1
      if d.x.nan? || d.y.nan?
        return
      end

      options = {
        :angle      => Fee.r45,                  # 傘の開き
        :arrow_size => p0.distance_to(p1) * 0.1, # 傘の大きさは線分の長さに比例
      }.merge(options)

      draw_line(p0, p1, options) # 線分の表示

      # 傘の表示
      a = p1.angle_to(p0)
      draw_line(p1, p1 + Vector.angle_at(a + options[:angle]).scale(options[:arrow_size]), options)
      draw_line(p1, p1 + Vector.angle_at(a - options[:angle]).scale(options[:arrow_size]), options)
    end
  end

  if $0 == __FILE__
    require_relative "../../stylet"
    Base.run do
      draw_arrow(rect.center, rect.center + [50, 50])
      draw_vector(vec2[100, -100], :origin => rect.center, :label => "ok")
      draw_vector(vec2[100, 0], :origin => vec2[50, 50], :label => "ok")
    end
  end
end
