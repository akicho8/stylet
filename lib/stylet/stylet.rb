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

  # Stylet.context {|e| e.vputs "Hello" }
  # Stylet.context { vputs "Hello" }
  # Stylet.context.vputs "Hello"
  # Stylet.context.instance_exec(args{|args|...}
  def context(&block)
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

if $0 == __FILE__
  Stylet.run do
    vputs "a"
    Stylet.context.vputs "b"
    Stylet.context { vputs "c" }
    Stylet.context {|f| f.vputs "d" }
  end
end
