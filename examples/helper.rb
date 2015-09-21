require "./setup"

require_relative "cursor"

module Helper

  module ObjectCollection
    extend ActiveSupport::Concern

    included do
      attr_reader :objects

      setup do
        @objects = []
      end

      update do
        @objects.each(&:update)
        @objects.reject! {|e|e.respond_to?(:screen_out?) && e.screen_out?}
      end
    end
  end

  module CursorWithObjectCollection
    extend ActiveSupport::Concern
    include ObjectCollection
    include Cursor
  end
end

require_relative "movable_point"

if $0 == __FILE__
  Class.new(Stylet::Base) do
    include Helper::CursorWithObjectCollection
    run
  end
end
