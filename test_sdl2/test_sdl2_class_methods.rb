require "./setup"
SDL2.base_path                               # => "/usr/local/var/rbenv/versions/2.6.5/bin/"
SDL2.current_video_driver                    # => nil
SDL2.preference_path("org_name", "app_name") # => "/Users/ikeda/Library/Application Support/org_name/app_name/"
SDL2.video_drivers                           # => ["cocoa", "dummy"]
SDL2.video_init("cocoa")                     # => nil
