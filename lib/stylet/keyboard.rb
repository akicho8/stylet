module Stylet
  module Keyboard
    def run_initializers
      super
      init_on(:keyboard) do
        # SDL2::Key.scan # 先に SDL2::Key.press? を呼ぶとエラーになるのを防ぐため
      end
    end

    def polling
      super if defined? super
      # SDL2::Key.scan
    end
  end
end
