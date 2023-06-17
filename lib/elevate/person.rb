require_relative 'events/wait_for_destination'
require_relative 'events/wait_to_get_on'

module Elevate
  class Person
    def initialize(destination_floor)
      @destination_floor = destination_floor
    end

    def wait_for(elevator, from_floor:)
      elevator.call_to(from)
      direction = from_floor < @destination_floor ? :up : :down
      elevator.subscribe(Events::WaitToGetOn.new(self, floor: from_floor, direction: direction))
    end

    def get_on(elevator)
      elevator.add(self)
      elevator.select_destination(@destination_floor)
      elevator.subscribe(Events::WaitForDestination.new(self))
    end

    def get_off(elevator)
      elevator.remove(self)
    end

    def wants_to_get_off?(floor)
      floor == @destination_floor
    end
  end
end
