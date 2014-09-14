# -*- coding: utf-8 -*-
#
# .Stylet.context を書かない方法の実験
# Stylet::Delegators の中身がこんな感じ
#
require_relative "helper"
require 'forwardable'

class Ball
  extend Forwardable
  def_delegators "Stylet::Base.active_frame", :draw_triangle, :rect, :frame_counter

  def update
    draw_triangle(rect.center, :radius => 128, :angle => 1.0 / 256 * frame_counter)
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
