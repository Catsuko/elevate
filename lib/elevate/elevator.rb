require 'wisper_next'
require_relative 'router/ping_pong'

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

    def initialize(floors, capacity:, current_floor:, stops: Set.new, router: Router::PingPong.new)
      @floors = floors
      ensure_floor_in_bounds!(current_floor)

      @current_floor = current_floor
      @capacity = capacity
      @passengers = Set.new
      @stops = stops
      @router = router
    end

    def select_destination(floor)
      ensure_floor_in_bounds!(floor)
      return if floor == @current_floor

      @stops.add(floor)
    end

    # TODO: Rename this method to focus on what the passenger wants rather than what the elevator will do
    def stopping_at?(floor)
      @stops.include?(floor)
    end

    def contains?(person)
      @passengers.include?(person)
    end

    # TODO: Refactor router out of elevator, change #update to #move_to(floor)
    def update
      target = target_floor
      floor_delta = target <=> @current_floor
      floor_index = @floors.index(@current_floor) + floor_delta

      if floor_delta.zero?
        direction = :idle
      else
        @current_floor = @floors[floor_index]
        direction = floor_delta.positive? == (floor_index <= 0 || floor_index >= @floors.size - 1) ? :down : :up
      end

      open_doors(target, direction: direction) if at?(target)
    end

    # TODO: Remove #select_destination and add destination as an argument here
    def add(person)
      passengers = Set[person] + @passengers
      raise FullCapacityError, @capacity if passengers.size > @capacity

      @passengers = passengers
    end

    def remove(person)
      @passengers.delete(person)
    end

    def broadcast_stop(floor, direction:)
      broadcast(:elevator_stopped, elevator: self, floor: floor, direction: direction)
    end

    def at?(floor)
      @current_floor == floor
    end

    def to_s
      "Elevator [#{@passengers.map(&:name).join('|')}]"
    end

    private

    def open_doors(floor, direction:)
      @stops.delete(floor)
      broadcast_stop(floor, direction: direction)
      floor.broadcast_stop(self, direction: direction)
    end

    def target_floor
      @router.call(self, current_floor: @current_floor, floors: @floors)
    end

    def ensure_floor_in_bounds!(floor)
      raise OutOfBoundsError, floor unless @floors.include?(floor)
    end
  end
end
