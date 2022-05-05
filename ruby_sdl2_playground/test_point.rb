require "./setup"

point = SDL2::Point.new(1, 2)   # => 
point.x                         # => 
point.y                         # => 
# ~> /usr/local/var/rbenv/versions/3.1.0/lib/ruby/gems/3.1.0/gems/activesupport-7.0.2.4/lib/active_support/xml_mini.rb:184:in `current_thread_backend': uninitialized constant ActiveSupport::XmlMini::IsolatedExecutionState (NameError)
# ~> 
# ~>         IsolatedExecutionState[:xml_mini_backend]
# ~>         ^^^^^^^^^^^^^^^^^^^^^^
# ~> 	from /usr/local/var/rbenv/versions/3.1.0/lib/ruby/gems/3.1.0/gems/activesupport-7.0.2.4/lib/active_support/xml_mini.rb:103:in `backend='
# ~> 	from /usr/local/var/rbenv/versions/3.1.0/lib/ruby/gems/3.1.0/gems/activesupport-7.0.2.4/lib/active_support/xml_mini.rb:201:in `<module:ActiveSupport>'
# ~> 	from /usr/local/var/rbenv/versions/3.1.0/lib/ruby/gems/3.1.0/gems/activesupport-7.0.2.4/lib/active_support/xml_mini.rb:11:in `<top (required)>'
# ~> 	from /usr/local/var/rbenv/versions/3.1.0/lib/ruby/gems/3.1.0/gems/activesupport-7.0.2.4/lib/active_support/core_ext/array/conversions.rb:3:in `require'
# ~> 	from /usr/local/var/rbenv/versions/3.1.0/lib/ruby/gems/3.1.0/gems/activesupport-7.0.2.4/lib/active_support/core_ext/array/conversions.rb:3:in `<top (required)>'
# ~> 	from /usr/local/var/rbenv/versions/3.1.0/lib/ruby/gems/3.1.0/gems/activesupport-7.0.2.4/lib/active_support/duration.rb:3:in `require'
# ~> 	from /usr/local/var/rbenv/versions/3.1.0/lib/ruby/gems/3.1.0/gems/activesupport-7.0.2.4/lib/active_support/duration.rb:3:in `<top (required)>'
# ~> 	from /usr/local/var/rbenv/versions/3.1.0/lib/ruby/gems/3.1.0/gems/activesupport-7.0.2.4/lib/active_support/core_ext/time/calculations.rb:3:in `require'
# ~> 	from /usr/local/var/rbenv/versions/3.1.0/lib/ruby/gems/3.1.0/gems/activesupport-7.0.2.4/lib/active_support/core_ext/time/calculations.rb:3:in `<top (required)>'
# ~> 	from /usr/local/var/rbenv/versions/3.1.0/lib/ruby/gems/3.1.0/gems/activesupport-7.0.2.4/lib/active_support/core_ext/string/conversions.rb:4:in `require'
# ~> 	from /usr/local/var/rbenv/versions/3.1.0/lib/ruby/gems/3.1.0/gems/activesupport-7.0.2.4/lib/active_support/core_ext/string/conversions.rb:4:in `<top (required)>'
# ~> 	from /usr/local/var/rbenv/versions/3.1.0/lib/ruby/gems/3.1.0/gems/activesupport-7.0.2.4/lib/active_support/core_ext/string.rb:3:in `require'
# ~> 	from /usr/local/var/rbenv/versions/3.1.0/lib/ruby/gems/3.1.0/gems/activesupport-7.0.2.4/lib/active_support/core_ext/string.rb:3:in `<top (required)>'
# ~> 	from /usr/local/var/rbenv/versions/3.1.0/lib/ruby/gems/3.1.0/gems/table_format-0.0.10/lib/table_format/generator.rb:2:in `require'
# ~> 	from /usr/local/var/rbenv/versions/3.1.0/lib/ruby/gems/3.1.0/gems/table_format-0.0.10/lib/table_format/generator.rb:2:in `<top (required)>'
# ~> 	from /usr/local/var/rbenv/versions/3.1.0/lib/ruby/gems/3.1.0/gems/table_format-0.0.10/lib/table_format.rb:2:in `require'
# ~> 	from /usr/local/var/rbenv/versions/3.1.0/lib/ruby/gems/3.1.0/gems/table_format-0.0.10/lib/table_format.rb:2:in `<top (required)>'
# ~> 	from /usr/local/var/rbenv/versions/3.1.0/lib/ruby/gems/3.1.0/gems/bundler-2.3.12/lib/bundler/runtime.rb:60:in `require'
# ~> 	from /usr/local/var/rbenv/versions/3.1.0/lib/ruby/gems/3.1.0/gems/bundler-2.3.12/lib/bundler/runtime.rb:60:in `block (2 levels) in require'
# ~> 	from /usr/local/var/rbenv/versions/3.1.0/lib/ruby/gems/3.1.0/gems/bundler-2.3.12/lib/bundler/runtime.rb:55:in `each'
# ~> 	from /usr/local/var/rbenv/versions/3.1.0/lib/ruby/gems/3.1.0/gems/bundler-2.3.12/lib/bundler/runtime.rb:55:in `block in require'
# ~> 	from /usr/local/var/rbenv/versions/3.1.0/lib/ruby/gems/3.1.0/gems/bundler-2.3.12/lib/bundler/runtime.rb:44:in `each'
# ~> 	from /usr/local/var/rbenv/versions/3.1.0/lib/ruby/gems/3.1.0/gems/bundler-2.3.12/lib/bundler/runtime.rb:44:in `require'
# ~> 	from /usr/local/var/rbenv/versions/3.1.0/lib/ruby/gems/3.1.0/gems/bundler-2.3.12/lib/bundler.rb:176:in `require'
# ~> 	from /Users/ikeda/src/stylet/ruby_sdl2_playground/setup.rb:2:in `<top (required)>'
# ~> 	from <internal:/usr/local/var/rbenv/versions/3.1.0/lib/ruby/3.1.0/rubygems/core_ext/kernel_require.rb>:85:in `require'
# ~> 	from <internal:/usr/local/var/rbenv/versions/3.1.0/lib/ruby/3.1.0/rubygems/core_ext/kernel_require.rb>:85:in `require'
# ~> 	from -:1:in `<main>'
