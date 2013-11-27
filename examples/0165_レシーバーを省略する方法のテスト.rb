# -*- coding: utf-8 -*-
#
# .frame を書かない方法
#
require_relative "helper"
require 'forwardable'

class Ball
  extend Forwardable
  def_delegators "Stylet::Base.active_frame", :draw_triangle, :rect, :count

  def update
    draw_triangle(rect.center, :radius => 128, :angle => 1.0 / 256 * count)
  end
end

class App < Stylet::Base
  include Helper::CursorWithObjectCollection

  setup do
    @ball = Ball.new
  end

  update do
    @ball.update
  end

  run
end
