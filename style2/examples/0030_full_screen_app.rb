require "./setup"

class FullScreenApp < Stylet2::Base
  def initialize(*)
    super
    params[:full_screen] = true
  end

  def view
    super
    vputs window.fullscreen_mode
  end

  run
end
