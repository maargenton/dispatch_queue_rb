# =============================================================================
#
# MODULE      : dispatch_queue_rb.gemspec
# PROJECT     : DispatchQueueRb
# DESCRIPTION :
#
# Copyright (c) 2016, Marc-Antoine Argenton.  All rights reserved.
# =============================================================================


require_relative 'lib/dispatch_queue_rb/version.rb'

Gem::Specification.new do |spec|
  spec.name         = 'dispatch_queue_rb'
  spec.version      = DispatchQueue::VERSION
  spec.authors      = ["Marc-Antoine Argenton"]
  spec.email        = ["maargenton.dev@gmail.com"]
  spec.summary      = "Pure ruby implementation of Grand Central Dispatch concurrency primitives."
  spec.description  = %q{
    DispatchQueueRb is a pure ruby implementation of Grand Central Dispatch concurrency primitives.
    It implements serial and concurrent queues, with synchronous, asynchronous,
    barrier and delayed dispatch methods. All queues dispatch methods support an
    optional dispatch groups to synchronize on completion of a group of tasks.
    It also provides a thread pool based concurrent queue, scaled to the number
    of available cpu cores, and used by default to schedule the actual work.
                      }.gsub( /\s+/, ' ').strip
  spec.homepage     = "https://github.com/marcus999/dispatch_queue_rb"

  spec.files        = Dir['[A-Z]*', 'rakefile.rb', '*.gemspec'].reject { |f| f =~ /.lock/ }
  spec.files        += Dir['bin/**', 'lib/**/*.rb', 'test/**/*.rb', 'spec/**/*.rb', 'features/**/*.rb']
  spec.executables  = spec.files.grep( %r{^bin/} ) { |f| File.basename(f) }
  spec.test_files   = spec.files.grep( %r{^(test|spec|features)/} )

  # spec.add_runtime_dependency 'facets', '~> 3.0'
  # spec.add_runtime_dependency 'mustache', '~> 1.0'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'watch', '~> 0.1'
  spec.add_development_dependency 'rr', '~> 1.1'
  spec.add_development_dependency 'minitest', '~> 5.3'
  spec.add_development_dependency 'minitest-reporters', '~> 1.1'
end
