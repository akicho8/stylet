# -*- coding: utf-8 -*-
#
# PSPやPS3やトルネのインターフェイスでありがちなメニューの動き
#
require_relative "helper"

class Ball
  def initialize(index)
    @name = index.to_s
    @index = index

    @vertex = 16
    @radius = 48
    @everyone_radius = 80 * 2
    @arrow = rand(2).zero? ? 1 : -1 # どっち向きに回転するか

    @pos = Stylet::Vector.new(rand(__frame__.rect.w), rand(__frame__.rect.h))             # 物体初期位置

    @state = "state1"
    @state_counter = 0
  end

  def update
    if __frame__.axis.up.press? || __frame__.axis.down.press? || __frame__.axis.right.press? || __frame__.axis.left.press? || __frame__.button.btA.trigger?
      @index += __frame__.axis.down.repeat + __frame__.axis.right.repeat
      @index -= __frame__.axis.up.repeat + __frame__.axis.left.repeat
      @state = "state1"
      @state_counter = 0
    end
    if __frame__.button.btB.trigger?
      @state = "state3"
      @state_counter = 0
    end

    # 自分の位置に戻る
    if @state == "state1"
      @target = __frame__.rect.center + Stylet::Vector.angle_at((1.0 / __frame__.objects.size * @index)) * @everyone_radius
      @pos += (@target - @pos).scale(0.2)

      if (@target - @pos).magnitude < 1.0
        @pos = @target
        @state = "state2"
        @state_counter = 0
      end
    end

    # しばらく時間がたったら
    if @state == "state2"
      if @state_counter == 0
      end
      if @state_counter >= 30 * 1 || __frame__.button.btB.trigger?
        @state = "state3"
        @state_counter = 0
      end
    end

    # 勝手に動きだす
    if @state == "state3"
      if @state_counter == 0
        @speed = Stylet::Vector.new(rand(-1.5..1.5), rand(-1.0..1.0))
      end
      @pos += @speed
    end

    @state_counter += 1

    __frame__.draw_circle(@pos, :radius => @radius, :vertex => @vertex, :angle => 1.0 / 256 * __frame__.count)
    __frame__.vputs @name, :vector => @pos
  end
end

class App < Stylet::Base
  include Helper::CursorWithObjectCollection

  setup do
    self.title = "torne風メニュー(PSのシステムにありがちな動き)"
    cursor.display = false
    @objects = Array.new(8){|i|Ball.new(i)}
  end

  run
end
