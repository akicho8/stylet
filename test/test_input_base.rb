require "test_helper"

class TestInputBase < Test::Unit::TestCase
  setup do
    @klass = Class.new { include Stylet::Input::Base }
  end

  test "new" do
    obj = @klass.new
    assert_kind_of Stylet::Input::KeyOne, obj.button.to_a.first
  end
end
