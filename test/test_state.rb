require "test_helper"

class TestState < Test::Unit::TestCase
  description "あいうえお"
  test "all" do
    trace_ary = []
    state = State.new(:idle)
    loop_flag = true
    while loop_flag
      state.loop_in do
        trace_ary << [state.key, state.counter]
        case state.key
        when :active
          if state.counter_at?(1)
            loop_flag = false
          end
        when :idle
          if state.counter_at?(1)
            state.jump_to :active
          end
        end
      end
    end
    assert_equal [[:idle, 0], [:idle, 1], [:active, 0], [:active, 1]], trace_ary
  end
end
