module Elevate
  class Signals
    def initialize(for_entry: {}, for_exit: Set.new)
      @for_entry = for_entry
      @for_exit = for_exit
    end

    def enter_at(floor, direction:)
      signal = @for_entry.fetch(floor.to_i, 0) + (direction == :up ? 1 : -1)
      @for_entry.store(floor.to_i, signal.clamp(-1, 1))
    end

    def exit_at(floor)
      @for_exit.add(floor.to_i)
    end

    def set?(floor)
      @for_entry.key?(floor.to_i) || @for_exit.include?(floor.to_i)
    end

    def clear_on(floor)
      @for_entry.delete(floor.to_i)
      @for_exit.delete(floor.to_i)
    end
  end
end
