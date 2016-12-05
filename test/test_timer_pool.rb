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
    describe "default_pool" do
      subject { TimerPool.default_pool }

      it "is a valid TimerPool" do
        subject.must_be_instance_of TimerPool
      end

      it "execute tasks after specified time" do
        done = false
        subject.dispatch_after( Time.now() + 0.001 ) { done = true }
        done.must_equal false
        sleep( 0.002 )
        done.must_equal true
      end

      it "execute tasks after specified delay" do
        done = false
        subject.dispatch_after( 0.001 ) { done = true }
        done.must_equal false
        sleep( 0.002 )
        done.must_equal true
      end

      it "execute tasks in eta order" do
        result = []
        group = DispatchGroup.new
        queue = SerialQueue.new
        subject.dispatch_after( 0.001, target_queue:queue, group:group ) { result << 1 }
        subject.dispatch_after( 0.003, target_queue:queue, group:group ) { result << 3 }
        subject.dispatch_after( 0.004, target_queue:queue, group:group ) { result << 4 }
        subject.dispatch_after( 0.002, target_queue:queue, group:group ) { result << 2 }
        group.wait()
        result.must_equal [1,2,3,4]
      end
    end # describe "default_pool"

    describe "SerialQueue.dispatch_after" do
      subject { SerialQueue.new }

      it "execute tasks in eta order" do
        result = []
        group = DispatchGroup.new
        subject.dispatch_after( 0.001, group:group ) { result << 1 }
        subject.dispatch_after( 0.003, group:group ) { result << 3 }
        subject.dispatch_after( 0.004, group:group ) { result << 4 }
        subject.dispatch_after( 0.002, group:group ) { result << 2 }
        group.wait()
        result.must_equal [1,2,3,4]
      end
    end

    describe "ConcurrentQueue.dispatch_after" do
      subject { ConcurrentQueue.new }

      it "execute tasks in eta order" do
        result = []
        group = DispatchGroup.new
        subject.dispatch_after( 0.001, group:group ) { result << 1 }
        subject.dispatch_after( 0.003, group:group ) { result << 3 }
        subject.dispatch_after( 0.004, group:group ) { result << 4 }
        subject.dispatch_after( 0.002, group:group ) { result << 2 }
        group.wait()
        result.must_equal [1,2,3,4]
      end
    end

    describe "ThreadPoolQueue.dispatch_after" do
      subject { Dispatch.default_queue }

      it "execute tasks in eta order" do
        result = []
        group = DispatchGroup.new
        subject.dispatch_after( 0.001, group:group ) { result << 1 }
        subject.dispatch_after( 0.003, group:group ) { result << 3 }
        subject.dispatch_after( 0.004, group:group ) { result << 4 }
        subject.dispatch_after( 0.002, group:group ) { result << 2 }
        group.wait()
        result.must_equal [1,2,3,4]
      end
    end

  end # describe TimerPool
end # module DispatchQueue
