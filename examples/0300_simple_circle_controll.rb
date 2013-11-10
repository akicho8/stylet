# -*- coding: utf-8 -*-
#
# 円の移動の定石
#
require_relative "helper"

class Scene
  def initialize(win)
    @win = win

    @pA = @win.rect.center.clone
    @sA = Stylet::Vector.angle_at(Stylet::Fee.clock(8))

    @radius = 50
    @vertex = 32
  end

  def update
    # 操作
    begin
      # AとBで速度ベクトルの反映
      @pA += @sA.scale(@win.button.btA.repeat_0or1) + @sA.scale(-@win.button.btB.repeat_0or1)
      # Cボタンおしっぱなし + マウスで自機位置移動
      if @win.button.btC.press?
        @pA = @win.cursor.point.clone
      end
      # Dボタンおしっぱなし + マウスで自機角度変更
      if @win.button.btD.press?
        if @win.cursor.point != @pA
          @sA = (@win.cursor.point - @pA).normalize * @sA.magnitude
        end
      end
    end

    @win.draw_circle(@pA, :vertex => @vertex, :radius => @radius)
    @win.draw_vector(@sA.scale(@radius), :origin => @pA)
  end

  def screen_out?
    false
  end
end

class App < Stylet::Base
  include Helper::CursorWithObjectCollection

  attr_reader :ray_mode
  attr_reader :reflect_mode

  def before_run
    super if defined? super

    @ray_mode = true           # true:ドット false:円
    @reflect_mode = true       # true:反射する

    @objects << Scene.new(self)
    @cursor.vertex = 3
  end

  def update
    super if defined? super

    if key_down?(SDL::Key::A)
      @ray_mode = !@ray_mode
    end

    if key_down?(SDL::Key::S)
      @reflect_mode = !@reflect_mode
    end

    # 操作説明
    vputs "A:ray=#{@ray_mode} S:reflect=#{@reflect_mode}"
    vputs "Z:ray++ X:ray-- C:drag V:angle"
  end
end

App.run
