require_relative "helper"

class W1 < SimpleDelegator
  def initialize
    super(Stylet::Base.active_frame)
  end

  def update
    next_frame
    vputs self.class.name
  end
end

class W2 < SimpleDelegator
  def initialize
    super(Stylet::Base.active_frame)
  end

  def update
    next_frame
    vputs self.class.name
  end
end

w1 = W1.new
w2 = W2.new

30.times { w1.update }
30.times { w2.update }
30.times { w1.update }
