require_relative "setup"

Stylet.run do
  vi = SDL2::Screen.info
  vi.class.instance_methods(false).each do |var|
    vputs "#{var} #{vi.send(var)}"
  end
end
