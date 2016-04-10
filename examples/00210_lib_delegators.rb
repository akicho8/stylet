# Stylet::Delegators で Stylet::Base.active_frame に移譲しまくっているので vputs がそのまま使える
require "./setup"

class App < Stylet::Base
  update { Class.new { include Stylet::Delegators }.new.vputs "ok" }
  run
end
