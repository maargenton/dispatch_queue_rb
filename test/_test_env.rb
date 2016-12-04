# =============================================================================
#
# MODULE      : test/_test_env.rb
# PROJECT     : DispatchQueueRb
# DESCRIPTION :
#
# Copyright (c) 2016, Marc-Antoine Argenton.  All rights reserved.
# =============================================================================

require 'minitest/autorun'
require 'minitest/reporters'
require 'fileutils'
require 'pp'
require 'rr'

require 'lib/dispatch_queue_rb.rb'

# Minitest::Reporters.use! [Minitest::Reporters::SpecReporter.new]
# Minitest.backtrace_filter
# Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new( color:true ), Minitest::Reporters::JUnitReporter.new]

module Minitest::Assertions
  def assert_custom( expected, actual )
    assert false, "assert_custom() always fails\n" +
                  "  Expected: #{expected.inspect}\n" +
                  "  Actak:    #{actual.inspect}\n"
  end
end
