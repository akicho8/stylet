# -*- coding: utf-8 -*-
require_relative 'version'
require_relative 'base'
require_relative 'input'
require_relative 'state'
require_relative 'contrib/menu'

module Stylet
  extend self

  # ショートカット
  #   Stylet.run { vputs "Hello" }
  def run(*args, &block)
    Base.run(*args, &block)
  end

  def __frame__(&block)
    if block
      if block.arity == 1
        block.call(Base.active_frame)
      else
        Base.active_frame.instance_eval(&block)
      end
    else
      Base.active_frame
    end
  end

  def hello_world
    run { vputs "Hello, World" }
  end
end

module Kernel
  def __frame__(&block)
    Stylet.__frame__(&block)
  end
end

if $0 == __FILE__
  Stylet.run do
    vputs "a"
    __frame__.vputs "b"
    __frame__ { vputs "c" }
    __frame__ {|f| f.vputs "d" }
  end
end