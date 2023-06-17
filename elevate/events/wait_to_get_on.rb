require 'wisper_next'

module Elevate
  module Events
    class WaitToGetOn
      include WisperNext.subscriber

      def initialize(person, floor:, direction:)
        @person = person
        @floor = floor
        @direction = direction
      end

      def on_elevator_arrived(elevator:, floor:, direction:)
        return unless @floor == floor && @direction == direction

        elevator.unsubscribe(self)
        @person.get_on(elevator)
      end
    end
  end
end
