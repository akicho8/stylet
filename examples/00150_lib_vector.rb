require "./setup"
include Stylet

vector = Vector.new(3, 3)
vector.angle                    # => 
# ~> /usr/local/var/rbenv/versions/2.6.5/lib/ruby/site_ruby/2.6.0/rubygems/specification.rb:2236:in `raise_if_conflicts': Unable to activate activemodel-6.1.4.1, because activesupport-6.1.4.4 conflicts with activesupport (= 6.1.4.1) (Gem::ConflictError)
# ~> 	from /usr/local/var/rbenv/versions/2.6.5/lib/ruby/site_ruby/2.6.0/rubygems/specification.rb:1367:in `activate'
# ~> 	from /usr/local/var/rbenv/versions/2.6.5/lib/ruby/site_ruby/2.6.0/rubygems.rb:211:in `rescue in try_activate'
# ~> 	from /usr/local/var/rbenv/versions/2.6.5/lib/ruby/site_ruby/2.6.0/rubygems.rb:204:in `try_activate'
# ~> 	from /usr/local/var/rbenv/versions/2.6.5/lib/ruby/site_ruby/2.6.0/rubygems/core_ext/kernel_require.rb:153:in `rescue in require'
# ~> 	from /usr/local/var/rbenv/versions/2.6.5/lib/ruby/site_ruby/2.6.0/rubygems/core_ext/kernel_require.rb:149:in `require'
# ~> 	from /Users/ikeda/src/stylet/lib/stylet/callbacks.rb:2:in `<top (required)>'
# ~> 	from /Users/ikeda/src/stylet/lib/stylet/base.rb:31:in `require_relative'
# ~> 	from /Users/ikeda/src/stylet/lib/stylet/base.rb:31:in `<top (required)>'
# ~> 	from /Users/ikeda/src/stylet/lib/stylet/stylet.rb:2:in `require_relative'
# ~> 	from /Users/ikeda/src/stylet/lib/stylet/stylet.rb:2:in `<top (required)>'
# ~> 	from /usr/local/var/rbenv/versions/2.6.5/lib/ruby/site_ruby/2.6.0/rubygems/core_ext/kernel_require.rb:85:in `require'
# ~> 	from /usr/local/var/rbenv/versions/2.6.5/lib/ruby/site_ruby/2.6.0/rubygems/core_ext/kernel_require.rb:85:in `require'
# ~> 	from /Users/ikeda/src/stylet/lib/stylet.rb:1:in `<top (required)>'
# ~> 	from /usr/local/var/rbenv/versions/2.6.5/lib/ruby/site_ruby/2.6.0/rubygems/core_ext/kernel_require.rb:85:in `require'
# ~> 	from /usr/local/var/rbenv/versions/2.6.5/lib/ruby/site_ruby/2.6.0/rubygems/core_ext/kernel_require.rb:85:in `require'
# ~> 	from /Users/ikeda/src/stylet/examples/setup.rb:2:in `<top (required)>'
# ~> 	from /usr/local/var/rbenv/versions/2.6.5/lib/ruby/site_ruby/2.6.0/rubygems/core_ext/kernel_require.rb:85:in `require'
# ~> 	from /usr/local/var/rbenv/versions/2.6.5/lib/ruby/site_ruby/2.6.0/rubygems/core_ext/kernel_require.rb:85:in `require'
# ~> 	from -:1:in `<main>'
# ~> /usr/local/var/rbenv/versions/2.6.5/lib/ruby/site_ruby/2.6.0/rubygems/specification.rb:2236:in `raise_if_conflicts': Unable to activate activemodel-6.1.4.1, because activesupport-6.1.4.4 conflicts with activesupport (= 6.1.4.1) (Gem::ConflictError)
# ~> 	from /usr/local/var/rbenv/versions/2.6.5/lib/ruby/site_ruby/2.6.0/rubygems/specification.rb:1367:in `activate'
# ~> 	from /usr/local/var/rbenv/versions/2.6.5/lib/ruby/site_ruby/2.6.0/rubygems.rb:205:in `try_activate'
# ~> 	from /usr/local/var/rbenv/versions/2.6.5/lib/ruby/site_ruby/2.6.0/rubygems/core_ext/kernel_require.rb:153:in `rescue in require'
# ~> 	from /usr/local/var/rbenv/versions/2.6.5/lib/ruby/site_ruby/2.6.0/rubygems/core_ext/kernel_require.rb:149:in `require'
# ~> 	from /Users/ikeda/src/stylet/lib/stylet/callbacks.rb:2:in `<top (required)>'
# ~> 	from /Users/ikeda/src/stylet/lib/stylet/base.rb:31:in `require_relative'
# ~> 	from /Users/ikeda/src/stylet/lib/stylet/base.rb:31:in `<top (required)>'
# ~> 	from /Users/ikeda/src/stylet/lib/stylet/stylet.rb:2:in `require_relative'
# ~> 	from /Users/ikeda/src/stylet/lib/stylet/stylet.rb:2:in `<top (required)>'
# ~> 	from /usr/local/var/rbenv/versions/2.6.5/lib/ruby/site_ruby/2.6.0/rubygems/core_ext/kernel_require.rb:85:in `require'
# ~> 	from /usr/local/var/rbenv/versions/2.6.5/lib/ruby/site_ruby/2.6.0/rubygems/core_ext/kernel_require.rb:85:in `require'
# ~> 	from /Users/ikeda/src/stylet/lib/stylet.rb:1:in `<top (required)>'
# ~> 	from /usr/local/var/rbenv/versions/2.6.5/lib/ruby/site_ruby/2.6.0/rubygems/core_ext/kernel_require.rb:85:in `require'
# ~> 	from /usr/local/var/rbenv/versions/2.6.5/lib/ruby/site_ruby/2.6.0/rubygems/core_ext/kernel_require.rb:85:in `require'
# ~> 	from /Users/ikeda/src/stylet/examples/setup.rb:2:in `<top (required)>'
# ~> 	from /usr/local/var/rbenv/versions/2.6.5/lib/ruby/site_ruby/2.6.0/rubygems/core_ext/kernel_require.rb:85:in `require'
# ~> 	from /usr/local/var/rbenv/versions/2.6.5/lib/ruby/site_ruby/2.6.0/rubygems/core_ext/kernel_require.rb:85:in `require'
# ~> 	from -:1:in `<main>'
# ~> /usr/local/var/rbenv/versions/2.6.5/lib/ruby/site_ruby/2.6.0/rubygems/core_ext/kernel_require.rb:148:in `require': cannot load such file -- active_model/callbacks (LoadError)
# ~> 	from /usr/local/var/rbenv/versions/2.6.5/lib/ruby/site_ruby/2.6.0/rubygems/core_ext/kernel_require.rb:148:in `require'
# ~> 	from /Users/ikeda/src/stylet/lib/stylet/callbacks.rb:2:in `<top (required)>'
# ~> 	from /Users/ikeda/src/stylet/lib/stylet/base.rb:31:in `require_relative'
# ~> 	from /Users/ikeda/src/stylet/lib/stylet/base.rb:31:in `<top (required)>'
# ~> 	from /Users/ikeda/src/stylet/lib/stylet/stylet.rb:2:in `require_relative'
# ~> 	from /Users/ikeda/src/stylet/lib/stylet/stylet.rb:2:in `<top (required)>'
# ~> 	from /usr/local/var/rbenv/versions/2.6.5/lib/ruby/site_ruby/2.6.0/rubygems/core_ext/kernel_require.rb:85:in `require'
# ~> 	from /usr/local/var/rbenv/versions/2.6.5/lib/ruby/site_ruby/2.6.0/rubygems/core_ext/kernel_require.rb:85:in `require'
# ~> 	from /Users/ikeda/src/stylet/lib/stylet.rb:1:in `<top (required)>'
# ~> 	from /usr/local/var/rbenv/versions/2.6.5/lib/ruby/site_ruby/2.6.0/rubygems/core_ext/kernel_require.rb:85:in `require'
# ~> 	from /usr/local/var/rbenv/versions/2.6.5/lib/ruby/site_ruby/2.6.0/rubygems/core_ext/kernel_require.rb:85:in `require'
# ~> 	from /Users/ikeda/src/stylet/examples/setup.rb:2:in `<top (required)>'
# ~> 	from /usr/local/var/rbenv/versions/2.6.5/lib/ruby/site_ruby/2.6.0/rubygems/core_ext/kernel_require.rb:85:in `require'
# ~> 	from /usr/local/var/rbenv/versions/2.6.5/lib/ruby/site_ruby/2.6.0/rubygems/core_ext/kernel_require.rb:85:in `require'
# ~> 	from -:1:in `<main>'
