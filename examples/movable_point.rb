# -*- coding: utf-8 -*-

require_relative "helper"

module Helper
  module MovablePoint
    extend ActiveSupport::Concern

    included do
      attr_accessor :dragging_current

      # before_main_loop do
      #   # @dpoints << rect.center + Stylet::Vector.new(-rect.w / 4, rect.h / 4)
      #   # @dpoints << rect.center + Stylet::Vector.new(0, -rect.h / 4)
      #   # @dpoints << rect.center + Stylet::Vector.new(rect.w / 4, rect.h / 4)
      # end

      # after_update do
      # end
    end

    def movable_point_update(points, options = {})
      options = {
        :origin => Stylet::Vector.zero,
      }.merge(options)

      mpoint = mouse.point - options[:origin]

      unless @dragging_current
        if button.btA.trigger?
          if v = points.find{|e|Stylet::CollisionSupport.squire_collision?(e, mpoint, :radius => 8)}
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
        @dragging_current.copy_from(mpoint)
      end

      if @dragging_current
        draw_circle(options[:origin] + @dragging_current, :radius => 8, :vertex => 32)
      end

      points.each {|e| draw_circle(options[:origin] + e, :radius => 2) }
    end
  end
end

if $0 == __FILE__
  class App < Stylet::Base
    include Helper::CursorWithObjectCollection
    include Helper::MovablePoint

    before_main_loop do
      @points = []
      @points << rect.center + Stylet::Vector.new(-rect.w / 4, rect.h / 4)
      @points << rect.center + Stylet::Vector.new(0, -rect.h / 4)
      @points << rect.center + Stylet::Vector.new(rect.w / 4, rect.h / 4)
    end

    after_update do
      movable_point_update(@points)
      @points.each_with_index{|e, i| vputs("#{i}", :vector => e) }
    end

    run
  end
end
