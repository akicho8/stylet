# -*- coding: utf-8 -*-
require "test_helper"

class TestInputKeyOne < Test::Unit::TestCase
  setup do
    @key_one = Stylet::Input::KeyOne.new(name: "A", match_chars: "A", store_char: "A", index: 0)
  end

  test "repeat" do
    cnt_ary = []
    rep_ary = []
    6.times do
      @key_one.counter_update(true)
      rep_ary << @key_one.repeat(3)
      cnt_ary << @key_one.count
    end
    assert_equal [1, 0, 0, 0, 2, 3], rep_ary
    assert_equal [1, 2, 3, 4, 5, 6], cnt_ary
  end

  test "<<" do
    @key_one << true
    @key_one.counter_update
    assert_equal 1, @key_one.count

    @key_one << "A"
    @key_one.counter_update
    assert_equal 2, @key_one.count
  end

  test "キーを離した瞬間がわかる" do
    @key_one.counter_update(true)
    assert_false @key_one.free_trigger?
    @key_one.counter_update(false)
    assert_true @key_one.free_trigger?
  end

  test "0.0 or 1.0 を返す(キーリピート対応)" do
    @key_one.counter_update(true)
    assert_equal 1.0, @key_one.repeat_0or1
    @key_one.counter_update(false)
    assert_equal 0.0, @key_one.repeat_0or1
  end
end
