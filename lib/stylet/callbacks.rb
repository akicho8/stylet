# -*- coding: utf-8 -*-
require 'active_support/callbacks'
require 'active_model/callbacks'

module Stylet
  module Callbacks
    extend ActiveSupport::Concern

    included do
      extend ActiveModel::Callbacks
      define_model_callbacks :setup, :update, :main_loop
    end

    class_methods do
      def setup(*args, &block)
        set_callback(:setup, *args, &block)
      end

      def update(*args, &block)
        set_callback(:update, *args, &block)
      end
    end

    def setup
      run_callbacks(:setup) { super }
    end

    def update
      run_callbacks(:update) { super }
    end

    def main_loop(&block)
      run_callbacks(:main_loop) { super(&block) }
    end
  end
end

if $0 == __FILE__
  require_relative "../stylet"

  # 方法1
  Stylet::Base.setup { @a = "A" }
  Stylet::Base.update { vputs @a }
  Stylet::Base.run

  # 方法2
  module Stylet
    class Base
      setup { @b = "B" }
      update { vputs @b }
      run
    end
  end

  # 方法3 (他の方法のあとに呼ぶとだめなのはなぜ？)
  # Stylet::Base.reset_callbacks(:setup)
  # Stylet::Base.reset_callbacks(:update)
  class A < Stylet::Base
    setup { @c = "C" }
    update { vputs @c }
    run
  end
end
