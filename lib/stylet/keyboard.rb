# -*- coding: utf-8 -*-
module Stylet
  module Keyboard
    def run_initializers
      super
      init_on(:keyboard) do
        # SDL::Key.press? のタイミングが難しくなるためとにかく最初に scan しておく
        SDL::Key.scan
      end
    end

    def polling
      super if defined? super
      SDL::Key.scan
    end
  end
end
