require "./setup"

class HelloApp < Stylet2::Base
  def view
    super
    vputs "Hello"
  end

  run
end
