# -*- coding: utf-8 -*-

module Stylet
  module Pause
    def initialize
      super
      @pause = false
    end

    def polling
      super
      if Stylet.config.pause_keys.any? {|key|key_down?(key)}
        @pause = !@pause
      end
    end

    def pause?
      @pause
    end
  end
end

if $0 == __FILE__
  require_relative "../stylet"
  Stylet.run
end
