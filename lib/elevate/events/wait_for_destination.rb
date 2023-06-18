require 'wisper_next'

module Elevate
  module Events
    class WaitForDestination
      include WisperNext.subscriber prefix: true

      def initialize(person)
        @person = person
      end

      def on_elevator_arrived(payload)
        return unless @person.wants_to_get_off?(payload.fetch(:floor))

        elevator = payload.fetch(:elevator)
        elevator.unsubscribe(self)
        @person.get_off(elevator)
      end
    end
  end
end
