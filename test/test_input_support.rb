require "test_helper"

class TestInputSupport < Test::Unit::TestCase
  setup do
    @left  = Stylet::Input::KeyOne.new(name: "L", match_chars: "L", store_char: "L", index: 0)
    @right = Stylet::Input::KeyOne.new(name: "R", match_chars: "R", store_char: "R", index: 0)
  end

  # 入力優先順位テスト
  test "preference_key" do
    # 最初は両方押されていないので nil が返る。
    assert_equal nil, preference_key

    # 左だけ押されると、もちろん左が優先される。
    @left.counter_update(true)
    @right.counter_update(false)
    assert_equal @left, preference_key

    # 次のフレーム。左は押しっぱなし。右を初めて押した。すると右が優先される。
    @left.counter_update(true)
    @right.counter_update(true)
    assert_equal @right, preference_key

    # 次のフレーム。両方離した。nil が返る。
    @left.counter_update(false)
    @right.counter_update(false)
    assert_equal nil, preference_key

    # 次のフレーム。両方同時押し。左が優先される。
    @left.counter_update(true)
    @right.counter_update(true)
    assert_equal @left, preference_key
  end

  test "key_power_effective?" do
    @right.counter_update(true)
    assert_false Stylet::Input::Support.key_power_effective?(@left, @right, 2)
    @right.counter_update(true)
    assert_false Stylet::Input::Support.key_power_effective?(@left, @right, 2)
    @right.counter_update(true)
    assert_true Stylet::Input::Support.key_power_effective?(@left, @right, 2)
  end

  def preference_key
    Stylet::Input::Support.preference_key(@left, @right)
  end
end
