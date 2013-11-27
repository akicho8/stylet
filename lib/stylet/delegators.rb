# -*- coding: utf-8 -*-
require 'forwardable'
require "active_support/concern"

module Stylet
  module Delegators
    extend ActiveSupport::Concern
    included do
      extend Forwardable
      def_delegators "Stylet::Base.active_frame", *[
        :vputs,
        :rect,
        :count,
        :joys,
        :draw_line,
        :draw_circle,
        :draw_triangle,
        :draw_square,
        :draw_rectangle,
        :draw_vector,
        :draw_arrow,
        :draw_polygon,
      ]
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
