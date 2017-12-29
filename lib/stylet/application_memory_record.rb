require "memory_record"

module Stylet
  module ApplicationMemoryRecord
    extend ActiveSupport::Concern

    included do
      include MemoryRecord
    end

    class_methods do
      def info
        collect(&:to_h).to_t
      end
    end

    def info
      to_h.to_t
    end

    def to_h
      attributes
    end

    def name_with_key
      "#{name} (#{key})"
    end

    def logger
      Stylet.logger
    end
  end
end
