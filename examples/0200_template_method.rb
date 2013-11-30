# -*- coding: utf-8 -*-
require "./setup"

class App < Stylet::Base
  setup do
    self.title = "テンプレートメソッドパターン"
  end

  update do
    vputs "Hello, world."
  end

  run
end
