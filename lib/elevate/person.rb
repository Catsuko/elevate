require 'wisper_next'
require_relative 'events/wait_for_destination'
require_relative 'events/wait_to_get_on'

module Elevate
  class Person
    include WisperNext.publisher

    def initialize(destination, name: nil)
      @destination = destination
      @name = name
    end

    def wait_for_elevator(on:)
      direction = on < @destination ? :up : :down
      on.call_elevator(direction)
      on.subscribe(Events::WaitToGetOn.new(self, floor: on, direction: direction))
    end

    def get_on(elevator)
      elevator.add(self)
      elevator.select_destination(@destination)
      elevator.subscribe(Events::WaitForDestination.new(self))
      broadcast(:person_got_on, person: self)
    end

    def get_off(elevator)
      elevator.remove(self)
      broadcast(:person_got_off, person: self, floor: @destination)
      unsubscribe_all
    end

    def wants_to_get_off?(floor)
      floor == @destination
    end

    def to_s
      "Person #{@name}".strip
    end

    def name
      @name
    end
  end
end
