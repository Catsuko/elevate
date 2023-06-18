module Elevate
  class Signals
    def initialize(for_entry: {}, for_exit: Set.new)
      @for_entry = for_entry
      @for_exit = for_exit
    end

    def enter_at(floor, direction:)
      signal = @for_entry.fetch(floor, 0) + (direction == :up ? 1 : -1)
      @for_entry.store(floor, signal.clamp(-1, 1))
    end

    def exit_at(floor)
      @for_exit.add(floor)
    end

    def set?(floor)
      @for_entry.key?(floor) || @for_exit.include?(floor)
    end

    def clear_on(floor)
      @for_entry.delete(floor)
      @for_exit.delete(floor)
    end
  end
end
