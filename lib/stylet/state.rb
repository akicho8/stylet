# -*- coding: utf-8 -*-
#
# 状態遷移管理
#
#   state = State.new(:idle)
#   state.loop_in do
#     case state.key
#     when :idle
#       if state.counter_at?(1)
#         state.jump_to :active
#       end
#     when :active
#       if state.start?
#       end
#       if state.counter_at?(1)
#       end
#     end
#   end
#
class State
  attr_reader :counter, :key

  def initialize(key = nil)
    @_loop_break = Object.new
    @_transit_key = Object.new
    @depth = 0
    jump_to(key)
  end

  def start?
    @counter == 0
  end

  def pass
    @counter += 1
  end

  def counter_at?(counter)
    @counter == counter
  end

  def jump_to(key)
    soft_jump_to(key)
    if @depth.nonzero?
      throw @_transit_key
    end
  end

  def loop_in(&block)
    @depth += 1
    catch @_loop_break do
      loop do
        catch @_transit_key do
          yield
          throw @_loop_break
        end
      end
    end
    @depth -= 1
    pass
  end

  def to_s
    "#{@key}: #{@counter} (#{@_transit_key})"
  end

  private

  def soft_jump_to(key)
    @key = key
    @counter = 0
  end
end
