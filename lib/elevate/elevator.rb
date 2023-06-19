require 'wisper_next'
require_relative 'signals'

module Elevate
  class Elevator
    include WisperNext.publisher

    OutOfBoundsError = Class.new(StandardError) do
      def initialize(floor)
        super("Floor #{floor.to_i} is out of bounds.")
      end
    end

    FullCapacityError = Class.new(StandardError) do
      def initialize(capacity)
        super("Elevator is at full capacity: #{capacity}/#{capacity}")
      end
    end

    # TODO: Refactor many instance variables into some cohesive components
    def initialize(floors, current_floor:, capacity:, signals: Signals.new)
      @floors = floors
      ensure_floor_in_bounds!(current_floor)

      @current_floor = current_floor
      @capacity = capacity
      @passengers = Set.new
      @signals = signals
    end

    def select_destination(floor)
      ensure_floor_in_bounds!(floor)
      return if floor == @current_floor

      @signals.exit_at(floor)
    end

    def stopping_at?(floor)
      @signals.set?(floor)
    end

    def contains?(person)
      @passengers.include?(person)
    end

    def update
      floor_delta = target_floor <=> @current_floor
      return if floor_delta.zero?

      @current_floor += floor_delta
      @signals.clear_on(@current_floor)
      direction = floor_delta.positive? ? :up : :down
      broadcast_stop(@current_floor, direction: direction)
      @current_floor.broadcast_stop(self, direction: direction)
    end

    def add(person)
      passengers = Set[person] + @passengers
      raise FullCapacityError, @capacity if passengers.size > @capacity

      @passengers = passengers
    end

    def remove(person)
      @passengers.delete(person)
    end

    def broadcast_stop(floor, travel_direction:)
      broadcast(:elevator_stopped, elevator: self, floor: floor, direction: travel_direction)
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
