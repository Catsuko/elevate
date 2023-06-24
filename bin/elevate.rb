#!/usr/bin/env ruby

require_relative '../lib/elevate/simulation'
require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.banner = 'Usage: elevate -f 20 -n 100 -c 3'

  opts.on('-fFLOORS', '--floors=FLOORS', 'Number of floors') { |v| options[:floors] = v.to_i }
  opts.on('-nTRAFFIC', '--traffic=TRAFFIC', 'Total number of people') { |v| options[:traffic] = v.to_i }
  opts.on('-cCAPACITY', '--capacity=CAPACITY', 'Max people on board') { |v| options[:capacity] = v.to_i }
end.parse!

simulation = Elevate::Simulation.new(total_users: options.fetch(:traffic))
simulation.run(total_floors: options.fetch(:floors), elevator_capacity: options.fetch(:capacity))
