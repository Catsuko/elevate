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
        return unless @floor == payload.fetch(:floor) && going_to_destination?(payload.fetch(:direction))

        elevator = payload.fetch(:elevator)
        @person.get_on(elevator)
        @floor.unsubscribe(self)
      rescue Elevator::FullCapacityError
        # Elevator is full, wait for the next one :(
      end

      private

      def going_to_destination?(direction)
        [@direction, :idle].include?(direction)
      end
    end
  end
end
