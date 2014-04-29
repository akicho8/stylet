require "forwardable"
require "active_support/concern"

module Stylet
  module Delegators
    extend ActiveSupport::Concern
    included do
      extend Forwardable

      unless self <= Stylet::Base
        instance_delegate [
          :vputs,
          :dputs,
          :rect,
          :count,
          :joys,
          :draw_dot,
          :draw_line,
          :draw_circle,
          :draw_triangle,
          :draw_square,
          :draw_angle_rect,
          :draw_rect,
          :_draw_rect,
          :draw_vector,
          :draw_arrow,
          :draw_polygon,
          :screen,

          :check_fps,

          :vec2,
          :rect2,
        ] => "Stylet::Base.active_frame"
      end

      instance_delegate [:rsin, :rcos] => "Stylet::Fee"
    end
  end
end

if $0 == __FILE__
  require_relative "../stylet"
  class App < Stylet::Base
    update { Class.new { include Stylet::Delegators }.new.vputs "ok" }
    run
  end
end
