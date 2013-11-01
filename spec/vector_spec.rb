# -*- coding: utf-8 -*-
require "spec_helper"

module Stylet
  describe Vector do
    it do
      (Vector.new(1, 2) + Vector.new(3, 4)).should == Vector.new(4, 6)
    end
  end
end
