require "test_helper"

class Foo < Test::Unit::TestCase
  setup do
    @a = 1
  end
  test "a" do
    assert_equal 1, @a
  end
  test "b" do
    assert_equal 1, 1
  end
end
