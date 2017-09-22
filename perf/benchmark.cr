
{{ puts "Compiling...".id }}
require "./the_job"
require "benchmark"

job = The_Job.new

Benchmark.bm do |b|
  b.report("Encoding:"){ job.escape(100) }
  b.report("Decoding:"){ job.unescape(100) }
end
