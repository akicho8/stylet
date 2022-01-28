# tixy.land

require_relative "helper"
require_relative "lifegame_patterns"

Stylet.config.fps = 30

class App < Stylet::Base
  include Helper::CursorWithObjectCollection

  PATTERNS = [
    { name: "default",                                              func: -> (t, i, x, y) { Math.sin(y/8+t)                            } },
    { name: "for every dot return 0 or 1 to change the visibility", func: -> (t, i, x, y) { rand < 0.1                                 } },
    { name: "use a float between 0 and 1 to define the size",       func: -> (t, i, x, y) { rand                                       } },
    { name: "parameter `t` is the time in seconds",                 func: -> (t, i, x, y) { Math.sin(t)                                } },
    { name: "parameter `i` is the index of the dot (0..255)",       func: -> (t, i, x, y) { i / 256                                    } },
    { name: "`x` is the column index from 0 to 15",                 func: -> (t, i, x, y) { x / 16                                     } },
    { name: "`y` is the row also from 0 to 15",                     func: -> (t, i, x, y) { y / 16                                     } },
    { name: "positive numbers are white, negatives are red",        func: -> (t, i, x, y) { y - 7.5                                    } },
    { name: "use the time to animate values",                       func: -> (t, i, x, y) { y - t                                      } },
    { name: "multiply the time to change the speed",                func: -> (t, i, x, y) { y - t*4                                    } },
    { name: "create patterns using different color",                func: -> (t, i, x, y) { [1, 0, -1][i%3]                            } },
    { name: "skip `Math.` to use methods",                          func: -> (t, i, x, y) { Math.sin(t-Math.sqrt((x-7.5)**2+(y-6)**2)) } },
    { name: "more examples",                                        func: -> (t, i, x, y) { Math.sin(y/8 + t)                          } },
    { name: "simple triangle",                                      func: -> (t, i, x, y) { y - x                                      } },
    { name: "quarter triangle",                                     func: -> (t, i, x, y) { (y > x) && (14-x < y)                      } },
    { name: "pattern",                                              func: -> (t, i, x, y) { i%4 - y%4                                  } },
    { name: "grid",                                                 func: -> (t, i, x, y) { (i%4)>0 && (y%4)>0                         } },
    { name: "square",                                               func: -> (t, i, x, y) { x>3 && y>3 && x<12 && y<12                 } },
    { name: "animated square",                                      func: -> (t, i, x, y) { (x>t && y>t && x<15-t && y<15-t) ? -1 : 0  } },
    { name: "mondrian squares",                                     func: -> (t, i, x, y) { (y-6) * (x-6)                              } },
    { name: "moving cross",                                         func: -> (t, i, x, y) { (y-4*t) * (x-2-t)                          } },
    { name: "sierpinski",                                           func: -> (t, i, x, y) { (4*t).to_i & i.to_i & x.to_i & y.to_i      } },

    { name: "binary clock",                      func: -> (t, i, x, y) { (t*10).to_i & (1<<x) && y==8 } },
    { name: "random noise",                      func: -> (t, i, x, y) { rand(-1.0..1.0) } },
    { name: "static smooth noise",               func: -> (t, i, x, y) { Math.sin(i**2) } },
    { name: "animated smooth noise",             func: -> (t, i, x, y) { Math.cos(t + i + x * y) } },
    { name: "waves",                             func: -> (t, i, x, y) { Math.sin(x/2) - Math.sin(x-t) - y+6 } },
    { name: "bloop bloop bloop by @v21",         func: -> (t, i, x, y) { (x-8)*(y-8) - Math.sin(t)*64 } },
    { name: "fireworks by @p_malin and @aemkei", func: -> (t, i, x, y) { -0.4/(Math.hypot(x-t%10,y-t%8)-t%2*9) } },
    { name: "ripples by @thespite",              func: -> (t, i, x, y) { Math.sin(t-Math.sqrt(x*x+y*y)) } },
    { name: "scrolling TIXY font by @atesgoral",              func: -> (t, i, x, y) { Math.sin(t-Math.sqrt(x*x+y*y)) } },
    { name: "3d checker board by @p_malin",              func: -> (t, i, x, y) {
        a = 0
        b = 0
        if y >= 1
          a = (x - 8) / y + t * 5
          b = 1 / y * 8
        end
        (a.to_i & 1 ^ b.to_i & 1) * y / 5

      } },
    { name: "sticky blood by @joeytwiddle",              func: -> (t, i, x, y) { y-t*3+9+3*Math.cos(x*3-t)-5*Math.sin(x*7) } },
    { name: "3d starfield by @p_malin",                  func: -> (t, i, x, y) { d=y*y%5.9+1;(((x+t*50/d).to_i&15).zero? ? 1/d : 0) } },
    { name: "dialogue with an alien by @chiptune",       func: -> (t, i, x, y) { 1.0/32.0*Math.tan(t/64.0*x*Math.tan(i-x)) } },
    { name: "hungry pac man by @p_malin and @aemkei",    func: -> (t, i, x, y) { Math.hypot(x-=t%4*5,y-=8)<6 && x<y || y<-x } }, # ?
    { name: "spectrum analyser by @joeytwiddle",         func: -> (t, i, x, y) { (x.to_i & y.to_i) < (9 & y.to_i) >4+Math.sin(8*t+x*x)+x/4 } }, # ?
    { name: "diagonals",         func: -> (t, i, x, y) { y == x || ((15-x == y) ? -1 : 0 ) }},
    { name: "frame",           func: -> (t, i, x, y) { x==0 || x==15 || y==0 || y==15 }},
    { name: "drop",            func: -> (t, i, x, y) { 8*t%13 - Math.hypot(x-7.5, y-7.5)    }},
    { name: "rotation",        func: -> (t, i, x, y) { Math.sin(2*Math.atan((y-7.5)/(x-7.5))+5*t) }},

  ]

  setup do
    @world_size    = 16
    @cell_size_px  = 16
    @pattern_index = -1
  end

  update do
    if current_pattern
      vputs "#{@pattern_index}: #{current_pattern[:name]}"
    end

    if button.btA.repeat == 1 || button.btB.repeat == 1
      @pattern_index += (button.btA.repeat_0or1 - button.btB.repeat_0or1)
    end

    top_left = srect.center - vec2[@world_size, @world_size].scale(@cell_size_px * 0.5)

    time = frame_counter.fdiv(Stylet.config.fps)

    index = 0
    @world_size.times do |y|
      @world_size.times do |x|
        v = top_left + vec2[x, y].scale(@cell_size_px)
        rv = any_func(time, index, x, y)
        if rv.kind_of?(Numeric)
          rv = rv.clamp(-1.0, 1.0)
          if rv.positive?
            c1 = rv * 255
            rgb = [c1, c1, c1]
          elsif rv.negative?
            c1 = -rv * 255
            rgb = [0, c1, 0]
          else
            rgb = [0, 0, 0]
          end
          screen.fill_rect(*v, @cell_size_px, @cell_size_px, rgb)
        end

        index += 1
      end
    end

    # draw_rect4(*srect.center, 2, 2, fill: true, color: :red)
  end

  def any_func(t, i, x, y)
    if e = current_pattern
      r = e[:func].call(t, Float(i), Float(x), Float(y))
      if r == true
        r = 1.0
      elsif r == false || r.nil?
        r = 0.0
      end
      r
    end
  end

  def current_pattern
    PATTERNS[@pattern_index.modulo(PATTERNS.size)]
  end

  run
end
