require 'elevate/person'
require 'elevate/elevator'
require 'elevate/floor'

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
    it 'moves one floor towards the target floor' do
      skip('not implemented')
    end

    it 'does not stop' do
      skip('not implemented')
    end

    context 'when the next floor is the target floor' do
      it 'moves to the target floor' do
        skip('not implemented')
      end

      it 'stops' do
        skip('not implemented')
      end
    end
  end
end
