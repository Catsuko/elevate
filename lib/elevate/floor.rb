require 'wisper_next'

module Elevate
  class Floor
    include WisperNext.publisher
    include Comparable

    attr_reader :number

    def initialize(number, up_signal: false, down_signal: false)
      @number = number
      @up_signal = up_signal
      @down_signal = down_signal
    end

    def to_i
      number
    end

    def eql?(other)
      other.class == self.class && other.hash == hash
    end

    def ==(other)
      eql?(other)
    end

    def hash
      number.hash
    end

    def <=>(other)
      number <=> other.number
    end

    def call_elevator(direction)
      set_signal(true, direction: direction)
    end

    def calling?(direction)
      direction == :up ? @up_signal : @down_signal
    end

    def broadcast_stop(elevator, travel_direction:)
      set_signal(false, direction: travel_direction)
      broadcast(:elevator_stopped, elevator: elevator, floor: self, direction: travel_direction)
    end

    private

    def set_signal(on, direction:)
      if direction == :up
        @up_signal = on
      else
        @down_signal = on
      end
    end
  end
end
