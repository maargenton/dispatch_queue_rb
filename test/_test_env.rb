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
require 'timeout'

require 'lib/dispatch_queue_rb.rb'

# Minitest::Reporters.use! [Minitest::Reporters::SpecReporter.new]
# Minitest.backtrace_filter
# Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new( color:true ), Minitest::Reporters::JUnitReporter.new]

module Minitest::Assertions
  def assert_must_timeout( timeout_delay = 0.001 )
    success = false
    begin
      timeout( timeout_delay ) do
        yield
      end
    rescue Timeout::Error => e
      success = true
    end

    # assert success, "Expected operation to not complete within #{timeout_delay}s, but did"
    assert success, "Expected operation to not complete within #{timeout_delay}s, but did"
  end

  def assert_wont_timeout( timeout_delay = 0.001 )
    success = true
    begin
      timeout( timeout_delay ) do
        yield
      end
    rescue Timeout::Error => e
      success = false
    end

    # assert success, "Expected operation to not complete within #{timeout_delay}s, but did"
    assert success, "Expected operation to complete within #{timeout_delay}s, but did not"
  end
end
