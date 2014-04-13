# -*- coding: utf-8 -*-
require "spec_helper"

describe State do
  it "call" do
    trace_ary = []
    object = State.new(:idle)
    loop_flag = true
    while loop_flag
      object.loop_in do
        trace_ary << [object.state, object.count]
        case object.state
        when :active
          if object.count_at?(1)
            loop_flag = false
          end
        when :idle
          if object.count_at?(1)
            object.jump_to(:active)
          end
        end
      end
    end
    trace_ary.should == [[:idle, 0], [:idle, 1], [:active, 0], [:active, 1]]
  end
end
