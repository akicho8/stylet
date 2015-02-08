# -*- coding: utf-8 -*-
require "./setup"
require "stackprof"

StackProf.run(mode: :cpu, out: "/tmp/stackprof-cpu-myapp.dump") do
  Stylet.run do
    vputs frame_counter
  end
end

# stackprof /tmp/stackprof-cpu-myapp.dump
