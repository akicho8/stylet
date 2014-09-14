# -*- coding: utf-8 -*-
require_relative "helper"

class MyApp < Stylet::Base
  attr_accessor :tasks
  def initialize(*)
    super
    @tasks = []
  end
  instance
end

class Player
  include Observable
  def render
    changed
    notify_observers(self)
  end
end

class Task
  include Stylet::Delegators

  def initialize
    @frame_counter = 0
  end

  def call
    @frame_counter += 1
    vputs "#{self.class.name} #{@frame_counter}"
    if @frame_counter >= 60
      Stylet::Base.active_frame.tasks.delete(self)
    end
  end
end

class Window < SimpleDelegator
  def initialize(player)
    super(Stylet::Base.active_frame) # MyApp.active_frame でも可
    player.add_observer(self)
  end

  def update(player)            # observer として呼ばれる update
    if frame_counter.modulo(120).zero?
      tasks << Task.new
    end
    tasks.each(&:call)

    next_frame                  # Stylet::Base#update を呼ぶ。干渉しない。
    vputs "#{self.class.name} #{frame_counter}"
  end
end

player = Player.new
window = Window.new(player)
loop do
  player.render
end
