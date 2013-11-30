# -*- coding: utf-8 -*-
# キーボードの入力チェック
require "./setup"

class Player
  include Stylet::Input::Base
  include Stylet::Input::StandardKeybord

  def update
    super
    key_counter_update_all
    frame.vputs(to_s)
    frame.vputs(axis_angle_index.to_s)
    frame.vputs(axis_angle.to_s)
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
