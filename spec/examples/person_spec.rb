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
  end

  describe '#get_off' do
    subject { person.get_off(elevator) }

    before { person.get_on(elevator) }

    it 'leaves the elevator' do
      expect { subject }.to change { elevator.contains?(person) }.from(true).to(false)
    end
  end
end
