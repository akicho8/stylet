require_relative "helper"

class Particle
  include Stylet::Delegators
  delegate :objects, :button, :cursor, :to => "Stylet.context"

  GRAVITY = 2.0

  attr_reader :p0, :p1, :diameter, :mass

  def initialize(point, mass)
    @p0 = point.clone
    @p1 = point.clone

    @speed = vec2[0, 0]
    @accel = vec2[0, 0]

    @mass = mass                            # 質量
    @diameter = Math.sqrt(mass) * 20 # 直径
  end

  def update
    @accel = vec2[0, 0]
    @min_dist = 1000

    objects.each do |e|
      if e == self
        next
      end
      dist = Math.hypot(*(@p0 - e.p0))
      dir = -angle_of(@p0, e.p0)
      if dist < @min_dist
        @min_dist = dist
      end
      force = (GRAVITY * mass * e.mass) / dist
      if dist > diameter
        @accel.x += force / mass * Math.cos(dir)
        @accel.y += force / mass * Math.sin(dir)
      end
    end

    # 計算
    @speed += @accel
    @p1 = @p0 + @speed

    # 描画
    charge_col  = 1000.0 / @min_dist / 50.0
    tot_col_1   = 100 + charge_col * 6
    tot_col_2   = 150 + charge_col * charge_col
    tot_col_3   = diameter + 8 + charge_col

    draw_circle(p1, :radius => diameter / 2)

    @p0 = p1.clone
  end

  def angle_of(p1, p2)
    v = p1 - p2
    Math::PI - Math.atan2(v.y, v.x)
  end
end

class App < Stylet::Base
  include Helper::CursorWithObjectCollection

  setup do
    3.times do
      objects << Particle.new(srect.center + vec2.rand(-100..+100), rand(0.1..8))
    end
  end

  update do
    if button.btA.trigger?
      objects << Particle.new(mouse.point, rand(0.1..8))
    end
  end

  run
end
