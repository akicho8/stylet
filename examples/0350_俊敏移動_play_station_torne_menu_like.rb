# -*- coding: utf-8 -*-
#
# PSPやPS3やトルネのインターフェイスでありがちなメニューの動き
#
require_relative "helper"

class Ball
  def initialize(win, index)
    @win = win
    @name = index.to_s
    @index = index

    @vertex = 16
    @radius = 48
    @everyone_radius = 80 * 2
    @arrow = rand(2).zero? ? 1 : -1 # どっち向きに回転するか

    @pos = Stylet::Vector.new(rand(@win.rect.w), rand(@win.rect.h))             # 物体初期位置

    @mode = "mode1"
    @mode_count = 0
  end

  def update
    # Dボタンおしっぱなし + マウスで角度変更
    if @win.axis.up.press? || @win.axis.down.press? || @win.axis.right.press? || @win.axis.left.press? || @win.button.btA.trigger?
      @index += @win.axis.down.repeat + @win.axis.right.repeat
      @index -= @win.axis.up.repeat + @win.axis.left.repeat
      @mode = "mode1"
      @mode_count = 0
    end
    if @win.button.btB.trigger?
      @mode = "mode3"
      @mode_count = 0
    end

    # 自分の位置に戻る
    if @mode == "mode1"
      @target = @win.rect.center + Stylet::Vector.angle_at((1.0 / @win.objects.size * @index)) * @everyone_radius
      @pos += (@target - @pos).scale(0.3)

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
      if @mode_count >= 30 * 1 || @win.button.btB.trigger?
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

    @win.draw_circle(@pos, :radius => @radius, :vertex => @vertex, :angle => 1.0 / 256 * @win.count)
    @win.vputs @name, :vector => @pos
  end
end

class App < Stylet::Base
  include Helper::CursorWithObjectCollection

  setup do
    self.title = "torne風メニュー(PSのシステムにありがちな動き)"
    @cursor.display = false
    @objects = Array.new(8){|i|Ball.new(self, i)}
  end

  run
end
