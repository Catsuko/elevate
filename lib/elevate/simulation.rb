require_relative 'floor'
require_relative 'elevator'
require_relative 'person'
require_relative 'events/simulation_progress'
require_relative 'events/logger'
require_relative 'router/ping_pong'

# TODO: Move Simulation into its own module and directory
# TODO: Create Elevate entry point module that requires all of the core elevate classes
module Elevate
  class Simulation
    def initialize(total_users:)
      @total_users = total_users
    end

    def run(elevator_capacity:, total_floors:, router: Router::PingPong.new)
      floors = total_floors.times.map { |f| Floor.new(f + 1) }
      elevator = Elevator.new(floors, capacity: elevator_capacity, current_floor: floors.min)
      elevator.subscribe(logger)

      progress = Events::SimulationProgress.new(goal: @total_users)
      turns = run_until_complete(elevator, floors: floors, progress: progress, router: router)
      logger.on_completed(turns)
    end

    private

    def logger
      @logger ||= Events::Logger.new
    end

    def run_until_complete(elevator, floors:, progress:, router:)
      user_count = 0
      (1..).lazy.each do |turn|
        add_person(number: user_count, floors: floors) do |person|
          user_count += 1
          person.subscribe(progress)
          person.subscribe(logger)
        end
        elevator.move(driven_by: router)
        return turn if progress.completed?
      end
    end

    def add_person(number:, floors:)
      return if number == @total_users

      start = floors.sample
      finish = floors.sample
      return if start == finish

      Person.new(finish, name: number).tap do |person|
        yield(person)
        person.wait_for_elevator(on: start)
      end
    end
  end
end
