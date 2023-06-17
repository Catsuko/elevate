require 'wisper_next'

module Elevate
  class Elevator
    include WisperNext.publisher

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

      signal = @on_signals.fetch(floor, 0) + (direction == :up ? 1 : -1)
      @on_signals.store(floor, signal.clamp(-1, 1))
    end

    def select_destination(floor)
      ensure_floor_in_bounds!(floor)

      @off_signals.add(floor)
    end

    def stopping_at?(floor)
      @off_signals.include?(floor)
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
      broadcast(:elevator_arrived, elevator: self, floor: @current_floor,
                                   direction: floor_delta.positive? ? :up : :down)
    end

    def add(person)
      raise 'Elevator is full!' if @passengers.size >= @capacity

      @passengers.add(person)
    end

    def remove(person)
      @passengers.delete(person)
    end

    private

    def target_floor
      @floors.max
    end

    def ensure_floor_in_bounds!(floor)
      raise ArgumentError, "cannot travel to floor `#{floor}`" unless @floors.include?(floor)
    end
  end
end
