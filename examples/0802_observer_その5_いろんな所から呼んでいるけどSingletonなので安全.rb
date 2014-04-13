# -*- coding: utf-8 -*-
require_relative "helper"

class Player
  include Observable
  def render
    changed
    notify_observers(self)
  end
end

class Window < SimpleDelegator
  def initialize(player)
    super(Stylet::Base.active_frame)
    player.add_observer(self)
  end

  def update(player)
    next_frame
    vputs [count, player.object_id, self.class.name]
  end
end

player = Player.new
Window.new(player)

60.times { player.render }      # observer形式で60回呼ぶ

# 【重要】 Stylet::Base.run の場合は singleton のインスタンスを汚さないので何度呼んでもいいが、
# Stylet::Base を継承して作ったクラスで update コールバックを使う場合はグローバルなインスタンスに結びついてしまうため
# 他のところで実行されたオブザーバーが update コールバックもいっしょに呼んでしまう。

Stylet::Base.run do             # これを実行し始めたときにはすでに count は 60 になっている
  if count == 120               # ので 60 フレームたったときにここにくる
    60.times { player.render }  # さらにループの中で observer 形式で呼び出しても Singleton なので安全
  end
  vputs [count, player.object_id, self.class.name]
end
