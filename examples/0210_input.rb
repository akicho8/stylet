# -*- coding: utf-8 -*-
# キーボードの入力チェック
require "./setup"

class Player
  include Stylet::Input::Base
  include Stylet::Input::StandardKeybord

  def initialize(win)
    super()
    @win = win
  end

  def update
    super
    key_counter_update_all
    @win.vputs(to_s)
    @win.vputs(axis_angle_index.to_s)
    @win.vputs(axis_angle.to_s)
  end
end

class App < Stylet::Base
  setup do
    self.title = "キーボードの入力チェック"
    @player = Player.new(self)
  end

  update do
    @player.update
  end

  run
end
