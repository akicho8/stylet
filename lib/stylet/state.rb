# -*- coding: utf-8 -*-
# 状態遷移管理

class State
  attr_reader :count, :state, :looping

  def initialize(state = nil)
    soft_jump_to(state)
  end

  def start?
    @count == 0
  end

  def pass
    @count += 1
  end

  def count_at?(count)
    @count == count
  end

  # 状態遷移
  def soft_jump_to(state)
    @state = state
    @count = 0
  end

  # 一気に次の状態に移行する
  def jump_to(state)
    soft_jump_to(state)
    if @looping
      throw transit_key
    end
  end

  # jump_to を使って瞬時に別の状態に移行するためのブロックを作る
  #
  # Example:
  #
  #   object = State.new(:idle)
  #   object.loop_in do
  #     case object.state
  #     when :idle
  #       if object.count_at?(1)
  #         object.jump_to(:active)
  #       end
  #     when :active
  #       if object.start?
  #       end
  #       if object.count_at?(1)
  #       end
  #     end
  #   end
  #
  def loop_in(&block)
    @looping = true
    begin
      ret = catch(transit_key) do
        yield
        true
      end
    end until ret == true
    @looping = false
    pass
  end

  def transit_key
    :"transit_#{object_id}"
  end

  def to_s
    "#{@state}: #{@count} (#{transit_key})"
  end
end
