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

    @pos = Stylet::Vector.new(rand(frame.rect.w), rand(frame.rect.h))             # 物体初期位置

    @mode = "mode1"
    @mode_count = 0
  end

  def update
    if frame.axis.up.press? || frame.axis.down.press? || frame.axis.right.press? || frame.axis.left.press? || frame.button.btA.trigger?
      @index += frame.axis.down.repeat + frame.axis.right.repeat
      @index -= frame.axis.up.repeat + frame.axis.left.repeat
      @mode = "mode1"
      @mode_count = 0
    end
    if frame.button.btB.trigger?
      @mode = "mode3"
      @mode_count = 0
    end

    # 自分の位置に戻る
    if @mode == "mode1"
      @target = frame.rect.center + Stylet::Vector.angle_at((1.0 / frame.objects.size * @index)) * @everyone_radius
      @pos += (@target - @pos).scale(0.2)

      if (@target - @pos).magnitude < 1.0
        @pos = @target
        @mode = "mode2"
        @mode_count = 0
      end
    end

    # しばらく時間がたったら
    if @mode == "mode2"
      if @mode_count == 0
      end
      if @mode_count >= 30 * 1 || frame.button.btB.trigger?
        @mode = "mode3"
        @mode_count = 0
      end
    end

    # 勝手に動きだす
    if @mode == "mode3"
      if @mode_count == 0
        @speed = Stylet::Vector.new(rand(-1.5..1.5), rand(-1.0..1.0))
      end
      @pos += @speed
    end

    @mode_count += 1

    frame.draw_circle(@pos, :radius => @radius, :vertex => @vertex, :angle => 1.0 / 256 * frame.count)
    frame.vputs @name, :vector => @pos
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
