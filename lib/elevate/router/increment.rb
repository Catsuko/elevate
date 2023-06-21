module Elevate
  module Router
    class Increment
      def call(_elevator, current_floor:, floors:)
        floors.lazy
              .each_cons(2)
              .select { |floor, _next_floor| floor == current_floor }
              .map { |_floor, next_floor| next_floor }
              .first || current_floor
      end
    end
  end
end
