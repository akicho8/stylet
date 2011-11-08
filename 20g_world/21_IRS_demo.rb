# -*- coding: utf-8 -*-
require File.expand_path(File.join(File.dirname(__FILE__), "environment"))

Library = {
  :title => "IRSが必要になるケース",
  :controller => SimulateWithSoundController.new,
  :pattern => "bb",
  :field => <<-EOT,
  ...o......
  ...o......
  bb.oo.r.o.
  bbbyy.r.o.
  bbbyy.r.oo
  EOT
}

if $0 == __FILE__
  Simulator.start(Library)
end
