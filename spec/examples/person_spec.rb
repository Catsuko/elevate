require 'elevate/person'
require 'elevate/elevator'

RSpec.describe Elevate::Person do
  let(:destination) { 20 }
  let(:elevator) { Elevate::Elevator.new(1..destination, current_floor: 1, capacity: 1) }
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
        elevator.broadcast_arrival(destination.pred, travel_direction: :up)
      end.not_to change { elevator.contains?(person) }.from(true)
    end

    it 'gets off when the elevator reaches their destination' do
      subject
      expect do
        elevator.broadcast_arrival(destination, travel_direction: :up)
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

  describe '#wait_for' do
    let(:from_floor) { 2 }
    subject { person.wait_for(elevator, from_floor: from_floor) }

    it 'calls the elevator to their floor' do
      expect { subject }.to change { elevator.stopping_at?(from_floor) }.from(false).to(true)
    end

    context 'when the elevator reaches their floor' do
      it 'enters when it is travelling in their direction' do
        subject
        expect do
          elevator.broadcast_arrival(from_floor, travel_direction: :up)
        end.to change { elevator.contains?(person) }.from(false).to(true)
      end

      it 'does not enter when it is travelling in the other direction' do
        subject
        expect do
          elevator.broadcast_arrival(from_floor, travel_direction: :down)
        end.not_to change { elevator.contains?(person) }.from(false)
      end
    end

    # From domain point of view, this is weird to test for, see comment in `events\wait_to_get_on.rb`.
    it 'does not enter the elevator when it arrives at other floors' do
      subject
      expect do
        elevator.broadcast_arrival(destination, travel_direction: :up)
      end.not_to change { elevator.contains?(person) }.from(false)
    end
  end
end
