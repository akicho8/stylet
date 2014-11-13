# -*- coding: utf-8 -*-
#
# ライフゲーム
#
# Conway's Game of Life http://www.conwaylife.com/
#

require_relative "helper"
require_relative "lifegame_patterns"

class App < Stylet::Base
  include Helper::CursorWithObjectCollection

  setup do
    @matrixs = Array.new(2){{}}
    @generation = 0
    @cell_list_index = 0

    @size = 12
    @width  = srect.width / @size
    @height = srect.height / @size

    reset
  end

  update do
    next_generation
    display
  end

  def reset
    @generation = 0
    @matrixs[0].clear
    LifegamePatterns[@cell_list_index.modulo(LifegamePatterns.size)].strip.lines.each_with_index do |line, y|
      line.chars.each_with_index do |char, x|
        if char.match(/[oO■]/)
          @matrixs[0][[x, y]] = true
        end
      end
    end
  end

  def next_generation
    if button.btA.repeat == 1 || button.btB.repeat == 1
      @cell_list_index += (button.btA.repeat_0or1 - button.btB.repeat_0or1)
      reset
    end
    if button.btC.repeat == 1
      reset
    end

    @matrix = @matrixs[@generation.modulo(@matrixs.size)]
    @next_matrix = @matrixs[@generation.next.modulo(@matrixs.size)]

    @height.times do |y|
      @width.times do |x|
        vec = vec2.new(x, y)
        frame_counter = around_vectors.count do |v|
          @matrix[(vec + v).to_a.collect(&:to_i)]
        end
        @next_matrix[vec.to_a] = @matrix[vec.to_a] ? (frame_counter == 2 || frame_counter == 3) : (frame_counter == 3)
      end
    end

    @generation += 1
  end

  def display
    if @next_matrix
      @next_matrix.each do |xy, cell|
        if cell
          v = vec2.new(*xy)
          v = (v * @size) + srect.to_vector + cursor.point
          draw_rect(Stylet::Rect4.new(*v, @size, @size), :fill => true, :color => :font)
        end
      end
    end
  end

  def around_vectors
    @around_vectors ||= [[-1, -1], [0, -1], [1, -1], [-1,  0], [1,  0], [-1, 1], [0, 1], [1, 1]].collect do |e|
      vec2.new(*e)
    end
  end

  run
end
