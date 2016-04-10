require "./setup"

class App < Stylet::Base
end

App.run(:title => "すべて同じオブジェクト") do
  vputs object_id
  vputs Stylet.context.object_id
  vputs Stylet::Base.active_frame.object_id
end
