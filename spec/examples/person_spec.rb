require 'elevate/person'
require 'elevate/elevator'

RSpec.describe Elevate::Person do
  describe '#wants_to_get_off?' do
    let(:destination) { 10 }
    let(:person) { described_class.new(destination) }

    it 'is true when the floor is the same as their destination' do
      expect(person.wants_to_get_off?(destination)).to eq true
    end

    it 'is false when the floor is different to their destination' do
      10.times do |n|
        expect(person.wants_to_get_off?(n)).to eq false
      end
    end
  end

  describe '#get_on' do
    let(:elevator) { Elevate::Elevator.new(1..20, current_floor: 1, capacity: 1) }
    let(:person) { described_class.new(20) }
    subject { person.get_on(elevator) }

    it 'makes the person enter the elevator' do
      expect { subject }.to change { elevator.contains?(person) }.from(false).to(true)
    end

    it "adds the person's destination to the elevator's stops" do
      expect { subject }.to change { elevator.stopping_at?(20) }.from(false).to(true)
    end
  end

  describe '#get_off' do
    let(:elevator) { Elevate::Elevator.new(1..20, current_floor: 1, capacity: 1) }
    let(:person) { described_class.new(20) }
    subject { person.get_off(elevator) }

    before { person.get_on(elevator) }

    it 'makes the person leave the elevator' do
      expect { subject }.to change { elevator.contains?(person) }.from(true).to(false)
    end
  end
end
