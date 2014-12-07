module Helper
  module Cursor
    extend ActiveSupport::Concern

    include Stylet::Input::Base
    include Stylet::Input::ExtensionButton
    include Stylet::Input::StandardKeybordBind
    include Stylet::Input::JoystickBindMethod
    include Stylet::Input::MouseButtonBind

    included do
      attr_reader :cursor

      setup do
        @cursor = CursorSet.new
        @cursor.point = @mouse.point.clone
      end

      update do
        joys.each {|joy| bit_update_by_joy(joy) }
        key_bit_update_all
        key_counter_update_all

        if mouse.moved?
          @cursor.point.replace(@mouse.point.clone)
        end

        if angle = axis_angle
          @cursor.point.replace(@cursor.point + vec2.angle_at(angle) * @cursor.speed)
        end

        if @cursor.display
          draw_circle(@cursor.point, :radius => @cursor.radius, :vertex => @cursor.vertex, :angle => 1.0 / 64 * frame_counter)
        end
      end
    end

    class CursorSet
      attr_accessor :point, :speed, :vertex, :radius, :display

      def initialize
        @point   = Stylet::Vector.zero
        @speed   = 5
        @vertex  = 3
        @radius  = 8
        @display = true
      end
    end
  end
end
