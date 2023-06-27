require 'wisper_next'

module Elevate
  module Events
    class Logger
      include WisperNext.subscriber prefix: true

      def on_person_got_on(payload)
        puts "  #{payload.fetch(:person)} got on"
      end

      def on_person_got_off(payload)
        puts "  #{payload.fetch(:person)} got off"
      end

      def on_elevator_stopped(payload)
        puts "\n#{payload.fetch(:elevator)} stopped at #{payload.fetch(:floor).number}F"
      end

      def on_completed(turns)
        puts "\nTook #{turns} turns"
      end
    end
  end
end
