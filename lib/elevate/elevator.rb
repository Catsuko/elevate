require 'wisper_next'

module Elevate
  class Elevator
    include WisperNext.publisher

    OutOfBoundsError = Class.new(StandardError) do
      def initialize(floor)
        super("Floor #{floor} is out of bounds.")
      end
    end

    FullCapacityError = Class.new(StandardError) do
      def initialize(capacity)
        super("Elevator is at full capacity: #{capacity}/#{capacity}")
      end
    end

    # TODO: Refactor many instance variables into some cohesive components
    def initialize(floors, current_floor:, capacity:)
      @floors = floors
      ensure_floor_in_bounds!(current_floor)

      @current_floor = current_floor
      @capacity = capacity
      @passengers = Set.new
      @on_signals = {}
      @off_signals = Set.new
    end

    def call_to(floor, direction:)
      ensure_floor_in_bounds!(floor)
      return if floor == @current_floor

      signal = @on_signals.fetch(floor, 0) + (direction == :up ? 1 : -1)
      @on_signals.store(floor, signal.clamp(-1, 1))
    end

    def select_destination(floor)
      ensure_floor_in_bounds!(floor)
      return if floor == @current_floor

      @off_signals.add(floor)
    end

    def stopping_at?(floor)
      @off_signals.include?(floor) || @on_signals.key?(floor)
    end

    def contains?(person)
      @passengers.include?(person)
    end

    def update
      floor_delta = target_floor <=> @current_floor
      return if floor_delta.zero?

      @current_floor = current_floor + floor_delta
      @on_signals.delete(@current_floor)
      @off_signals.delete(@current_floor)
      broadcast_arrival(@current_floor, direction: floor_delta.positive? ? :up : :down)
    end

    def add(person)
      passengers = Set[person] + @passengers
      raise FullCapacityError, @capacity if passengers.size > @capacity

      @passengers = passengers
    end

    def remove(person)
      @passengers.delete(person)
    end

    def broadcast_arrival(floor, travel_direction:)
      broadcast(:elevator_arrived, elevator: self, floor: floor, direction: travel_direction)
    end

    private

    def target_floor
      @floors.max
    end

    def ensure_floor_in_bounds!(floor)
      raise OutOfBoundsError, floor unless @floors.include?(floor)
    end
  end
end
