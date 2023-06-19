require_relative 'events/wait_for_destination'
require_relative 'events/wait_to_get_on'

module Elevate
  class Person
    def initialize(destination)
      @destination = destination
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
    end

    def get_off(elevator)
      elevator.remove(self)
    end

    def wants_to_get_off?(floor)
      floor == @destination
    end
  end
end
