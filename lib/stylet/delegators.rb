require "active_support/concern"
require "active_support/core_ext/module/delegation"

module Stylet
  module Delegators
    extend ActiveSupport::Concern

    included do
      unless self <= Base
        delegate(*[
            :vputs,
            :vputs_vector,
            :dputs,
            :srect,
            :frame_counter,
            :joys,
            :draw_dot,
            :draw_line,
            :draw_circle,
            :draw_triangle,
            :draw_square,
            :draw_angle_rect,
            :draw_rect,
            :draw_rect4,
            :draw_vector,
            :draw_arrow,
            :draw_polygon,
            :screen,
            :system_font,

            :fps_stat,
            :cpu_stat,

            :vec2,
            :vec3,
            :rect2,
            :rect4,
          ], :to => "Stylet::Base.active_frame")
      end

      delegate(*[:rsin, :rcos], :to => "Stylet::Fee")
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
