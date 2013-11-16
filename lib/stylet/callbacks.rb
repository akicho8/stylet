require 'active_support/callbacks'
require 'active_model/callbacks'

module Stylet
  module Callbacks
    extend ActiveSupport::Concern

    included do
      extend ActiveModel::Callbacks
      define_model_callbacks :setup, :update, :main_loop, :terminator => "false"
    end

    module ClassMethods
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
