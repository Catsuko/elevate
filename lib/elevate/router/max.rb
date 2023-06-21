module Elevate
  module Router
    class Max
      def call(_elevator, floors:, **_options)
        floors.max
      end
    end
  end
end
