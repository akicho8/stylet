require "./setup"

Stylet.run do
  Stylet.config.each do |k, v|
    vputs [k, v]
  end
end
