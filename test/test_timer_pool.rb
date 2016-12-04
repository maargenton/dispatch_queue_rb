# =============================================================================
#
# MODULE      : test/test_timer_pool.rb
# PROJECT     : DispatchQueue
# DESCRIPTION :
#
# Copyright (c) 2016, Marc-Antoine Argenton.  All rights reserved.
# =============================================================================


require '_test_env.rb'

module DispatchQueue
  describe TimerPool do

    subject { TimerPool.new }

    it "passes this one" do
      subject.must_be_instance_of TimerPool
    end

  end
end
