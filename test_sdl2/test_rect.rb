require "./setup"

rect1 = SDL2::Rect[  0, 0, 100, 100] # => <SDL2::Rect: x=0 y=0 w=100 h=100>
rect2 = SDL2::Rect[50, 50, 100, 100] # => <SDL2::Rect: x=50 y=50 w=100 h=100>

# 重なった小さな領域を新しく返す
rect1.intersection(rect2)            # => <SDL2::Rect: x=50 y=50 w=50 h=50>

# 両方を含む広い領域を新しく返す
rect1.union(rect2)                   # => <SDL2::Rect: x=0 y=0 w=150 h=150>

rect1.x                              # => 0
rect1.y                              # => 0
rect1.w                              # => 100
rect1.h                              # => 100
