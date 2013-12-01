# -*- coding: utf-8 -*-
# 戦車
require_relative "helper"

$DEBUG = false

class Tank
  include Stylet::Delegators
  include Stylet::Input::Base
  include Stylet::Input::ExtensionButton

  attr_accessor :pos
  attr_accessor :target
  attr_accessor :life
  attr_accessor :bullet_count
  attr_accessor :radius

  def initialize(name, pos)
    super()

    @name         = name
    @pos          = pos                        # 車体の位置
    @body_dir     = @pos.angle_to(rect.center) # 車体の進む方向
    @handle_dir   = 0                          # ハンドル角度
    @accel        = 0                          # 加速度
    @speed        = 0                          # 速度
    @old_pos      = @pos.clone                 # 前回の位置
    @bullet_count = 0                          # 発射している弾丸数
    @life         = 10                         # ライフ
    @anger        = 0                          # 怒り
    @radius       = 20                         # 車体の大きさ
    @bullet_max   = 3                          # 使える段数

    @cannon_dir   = @body_dir                  # 砲台の向き(実際)
    @cannon_dir2  = @body_dir                  # 砲台の向き(目標)
  end

  def update
    super if defined? super

    if @joystick_index
      if joy = joys[@joystick_index]
        update_by_joy(joy)
      end
    end

    key_counter_update_all

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
        # @handle_dir *= 0.8  # 止まっている場合はハンドルがなかなか効かない(普通の車なら0.0)
      else
        #   @handle_dir *= 1.0  # 動いている状態ではハンドルが効きやすい
      end
      @handle_dir *= 0.95   # ハンドルを元に戻す
      handle_gap = 0.1     # ハンドルが曲る最大の角度
      @handle_dir = Stylet::Etc.clamp(@handle_dir, (-handle_gap..handle_gap))
      @body_dir += @handle_dir
      vputs "ハンドル: #{@handle_dir.round(4)}" if $DEBUG
      vputs "車体向き: #{@body_dir.round(4)}" if $DEBUG
    end

    # アクセル
    begin
      @accel = 0
      if axis.up.press?
        @accel = 0.06             # 前の進むときの加速度
      end
      if axis.down.press?
        @accel = -0.06            # ブレーキの効き具合い
      end
      # @accel *= 2 if @life <= 1
      @speed += @accel if @life >= 1
      @speed *= 0.97              # 空気抵抗
      @speed = Stylet::Etc.clamp(@speed, (-1.0..5)) # 下るときと進むときの速度のリミット
      vputs "速度: #{@speed.round(4)}" if $DEBUG
    end

    # 移動
    begin
      @old_pos = @pos.clone
      @pos += Stylet::Vector.angle_at(@body_dir) * @speed
    end

    # 砲台
    begin
      # 砲台をアナログレバーの方向に向ける
      @cannon_dir2 = 0

      # 指定の方向に合わせる
      if joy = joys[@joystick_index]
        vec = joy.adjusted_analog_levers[:right]
        if vec.magnitude > 0.5
          # FIXME: ライブラリ化
          d = vec.angle.modulo(1.0) - @cannon_dir.modulo(1.0)
          if d < -1.0 / 2
            d = 1.0 + d
          elsif d > 1.0 / 2
            d = -1.0 + d
          end
          @cannon_dir2 = d
        end
      end

      # 車体の向きに合わせる
      if ext_button.btL1.press?
        d = @body_dir.modulo(1.0) - @cannon_dir.modulo(1.0)
        if d < -1.0 / 2
          d = 1.0 + d
        elsif d > 1.0 / 2
          d = -1.0 + d
        end
        @cannon_dir2 = d
      end

      # 相手の方向に合わせる
      if ext_button.btR1.press?
        d = @pos.angle_to(@target.pos) - @cannon_dir.modulo(1.0)
        if d < -1.0 / 2
          d = 1.0 + d
        elsif d > 1.0 / 2
          d = -1.0 + d
        end
        @cannon_dir2 = d
        # # ただしスピードが落ちる
        # @speed *= 0.9
      end

      @cannon_dir += @cannon_dir2 * 0.08 # 後ろの方にはなかなか向けられない

      vputs "cannon_dir2: #{@cannon_dir2}" if $DEBUG
      vputs "cannon_dir: #{@cannon_dir}" if $DEBUG
    end

    # タックルしたとき当り判定(減り込み回避のみ)
    begin
      diff = @target.pos - @pos
      rdiff = (@radius + @target.radius) - diff.magnitude
      if rdiff > 0
        @pos -= diff.normalize * rdiff / 2
        @target.pos += diff.normalize * rdiff / 2
      end
    end

    # 粉塵
    if false
      if @accel.nonzero? && @speed >= 1.0
        if count.modulo(3).zero?
          frame.objects << Dust.new(@pos, @body_dir + 0.5 + rand(-0.10..0.10), @speed * rand(6..8), rand(0.7..0.9), rand(15..20))
        end
      end
    end

    begin
      vputs "#{@name}: #{@life} (#{@power})"
    end

    if @life >= 1
      # 車体表示
      draw_rectangle(@pos, :angle => @cannon_dir, :radius => 25, :edge => 0.02)
      draw_rectangle(@pos, :angle => @body_dir, :radius => 25, :edge => 0.09)
    end
  end

  def damage
    if @life >= 1
      @life -= 1
      @anger += 1
      @bullet_max += 1          # 不利になると弾数が増える
      (n = 16).times do |i|
        frame.objects << Dust.new(@pos, 1.0 / n * i, rand(6..8), rand(0.7..0.9), 0)
      end
      Stylet::Audio.instance.se_stock["explosion01"].play
    end
  end
