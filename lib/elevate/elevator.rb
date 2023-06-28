require 'wisper_next'

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

    IdiotError = Class.new(StandardError) do
      def initialize
        super('🤦')
      end
    end

    def initialize(floors, capacity:, current_floor:, stops: Set.new)
      @floors = floors
      ensure_floor_in_bounds!(current_floor)

      @current_floor = current_floor
      @capacity = capacity
      @passengers = Set.new
      @stops = stops
    end

    def passenger_going_to?(floor)
      @stops.include?(floor)
    end

    def passenger?(person)
      @passengers.include?(person)
    end

    def move(driven_by:)
      move_to(driven_by.call(self, floors: @floors, current_floor: @current_floor))
    end

    def move_to(floor)
      floor_delta = floor <=> @current_floor
      floor_index = @floors.index(@current_floor) + floor_delta

      if floor_delta.zero?
        direction = :idle
      else
        @current_floor = @floors[floor_index]
        direction = floor_delta.positive? == (floor_index <= 0 || floor_index >= @floors.size - 1) ? :down : :up
      end

      open_doors(floor, direction: direction) if at?(floor)
    end

    def add(person, destination:)
      raise IdiotError if destination == @current_floor

      ensure_floor_in_bounds!(destination)
      passengers = Set[person] + @passengers
      raise FullCapacityError, @capacity if passengers.size > @capacity

      @passengers = passengers
      @stops.add(destination)
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

    def ensure_floor_in_bounds!(floor)
      raise OutOfBoundsError, floor unless @floors.include?(floor)
    end
  end
end
