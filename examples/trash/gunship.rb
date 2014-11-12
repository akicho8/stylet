class GunShip
  include Stylet::Input::Base

  attr_reader :pos
  attr_accessor :target

  def initialize(win, pos)
    super()
    @win = win
    @pos = pos
    @speed = 3
    @target = nil
    @size = 8
    @joystick_index = nil
  end

  def update
    super if defined? super

    if @joystick_index
      bit_update_by_joy(@win.joys[@joystick_index])
    end
    key_bit_update_all
    key_counter_update_all

    if dir = axis_angle
      x = @pos.x + Stylet::Fee.rcos(dir) * @speed
      y = @pos.y + Stylet::Fee.rsin(dir) * @speed
      if (@win.srect.min_x..@win.srect.max_x).include?(x)
        @pos.x = x
      end
      if (@win.srect.min_y..@win.srect.max_y).include?(y)
        @pos.y = y
      end
    end

    @win.draw_rect(Stylet::Rect4.new(@pos.x - @size, @pos.y - @size, @size * 2, @size * 2))
  end
end
