# -*- coding: utf-8 -*-
require "spec_helper"

module Stylet
  describe Input::KeyOne do
    before do
      @key_one = Input::KeyOne.new(name: "A", match_chars: ["A"], store_char: "A", index: 0)
    end

    it "repeat" do
      cnt_ary = []
      rep_ary = []
      6.times do
        @key_one.counter_update(true)
        rep_ary << @key_one.repeat(3)
        cnt_ary << @key_one.count
      end
      rep_ary.should == [1, 0, 0, 0, 2, 3]
      cnt_ary.should == [1, 2, 3, 4, 5, 6]
    end

    it "<<" do
      @key_one << true
      @key_one.counter_update
      @key_one.count.should == 1

      @key_one << "A"
      @key_one.counter_update
      @key_one.count.should == 2
    end

    it "キーを離した瞬間がわかる" do
      @key_one.counter_update(true)
      @key_one.free_trigger?.should == false
      @key_one.counter_update(false)
      @key_one.free_trigger?.should == true
    end

    it "0.0 or 1.0 を返す(キーリピート対応)" do
      @key_one.counter_update(true)
      @key_one.repeat_0or1.should == 1.0
      @key_one.counter_update(false)
      @key_one.repeat_0or1.should == 0.0
    end
  end
end
