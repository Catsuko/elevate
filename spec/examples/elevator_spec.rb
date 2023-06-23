require 'elevate/person'
require 'elevate/elevator'
require 'elevate/floor'
require 'elevate/router/max'

RSpec.describe Elevate::Elevator do
  let(:floors) { 5.times.map { |n| Elevate::Floor.new(n + 1) } }
  let(:current_floor) { floors.min }
  let(:elevator) { Elevate::Elevator.new(floors, current_floor: current_floor, capacity: 1) }

  describe '#select_destination' do
    it 'cannot select a floor that is out of bounds' do
      [-1, 0, 999].map { |n| Elevate::Floor.new(n) }.each do |floor|
        expect { elevator.select_destination(floor) }.to raise_error(described_class::OutOfBoundsError)
      end
    end

    it 'signals to make a stop at the floor' do
      floor = floors.max
      expect { elevator.select_destination(floor) }.to change { elevator.stopping_at?(floor) }.from(false).to(true)
    end

    it 'does not signal to make a stop if on the current floor' do
      expect do
        elevator.select_destination(current_floor)
      end.not_to change { elevator.stopping_at?(current_floor) }.from(false)
    end
  end

  describe '#add' do
    let(:person) { Elevate::Person.new(floors[1]) }

    it 'adds the person to the elevator' do
      expect { elevator.add(person) }.to change { elevator.contains?(person) }.from(false).to(true)
    end

    it 'cannot add people beyond the capacity of the elevator' do
      elevator.add(Elevate::Person.new(floors[2]))
      expect { elevator.add(person) }.to raise_error(described_class::FullCapacityError)
    end

    it 'adding the same person multiple times has no effect' do
      elevator.add(person)
      expect { elevator.add(person) }.not_to raise_error
    end
  end

  describe '#remove' do
    let(:person) { Elevate::Person.new(floors[1]) }

    it 'removes the person from the elevator' do
      elevator.add(person)
      expect { elevator.remove(person) }.to change { elevator.contains?(person) }.from(true).to(false)
    end

    it 'has no effect if the person is not in the elevator' do
      expect { elevator.remove(person) }.not_to raise_error
    end
  end

  describe '#update' do
    subject { elevator.update }

    context 'when the top floor is the target floor' do
      let(:elevator) do
        Elevate::Elevator.new(floors, current_floor: current_floor, capacity: 1, router: Elevate::Router::Max.new)
      end

      it 'moves one floor up' do
        expect { subject }.to change { elevator.at?(floors[1]) }.from(false).to(true)
      end

      it 'does not stop' do
        expect do |b|
          elevator.on(:elevator_stopped, &b)
          subject
        end.not_to yield_control
      end
    end

    context 'when the next stop is the top floor' do
      let(:elevator) do
        Elevate::Elevator.new(floors, current_floor: floors[-2], capacity: 1)
      end

      it 'stops and reverses direction' do
        expect do |b|
          elevator.on(:elevator_stopped, &b)
          subject
        end.to yield_with_args(hash_including(floor: floors[-1], direction: :down))
      end
    end

    context 'when the next stop is the first floor' do
      let(:elevator) do
        router = Elevate::Router::PingPong.new(going_up: false)
        Elevate::Elevator.new(floors, current_floor: floors[1], capacity: 1, router: router)
      end

      it 'stops and reverses direction' do
        expect do |b|
          elevator.on(:elevator_stopped, &b)
          subject
        end.to yield_with_args(hash_including(floor: floors[0], direction: :up))
      end
    end

    context 'when the next floor is the target floor' do
      it 'moves one floor up' do
        expect { subject }.to change { elevator.at?(floors[1]) }.from(false).to(true)
      end

      it 'stops' do
        expect do |b|
          elevator.on(:elevator_stopped, &b)
          subject
        end.to yield_with_args(hash_including(floor: floors[1], elevator: elevator, direction: :up))
      end

      it 'broadcasts stop on the floor' do
        expect do |b|
          floors[1].on(:elevator_stopped, &b)
          subject
        end.to yield_with_args(hash_including(floor: floors[1], elevator: elevator, direction: :up))
      end

      it 'removes floor as a destination' do
        elevator.select_destination(floors[1])
        expect { subject }.to change { elevator.stopping_at?(floors[1]) }.from(true).to(false)
      end
    end
  end
end
