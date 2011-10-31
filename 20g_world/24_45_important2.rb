# -*- coding: utf-8 -*-
require "environment"

Library = {
  :title => "45列目重要",
  :controller => SimulateWithSoundController.new,
  :pattern => "br",
  :field => <<-EOT,
  ..b.......
  ..bbbbbbbb
  ..bbbbbbbb
  .bbbbbbbbb
  .bbbbbbbbb
  .bbbbbbbbb
  .bbbbbbbbb
  .bbbbbbbbb
  .bbbbbbbbb
  .bbbbbbbbb
  .bbbbbbbbb
  .bbbbbbbbb
  .bbbbbbbbb
  .bbbbbbbbb
  .bbbbbbbbb
  .bbbbbbbbb
  EOT
}

if $0 == __FILE__
  Simulator.start(Library)
end
