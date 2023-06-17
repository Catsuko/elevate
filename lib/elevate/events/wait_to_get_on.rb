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

      # TODO: Having events for a person being triggered for floors they are not on feels weird to me.
      #       Can it be refactored so they are only exposed to events that take place in their local area?
      def on_elevator_arrived(elevator:, floor:, direction:)
        return unless @floor == floor && @direction == direction

        elevator.unsubscribe(self)
        @person.get_on(elevator)
      end
    end
  end
end
