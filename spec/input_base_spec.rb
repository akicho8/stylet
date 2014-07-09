require "spec_helper"

module Stylet
  describe Input::Base do
    before do
      @klass = Class.new { include Input::Base }
    end

    it "new" do
      obj = @klass.new
      obj.button.to_a.first.should be_an_instance_of(Input::KeyOne)
      obj.button.to_a.first.should be_a_kind_of(Input::KeyOne)
    end
  end
end
