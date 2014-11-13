# -*- coding: utf-8 -*-

require_relative "helper"

module Helper
  module MovablePoint
    extend ActiveSupport::Concern

    attr_accessor :dragging_current

    def update_movable_points(points, options = {})
      options = {
        :origin => vec2.zero,
        :radius => 2,           # ドットの大きさ
        :collision_radius => 8, # 当り判定の広さ
      }.merge(options)

      mpoint = mouse.point - options[:origin]

      unless @dragging_current
        if button.btA.trigger?
          if v = points.find{|e|Stylet::CollisionSupport.squire_collision?(e, mpoint, :radius => options[:collision_radius])}
            @dragging_current = v
          end
        end
      end

      if @dragging_current
        if button.btA.free?
          @dragging_current = nil
        end
      end

      if @dragging_current
        @dragging_current.replace(mpoint)
      end

      if @dragging_current
        draw_circle(options[:origin] + @dragging_current, :radius => options[:collision_radius], :vertex => 32)
      end

      points.each {|e| draw_circle(options[:origin] + e, :radius => options[:radius]) }
    end
  end
end

if $0 == __FILE__
  class App < Stylet::Base
    include Helper::CursorWithObjectCollection
    include Helper::MovablePoint

    setup do
      @points = []
      @points << srect.center + vec2.new(-srect.w / 4, srect.h / 4)
      @points << srect.center + vec2.new(0, -srect.h / 4)
      @points << srect.center + vec2.new(srect.w / 4, srect.h / 4)
    end

    update do
      update_movable_points(@points)
      @points.each_with_index{|e, i| vputs("#{i}", :vector => e) }
    end

    run
  end
end
