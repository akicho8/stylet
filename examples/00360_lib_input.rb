# キーボードの入力チェック
require "./setup"

class Player
  include Stylet::Input::Base
  include Stylet::Input::StandardKeybordBind

  def update
    raise if defined? super
    key_bit_update_all
    key_counter_update_all
    Stylet.context.vputs(to_s)
    Stylet.context.vputs(axis_angle_index.to_s)
    Stylet.context.vputs(axis_angle.to_s)
  end
end

class App < Stylet::Base
  setup do
    self.title = "キーボードの入力チェック"
    @player = Player.new
  end

  update do
    @player.update
  end

  run
end
