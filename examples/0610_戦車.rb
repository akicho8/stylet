# -*- coding: utf-8 -*-
# 戦車
require_relative "helper"

class Bullet
  def initialize(pos, dir, speed)
    @pos = pos
    @dir = dir
    @speed = speed

    @size = 8
    @radius = 0
  end

  def screen_out?
    Stylet::CollisionSupport.rect_out?(frame.rect, @pos) || @radius < 0
  end

  def update
    @radius += @speed
    frame.draw_triangle(@pos + Stylet::Vector.angle_at(@dir) * @radius, :radius => @size, :angle => @dir)
  end
end

class App < Stylet::Base
  include Helper::CursorWithObjectCollection

  setup do
    self.title = "戦車"

    @pos        = rect.center.clone    # 車体の位置
    @body_dir   = Stylet::Fee.clock(0) # 車体の進む方向
    @handle_dir = 0                    # ハンドル角度
    @accel      = 0                    # 加速度
    @speed      = 0                    # 速度
    @old_pos    = @pos.clone           # 前回の位置

    @cannon_dir = @body_dir

    @cursor.display = false
  end

  update do
    # リセット(画面外に行ってしまったとき用)
    if key_down?(SDL::Key::R)
      @pos = rect.center.clone
    end

    # ハンドル
    begin
      @handle_adir = 0
      if axis.left.press? || axis.right.press?
        # ハンドルの強さ。大きいと小回りが効く。
        @handle_adir = 0.0005
        if axis.left.press?
          @handle_adir *= -1
        end
      end
      @handle_dir += @handle_adir
      # ハンドルの角度の減速度(1.00なら車体が回りっぱなしになる)
      if @old_pos.truncate == @pos.truncate
        # @handle_dir *= 0.9  # 止まっている場合はハンドルがなかなか効かない(普通の車なら0.0)
      else
        # @handle_adir *= 1.1
        # @handle_dir *= 1.0  # 動いている状態ではハンドルが効きやすい
      end
      @handle_dir *= 0.95  # ハンドルを元に戻す
      handle_gap = 0.1     # ハンドルが曲る最大の角度
      @handle_dir = Stylet::Etc.range_limited(@handle_dir, (-handle_gap..handle_gap))
      @body_dir += @handle_dir
      vputs "ハンドル: #{@handle_dir.round(4)}"
      vputs "車体向き: #{@body_dir.round(4)}"
    end

    # アクセル
    begin
      @accel = 0
      if button.btA.press?
        @accel = 0.06             # 前の進むときの加速度
      end
      if button.btD.press?
        @accel = -0.06            # ブレーキの効き具合い
      end
      @speed += @accel
      @speed *= 0.98              # 空気抵抗
      @speed = Stylet::Etc.range_limited(@speed, (-2..2)) # 下るときと進むときの速度のリミット
      vputs "速度: #{@speed.round(4)}"
    end

    # 移動
    begin
      @old_pos = @pos.clone
      @pos += Stylet::Vector.angle_at(@body_dir) * @speed
    end

    # 砲台
    begin
      if joy = joys.first
        @cannon_vector = joy.adjusted_analog_levers[:left]
        if @cannon_vector.magnitude > 0.5
          @cannon_dir = @cannon_vector.angle
        end
      end
    end

    # if button.btA.count.modulo(8) == 1
    #   frame.objects << Bullet.new(@pos.clone, @pos.angle_to(@target.pos), 4.00)
    # end

    draw_rectangle(@pos, :angle => @cannon_dir, :radius => 30, :edge => 0.02)
    draw_rectangle(@pos, :angle => @body_dir, :radius => 25, :edge => 0.09)
  end

  run
end
