# -*- coding: utf-8 -*-
require "spec_helper"

module Stylet
  describe Input::Support do
    before do
      @left = Input::KeyOne.new
      @right = Input::KeyOne.new
    end

    # 入力優先順位テスト
    it "preference_key" do
      # 最初は両方押されていないので nil が返る。
      preference_key.should == nil

      # 左だけ押されると、もちろん左が優先される。
      @left.counter_update(true)
      @right.counter_update(false)
      preference_key.should == @left

      # 次のフレーム。左は押しっぱなし。右を初めて押した。すると右が優先される。
      @left.counter_update(true)
      @right.counter_update(true)
      preference_key.should == @right

      # 次のフレーム。両方離した。nil が返る。
      @left.counter_update(false)
      @right.counter_update(false)
      preference_key.should == nil

      # 次のフレーム。両方同時押し。左が優先される。
      @left.counter_update(true)
      @right.counter_update(true)
      preference_key.should == @left
    end

    it "key_power_effective?" do
      @left = Input::KeyOne.new
      @right = Input::KeyOne.new
      @right.counter_update(true)
      Input::Support.key_power_effective?(@left, @right, 2).should == false
      @right.counter_update(true)
      Input::Support.key_power_effective?(@left, @right, 2).should == false
      @right.counter_update(true)
      Input::Support.key_power_effective?(@left, @right, 2).should == true
    end

    private

    def preference_key
      Input::Support.preference_key(@left, @right)
    end
  end
end
