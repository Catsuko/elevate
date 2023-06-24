require 'wisper_next'

module Elevate
  module Events
    class SimulationProgress
      include WisperNext.subscriber prefix: true

      def initialize(goal:, completed: 0)
        @goal = goal
        @completed = completed
      end

      def completed?
        @completed >= @goal
      end

      def on_person_got_on(_payload); end

      def on_person_got_off(_payload)
        @completed += 1
      end
    end
  end
end
