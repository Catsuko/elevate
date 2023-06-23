module Elevate
  module Router
    class PingPong
      def initialize(going_up: true)
        @going_up = going_up
      end

      def call(_elevator, floors:, current_floor:)
        i = floors.index(current_floor)

        @going_up = if @going_up
                      i < floors.size - 1
                    else
                      i <= 0
                    end

        floors[i + (@going_up ? 1 : -1)]
      end
    end
  end
end
