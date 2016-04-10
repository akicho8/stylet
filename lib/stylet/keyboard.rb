module Stylet
  module Keyboard
    def run_initializers
      super
      init_on(:keyboard) do
        SDL::Key.scan # 先に SDL::Key.press? を呼ぶとエラーになるのを防ぐため
      end
    end

    def polling
      super if defined? super
      SDL::Key.scan
    end
  end
end
