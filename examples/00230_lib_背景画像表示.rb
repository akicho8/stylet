require "./setup"

Stylet.configure do |config|
  # config.background_image = "background.bmp"
  config.background_image = "assets/love_live.png"
  # config.background_image = "../assets/images/pingpong/pingpong_chara01.png"
end

Stylet.run(:title => "背景画像表示")
