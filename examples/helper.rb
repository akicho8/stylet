require "./setup"

module Helper
  module Cursor
    extend ActiveSupport::Concern

    include Stylet::Input::Base
    include Stylet::Input::ExtensionButton
    include Stylet::Input::StandardKeybord
    include Stylet::Input::JoystickBinding
    include Stylet::Input::MouseButtonAsCounter

    included do
      attr_reader :cursor

      setup do
        @cursor = CursorSet.new
        @cursor.point = @mouse.point.clone
      end

      update do
        if joy = joys.first
          update_by_joy(joy)
        end
        key_counter_update_all

        if mouse.moved?
          @cursor.point = @mouse.point.clone
        end

        if angle = axis_angle
          @cursor.point += Stylet::Vector.angle_at(angle) * @cursor.speed
        end

        if @cursor.display
          draw_circle(@cursor.point, :radius => @cursor.radius, :vertex => @cursor.vertex, :angle => 1.0 / 64 * @count)
        end
      end
    end

    class CursorSet
      attr_accessor :point, :speed, :vertex, :radius, :display

      def initialize
        @speed   = 5
        @vertex  = 3
        @radius  = 8
        @display = true
      end
    end
  end

  module ObjectCollection
    extend ActiveSupport::Concern

    included do
      attr_reader :objects

      setup do
        @objects = []
      end

      update do
        @objects.each(&:update)
        @objects.reject!{|e|e.respond_to?(:screen_out?) && e.screen_out?}
      end
    end
  end

  module CursorWithObjectCollection
    extend ActiveSupport::Concern
    include ObjectCollection
    include Cursor
  end
end

require_relative "movable_point"

if $0 == __FILE__
  Class.new(Stylet::Base) do
    include Helper::CursorWithObjectCollection
    run
  end
end
