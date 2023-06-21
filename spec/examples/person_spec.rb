require 'elevate/person'
require 'elevate/elevator'
require 'elevate/floor'

RSpec.describe Elevate::Person do
  let(:floors) { 3.times.map { |n| Elevate::Floor.new(n + 1) } }
  let(:destination) { floors.max }
  let(:elevator) { Elevate::Elevator.new(floors, current_floor: floors.min, capacity: 1) }
  let(:person) { described_class.new(destination) }

  describe '#wants_to_get_off?' do
    it 'wants to get off when at their destination' do
      expect(person.wants_to_get_off?(destination)).to eq true
    end

    it 'does not want to get off on other floors' do
      10.times do |n|
        expect(person.wants_to_get_off?(n)).to eq false
      end
    end
  end

  describe '#get_on' do
    subject { person.get_on(elevator) }

    it 'enters the elevator' do
      expect { subject }.to change { elevator.contains?(person) }.from(false).to(true)
    end

    it 'adds stop at their destination' do
      expect { subject }.to change { elevator.stopping_at?(destination) }.from(false).to(true)
    end

    it 'stays on the elevator as it stops at other floors' do
      subject
      expect do
        elevator.broadcast_stop(floors[1], direction: :up)
      end.not_to change { elevator.contains?(person) }.from(true)
    end

    it 'gets off when the elevator reaches their destination' do
      subject
      expect do
        elevator.broadcast_stop(destination, direction: :up)
      end.to change { elevator.contains?(person) }.from(true).to(false)
    end
  end

  describe '#get_off' do
    subject { person.get_off(elevator) }

    before { person.get_on(elevator) }

    it 'leaves the elevator' do
      expect { subject }.to change { elevator.contains?(person) }.from(true).to(false)
    end
  end

  describe '#wait_for_elevator' do
    let(:from_floor) { floors[1] }
    subject { person.wait_for_elevator(on: from_floor) }

    it 'calls the elevator to their floor' do
      expect { subject }.to change { from_floor.calling?(:up) }.from(false).to(true)
    end

    context 'when the elevator reaches their floor' do
      it 'enters when it is travelling in their direction' do
        subject
        expect do
          from_floor.broadcast_stop(elevator, direction: :up)
        end.to change { elevator.contains?(person) }.from(false).to(true)
      end

      it 'does not enter when it is travelling in the other direction' do
        subject
        expect do
          from_floor.broadcast_stop(elevator, direction: :down)
        end.not_to change { elevator.contains?(person) }.from(false)
      end

      it 'does not enter when the elevator is full' do
        elevator.add(described_class.new(destination))
        subject
        expect do
          from_floor.broadcast_stop(elevator, direction: :up)
        end.not_to change { elevator.contains?(person) }.from(false)
      end
    end
  end
end
