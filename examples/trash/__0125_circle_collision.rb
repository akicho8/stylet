# -*- coding: utf-8 -*-
#
# 円同士の当り判定
#
require_relative "helper"

class Ball
  def initialize(win, cpos)
    @win = win
    @cpos = cpos
    @pos = @cpos.clone
    @radius = 64
    @vr = 0
    @r = 0
    @dir = 0
  end

  def update
    dx = (@pos.x - @win.mouse.point.x).abs
    dy = (@pos.y - @win.mouse.point.y).abs
    distance = Math.sqrt((dx ** 2) + (dy ** 2))
    @win.vputs(distance)
    radius_plus = @radius + @win.radius
    gap = radius_plus - distance
    if gap > 0
      @dir = Stylet::Fee.angle(@win.mouse.point.x, @win.mouse.point.y, @pos.x, @pos.y)
      @cpos = @pos.clone
      @r = 0
      @vr = gap
    end
    @vr -= 0.01
    if @vr < 0
      @vr = 0
    end
    @r += @vr
    @pos.x = @cpos.x + Stylet::Fee.rcos(@dir) * @r
    @pos.y = @cpos.y + Stylet::Fee.rsin(@dir) * @r
    @win.draw_polygon(@pos, :radius => @radius, :vertex => 32)
  end

  def screen_out?
    false
  end
end

module Helper
  module HandCursor
    include Stylet::Input::Base
    include Stylet::Input::StandardKeybordBind
    include Stylet::Input::JoystickBindMethod
    include Stylet::Input::MouseButtonBind

    setup do
      super if defined? super
      @cursor.point = @mouse.point.clone
      @cursor.speed = 5
      @objects = []
    end

    def update
      super if defined? super

      if joy = joys.first
        bit_update_by_joy(joy)
      end
      key_bit_update_all
      key_counter_update_all

      if mouse.moved?
        @cursor.point = @mouse.point.clone
      end

      if dir = axis_angle
        @cursor.point.x += Stylet::Fee.rcos(dir) * @cursor.speed
        @cursor.point.y += Stylet::Fee.rsin(dir) * @cursor.speed
      end

      vputs @mouse.point.to_a
      vputs mouse.moved?

      vputs @objects.size
      @objects.each{|e|e.update}
      @objects.reject!{|e|e.screen_out?}
      draw_polygon(@cursor.point, :radius => 16, :vertex => 3, :angle => 1.0 / 64 * @count)
    end
  end
end

class App < Stylet::Base
  include Helper::CursorWithObjectCollection

  attr_reader :radius

  setup do
    @objects << Ball.new(self, rect.center)
    @radius = 64
  end

  update do
    draw_polygon(@mouse.point, :radius => @radius, :vertex => 32)
  end

  run
end
