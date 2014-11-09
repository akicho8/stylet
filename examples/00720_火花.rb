# -*- coding: utf-8 -*-
#
require_relative "helper"

class Bullet
  include Stylet::Delegators

  def initialize(point:, angle:, speed:, accel:)
    @point = point
    @angle = angle
    @speed = speed
    @accel = accel
    @radius = 0
    @p0 = @point
  end

  def update
    @speed += @accel
    @radius += @speed
    @p1 = @point + Stylet::Vector.angle_at(@angle) * @radius
    draw_line(@p0, @p1)
    @p0 = @p1
  end

  def screen_out?
    @speed <= 0
  end
end

class App < Stylet::Base
  include Helper::CursorWithObjectCollection

  update do
    if @button.btA.trigger?
      n = 16
      n.times.each do |i|
        @objects << Bullet.new(:point => cursor.point.dup, :angle => 1.0 / n * i, :speed => rand(4.0..10.0), :accel => rand(-0.5/2..-0.3/2))
      end
    end
  end

  run
end
