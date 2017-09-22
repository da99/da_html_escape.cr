
require "./the_job"
require "profiler"

job = The_Job.new

puts "Encoding"
Profiler__::start_profile
job.encode(1)
Profiler__::print_profile($stdout)

puts "Decoding"
Profiler__::start_profile
job.decode(1)
Profiler__::print_profile($stdout)
