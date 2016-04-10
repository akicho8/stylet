require "./setup"

Stylet.configure do |config|
  # config.background_image = "background.bmp"
  config.background_image = "assets/love_live.png"
end

Stylet.run(:title => "背景画像表示")
