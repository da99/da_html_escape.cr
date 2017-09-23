
{{ puts "Compiling...".id }}
require "./the_job"
require "benchmark"

job = The_Job.new

Benchmark.bm do |b|
  b.report(":escape        "){ job.escape(100) }
  b.report(":unescape_once "){ job.unescape_once(100) }
  b.report(":unescape!     "){ job.unescape!(100) }
end
