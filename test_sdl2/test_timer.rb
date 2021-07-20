require "./setup"

SDL2.init(SDL2::INIT_EVERYTHING)

# SDL2.init してからの経過ms
t = SDL2.get_ticks              # => 335
# パフォーマンス確認用のカウンタの精度は1秒間にこれだけ進む
SDL2.get_performance_frequency  # => 1000000000
# 1秒間で SDL2.get_performance_frequency だけ進むカウンタ値の取得
c = SDL2.get_performance_counter # => 495305640991272
# 1秒待つ
SDL2.delay(1000)                # => nil
# 1000ms進んだことがわかる
SDL2.get_ticks - t              # => 1001
# パフォーマンスカウンタも約 1000000000 進んだことがわかる
SDL2.get_performance_counter - c # => 1001206001
