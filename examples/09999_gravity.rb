require_relative "helper"

class Particle
  include Stylet::Delegators
  delegate :objects, :button, :cursor, :to => "Stylet.context"

  GRAVITY = 2.0

  attr_reader :p0, :p1, :diameter, :mass_amount

  def initialize(point, mass)
    @p0 = point.clone
    @p1 = point.clone

    @speed = vec2[0, 0]
    @accel = vec2[0, 0]

    @mass_amount = mass
    @diameter = Math.sqrt(mass_amount) * 20
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
      force = (GRAVITY * mass_amount * e.mass_amount) / dist
      if dist > diameter
        @accel.x += force / mass_amount * Math.cos(dir)
        @accel.y += force / mass_amount * Math.sin(dir)
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

    # fill(tot_col_1, tot_col_1, 255, charge_col * 150 + 3)
    # ellipse(p1.x, p1.y, tot_col_3, tot_col_3)
    # fill 0, 255
    # stroke tot_col_2, tot_col_2, 255, charge_col * 255 + 3
    # ellipse p1.x, p1.y, diameter, diameter

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