end

module BulletTrigger
  def initialize(*)
    super
    @power = 0
    @free_count = 0
  end

  def update
    super
    # ext_button.btR2.count.modulo(10) == 1
    if button.btC.trigger? || frame.key_down?(SDL::Key::B)
      if @bullet_count < @bullet_max
        @speed -= 0.2           # 玉を打つと反動で下がる。(FIXME: 砲台は前に向いていると限らないので間違い)
        frame.objects << Bullet.new(self, @pos.clone, @cannon_dir, 4)
      end
    end

    # 溜め
    if button.btC.press?
      @power += 1
      @free_count = 0
    else
      @free_count += 1
    end
    if @free_count == 1
      if @power >= 60 * 2
        @speed -= 0.3           # 玉を打つと反動で下がる
        1.times { frame.objects << Missile.new(self, @cannon_dir) }
      end
      @power = 0
    end
  end
end

class Tank1 < Tank
  include Stylet::Input::StandardKeybord
  include Stylet::Input::JoystickBinding
  include BulletTrigger

  def initialize(*)
    super
    @joystick_index = 0
  end
end

class Tank2 < Tank
  include Stylet::Input::ViLikeKeyboard
  include Stylet::Input::JoystickBinding
  include BulletTrigger

  def initialize(*)
    super
    @joystick_index = 1
  end
end

class Bullet
  attr_reader :death

  def initialize(tank, pos, dir, speed)
    @tank = tank
    @pos = pos
    @dir = dir
    @speed = speed

    @size = 6
    @radius = 26
    @death = false

    @tank.bullet_count += 1
    Stylet::Audio.instance.se_stock["A1_04069"].play
  end

  def update
    @radius += @speed
    _pos = @pos + Stylet::Vector.angle_at(@dir) * @radius
    frame.draw_triangle(_pos, :radius => @size, :angle => @dir, :vertex => 8)
    rc = Stylet::Rect.centered_create(@size * 1.5).add_vector(_pos)
    frame.draw_rect(rc) if $DEBUG
    if Stylet::CollisionSupport.rect_in?(rc, @tank.target.pos)
      if @tank.target.life >= 1
        @tank.target.damage
        final
      end
    end
    if Stylet::CollisionSupport.rect_out?(frame.rect, _pos)
      final
    end
  end

  def final
    unless @death
      @tank.bullet_count -= 1
      @death = true
    end
  end
end

class Missile
  attr_reader :death

  def initialize(tank, dir)
    @tank = tank
    @pos = tank.pos
    @dir = dir + rand(-0.1..0.1)
    @speed = rand(1.0..3.0)

    @size = 20
    @radius = 26
    @death = false

    Stylet::Audio.instance.se_stock["launch01"].play
  end

  def update
    if @tank.target.life >= 1
      a = @pos.angle_to(@tank.target.pos)
    else
      a = @pos.angle_to(frame.rect.center)
    end
    d = a.modulo(1.0) - @dir.modulo(1.0)
    if d < -1.0 / 2
      d = 1.0 + d
    elsif d > 1.0 / 2
      d = -1.0 + d
    end
    @dir += d * 0.04            # 誘導率
    # @speed += 0.01
    @speed = Stylet::Etc.clamp(@speed, (1..3))
    @radius += @speed
    _pos = @pos + Stylet::Vector.angle_at(@dir) * @radius
    frame.draw_triangle(_pos, :radius => @size, :angle => @dir)
    rc = Stylet::Rect.centered_create(@size * 1.5).add_vector(_pos)
    frame.draw_rect(rc) if $DEBUG
    if Stylet::CollisionSupport.rect_in?(rc, @tank.target.pos)
      if @tank.target.life >= 1
        @tank.target.damage
        final
      end
    end
    if Stylet::CollisionSupport.rect_out?(frame.rect, _pos)
      final
    end
  end

  def final
    unless @death
      @death = true
    end
  end
end

class Dust
  attr_reader :death

  def initialize(pos, dir, speed, friction, radius)
    @pos = pos
    @dir = dir
    @speed = speed
    @friction = friction
    @radius = radius

    @size = 1
    @death = false
  end

  def update
    @speed *= @friction
    @radius += @speed
    _pos = @pos + Stylet::Vector.angle_at(@dir) * @radius
    frame.draw_triangle(_pos, :radius => @size, :angle => @dir)
    if @speed.abs <= 0.03
      final
    end
  end

  def final
    @death = true
  end
end

class App < Stylet::Base
  include Helper::Cursor
  attr_reader :objects

  setup do
    Stylet::Audio.instance.se_stock.load_file("../sound_effect_libs/04/A1_04069.WAV")
    Stylet::Audio.instance.se_stock.load_file("explosion01.wav")
    Stylet::Audio.instance.se_stock.load_file("launch01.wav")

    self.title = "戦車 vs 戦車"
    cursor.display = false
    SDL::Mouse.hide
  end

  def reset_objects
    @objects = []
    @ships = []
    @tank1 = Tank1.new("1P", Stylet::Vector.new(rect.hx - rect.hx * 0.8, rect.hy))
    @tank2 = Tank2.new("2P", Stylet::Vector.new(rect.hx + rect.hx * 0.8, rect.hy))
    @tank1.target = @tank2
    @tank2.target = @tank1
    @ships << @tank1
    @ships << @tank2
  end
  setup :reset_objects

  update do
    if frame.key_down?(SDL::Key::R) || ((joy = joys.first) && joy.button(0) && joy.button(3))
      reset_objects
    end
    @ships.each(&:update)
    @objects.each(&:update)
    @objects.reject!{|e|e.death}
  end

  run
end
