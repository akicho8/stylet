# -*- coding: utf-8 -*-
#
# 放物線デモ(火山)
#
# ・Zでスピード反転
# ・Xでスピード二倍
# ・Cでマウスの位置にセット
# ・Vで速度ベクトルの向きをマウスの向きへ
#
require_relative "helper"

class Ball
  def initialize
    @vertex = 3 + rand(3)           # 物体は何角形か
    @radius = 2 + rand(24)          # 物体の大きさ
    @arrow = rand(2).zero? ? 1 : -1 # どっち向きに回転するか
    @reflect = 0

    @pos = Stylet::Vector.new(frame.rect.center.x, frame.rect.max_y + @radius * 2)             # 物体初期位置
    @speed = Stylet::Vector.new(rand(-2.0..2.0), rand(-15.0..-12)) # 速度ベクトル
    @gravity = Stylet::Vector.new(0, 0.220)                                                        # 重力
  end

  def update
    # 操作
    begin
      # Aボタンでスピード反転
      if frame.button.btA.trigger?
        @speed = @speed.scale(-1)
      end

      # Bボタンでスピード2倍
      if frame.button.btB.trigger?
        @speed = @speed.scale(2)
      end

      # Cボタンおしっぱなし + マウスで位置移動
      if frame.button.btC.press?
        @pos = frame.cursor.point.clone
      end

      # Dボタンおしっぱなし + マウスで角度変更
      if frame.button.btD.press?
        if frame.cursor.point != @pos
          # @speed = (frame.cursor.point - @pos).normalize * @speed.magnitude
          @speed = (frame.cursor.point - @pos).normalize * @speed.magnitude
        end
      end
    end

    @speed += @gravity # 加速
    @pos += @speed     # 進む

    # 画面下で弾ける
    if @reflect == 0
      max = (frame.rect.max_y - @radius)
      if @pos.y > max && @speed.y >= 1
        @speed.y = -@speed.y
        @speed = @speed.scale(0.5)
        if @speed.magnitude < 1.0
          @reflect += 1
        end
      end
    end

    # 完全に落ちてしまったら死ぬ
    max = frame.rect.max_y + @radius * 2
    if @pos.y > max && @speed.y >= 1
      frame.objects.delete(self)
    end

    frame.draw_circle(@pos, :radius => @radius, :vertex => @vertex, :angle => 1.0 / 256 * (@speed.magnitude + frame.count) * @arrow)
  end
end

class App < Stylet::Base
  include Helper::CursorWithObjectCollection

  setup do
    cursor.display = false
    self.title = "加速・放物線・バウンド"
  end

  update do
    if count.modulo(4).zero?
      @objects << Ball.new
    end
  end

  run
end
