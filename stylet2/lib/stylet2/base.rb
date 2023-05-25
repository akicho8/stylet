module Stylet2
  class Base
    include Math

    class << self
      def run(...)
        new(...).run
      end
    end

    attr_accessor :params

    def initialize(params = {}, &block)
      @params = Stylet2.config.to_h.merge(params)

      if block_given?
        yield self
      end
    end

    def run
      setup
      loop { process_once }
      teardown
    end

    def process_once
      before_process
      event_loop
      update
      before_view
      view
      after_view
      after_process
    end

    private

    def setup
      SDL2.init(SDL2::INIT_EVERYTHING)
    end

    def teardown
    end

    def before_process
    end

    def update
    end

    def before_view
    end

    def view
    end

    def after_view
    end

    def after_process
    end

    def event_loop
      while ev = SDL2::Event.poll
        event_handle(ev)
      end
    end

    def event_handle(ev)
      case ev
      when SDL2::Event::Quit
        exit
      when SDL2::Event::KeyDown
        case ev.scancode
        when SDL2::Key::Scan::ESCAPE
          exit
        when SDL2::Key::Scan::Q
          exit
        end
      end
    end
  end
end
