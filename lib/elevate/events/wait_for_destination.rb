require 'wisper_next'

module Elevate
  module Events
    class WaitForDestination
      include WisperNext.subscriber

      def initialize(person)
        @person = person
      end

      def on_elevator_arrived(elevator:, floor:)
        return unless @person.wants_to_get_off?(floor)

        elevator.unsubscribe(self)
        @person.get_off(elevator)
      end
    end
  end
end
