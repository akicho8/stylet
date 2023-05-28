require "./setup"

Stylet.run do
  vputs "RUBY_VERSION: #{RUBY_VERSION}"
  vputs "SGE: #{SDL2.respond_to?(:auto_lock)}"
end
