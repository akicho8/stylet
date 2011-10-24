$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + "/.."))
require "test_helper"

class TestController < BaseController
  def initialize(params = {})
    super()
    @level_info = LevelInfo.new
    {
      :speed        => 20.0, # 初期スピード
      :acceleration => 0,    # 加速度(これは使わないからどうにかしたい)
      :next_delay   => 0,    # 消さないときの次の待ち
      :fall_delay   => 0,    # 消したときの待ち1
      :next_delay2  => 0,    # 消したときの待ち2
      :lock_delay   => 30,   # 固まるまでの時間
      :flash_delay  => 0,    # 白く光る時間
    }.update(params).each{|k,v| @level_info[k]=v}
    @start_delay = 1            # 2frame目で出現
    @end_delay = 0
  end
end

class TestPlayer < Test::Unit::TestCase
  def frame_at(tm, dim, pos, controller, order, params = {})
    field = Field.new(dim)
    player = Player.new(field, pos, TextInputUnit.new(controller), Pattern::Original.new(order), TestController.new(params))
    tm.times {player.next_frame}
    player.puton
    field.to_s(:ustrip => true)
  end

  def test_irs
    expected = <<-END
...c....
...cc...
...c....
      END
    assert_equal(expected, frame_at(1, [8, 5], 3, %w(A), "c"))
  end

  def test_transit
    expected = <<-END
..rrrr..
..ccc...
...c....
...pp...
..pp....
..gg....
...gg...
..ooo...
..o.....
..bbb...
....b...
...yy...
...yy...
      END
    assert_equal(expected, frame_at(7, [8, 20], 3, [""]*7, "ybogpcr", :lock_delay => 0))
  end

  def test_kill_line
    expected = <<-END
    END
    assert_equal(expected, frame_at(2, [4, 5], 1, [""]*2, "r", :lock_delay => 0, :fall_delay => 1))
  end
end
