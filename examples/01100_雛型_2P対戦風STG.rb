require "./setup"

class GunShip
  include Stylet::Delegators
  include Stylet::Input::Base

  attr_reader :pos
  attr_accessor :target

  def initialize(pos)
    super()
    @pos = pos                  # 自機の位置
    @speed = 3                  # 移動速度
    @size = 8 * 3               # 自機の大きさ
    @joystick_index = nil       # 自分のジョイスティックの番号
    @target = nil               # 相手
  end

  def update
    if @joystick_index
      bit_update_by_joy(Stylet.context.joys[@joystick_index])
    end
    key_bit_update_all
    key_counter_update_all

    if dir = axis_angle
      next_pos = @pos + vec2.angle_at(dir) * @speed
      if Stylet::CollisionSupport.rect_in?(Stylet.context.srect, next_pos)
        @pos = next_pos
      end
    end

    draw_triangle(@pos, :radius => @size, :angle => @pos.angle_to(@target.pos))
  end
end

module BulletTrigger
  def update
    super
    if @button.btA.counter.modulo(8) == 1
      Stylet.context.objects << Bullet.new(@pos.clone, @pos.angle_to(@target.pos), 4.00)
    end
  end
end

class GunShip1 < GunShip
  include Stylet::Input::StandardKeybordBind
  include Stylet::Input::JoystickBindMethod
  include BulletTrigger

  def initialize(*)
    super
    @joystick_index = 0
  end
end

class GunShip2 < GunShip
  include Stylet::Input::HjklKeyboardBind
  include Stylet::Input::JoystickBindMethod
  include BulletTrigger

  def initialize(*)
    super
    @joystick_index = 1
  end
end

class Bullet
  include Stylet::Delegators

  def initialize(pos, dir, speed)
    @pos = pos
    @dir = dir
    @speed = speed

    @size = 8
    @radius = 0
  end

  def screen_out?
    Stylet::CollisionSupport.rect_out?(srect, @pos) || @radius < 0
  end

  def update
    @radius += @speed
    draw_triangle(@pos + vec2.angle_at(@dir) * @radius, :radius => @size, :angle => @dir)
  end
end

class App < Stylet::Base
  attr_reader :objects

  setup do
    self.title = "二人対戦風シューティング"
    @objects = []
    ship1 = GunShip1.new(vec2[srect.hx, srect.hy - srect.hy * 0.8])
    ship2 = GunShip2.new(vec2[srect.hx, srect.hy + srect.hy * 0.8])
    ship1.target = ship2
    ship2.target = ship1
    @objects << ship1
    @objects << ship2
  end

  update do
    @objects.each(&:update)
  end

  run
end
