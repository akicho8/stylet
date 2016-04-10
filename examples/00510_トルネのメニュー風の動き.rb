#
# PSPやPS3やトルネのインターフェイスでありがちなメニューの動き
#
require_relative "helper"

class Ball
  include Stylet::Delegators

  delegate :axis, :button, :objects, :to => "Stylet.context"

  def initialize(index)
    @name = index.to_s
    @index = index

    @vertex = 16
    @radius = 48
    @everyone_radius = 80 * 2
    @arrow = rand(2).zero? ? 1 : -1 # どっち向きに回転するか

    @pos = vec2[rand(srect.w), rand(srect.h)]             # 物体初期位置

    @state = State.new(:state1)
  end

  def update
    if axis.up.press? || axis.down.press? || axis.right.press? || axis.left.press? || button.btA.trigger?
      @index += axis.down.repeat + axis.right.repeat
      @index -= axis.up.repeat + axis.left.repeat
      @state.jump_to :state1
    end
    if button.btB.trigger?
      @state.jump_to :state3
    end

    @state.loop_in do
      case @state.key
      when :state1
        # 自分の位置に戻る
        @target = srect.center + vec2.angle_at((1.0 / objects.size * @index)) * @everyone_radius
        @pos += (@target - @pos).scale(0.2)

        if (@target - @pos).magnitude < 1.0
          @pos = @target
          @state.jump_to :state2
        end
      when :state2
        # しばらく時間がたったら
        if @state.start?
        end
        if @state.counter >= 30 * 1 || button.btB.trigger?
          @state.jump_to :state3
        end
      when :state3
        # 勝手に動きだす
        if @state.start?
          @speed = vec2[rand(-1.5..1.5), rand(-1.0..1.0)]
        end
        @pos += @speed
      end
    end

    draw_circle(@pos, :radius => @radius, :vertex => @vertex, :angle => 1.0 / 256 * frame_counter)
    vputs @name, :vector => @pos
  end
end

class App < Stylet::Base
  include Helper::CursorWithObjectCollection

  setup do
    self.title = "トルネ風メニュー(PSのシステムにありがちな動き)"
    cursor.display = false
    @objects = Array.new(8) {|i| Ball.new(i) }
  end

  run
end
