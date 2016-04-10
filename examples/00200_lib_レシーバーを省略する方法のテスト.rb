#
# .Stylet.context を書かない方法の実験
# Stylet::Delegators の中身がこんな感じ
#
require_relative "helper"
require 'forwardable'

class Ball
  delegate :draw_triangle, :srect, :frame_counter, :to => "Stylet::Base.active_frame"

  def update
    draw_triangle(srect.center, :radius => 128, :angle => 1.0 / 256 * frame_counter)
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
