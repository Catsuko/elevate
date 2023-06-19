require 'wisper_next'

module Elevate
  module Events
    class WaitToGetOn
      include WisperNext.subscriber prefix: true

      def initialize(person, floor:, direction:)
        @person = person
        @floor = floor
        @direction = direction
      end

      def on_elevator_stopped(payload)
        return unless @floor == payload.fetch(:floor) && @direction == payload.fetch(:direction)

        elevator = payload.fetch(:elevator)
        @person.get_on(elevator)
        @floor.unsubscribe(self)
      rescue Elevator::FullCapacityError
        # Elevator is full, wait for the next one :(
      end
    end
  end
end
