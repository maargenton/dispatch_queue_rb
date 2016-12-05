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
    let( :group )           { DispatchGroup.new }
    let( :queue )           { SerialQueue.new }
    let( :reference_time )  { Time.now + 0.005 }
    let( :result )          { [] }

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
        subject.dispatch_after( reference_time + 0.001, target_queue:queue, group:group ) { result << 1 }
        subject.dispatch_after( reference_time + 0.003, target_queue:queue, group:group ) { result << 3 }
        subject.dispatch_after( reference_time + 0.004, target_queue:queue, group:group ) { result << 4 }
        subject.dispatch_after( reference_time + 0.002, target_queue:queue, group:group ) { result << 2 }
        group.wait()
        result.must_equal [1,2,3,4]
      end
    end # describe "default_pool"

    describe "SerialQueue.dispatch_after" do
      subject { SerialQueue.new }

      it "execute tasks in eta order" do
        subject.dispatch_after( reference_time + 0.001, group:group ) { result << 1 }
        subject.dispatch_after( reference_time + 0.003, group:group ) { result << 3 }
        subject.dispatch_after( reference_time + 0.004, group:group ) { result << 4 }
        subject.dispatch_after( reference_time + 0.002, group:group ) { result << 2 }
        group.wait()
        result.must_equal [1,2,3,4]
      end

      it "execute more tasks in eta order" do
        count = 100
        (1..count).to_a.shuffle.each do |i|
          subject.dispatch_after( reference_time + i * 0.001, group:group ) { result << i }
        end
        group.wait()
        result.must_equal (1..count).to_a
      end
    end

    describe "ThreadQueue.dispatch_after" do
      subject { ThreadQueue.new }

      it "execute tasks in eta order" do
        subject.dispatch_after( reference_time + 0.001, group:group ) { result << 1 }
        subject.dispatch_after( reference_time + 0.003, group:group ) { result << 3 }
        subject.dispatch_after( reference_time + 0.004, group:group ) { result << 4 }
        subject.dispatch_after( reference_time + 0.002, group:group ) { result << 2 }
        group.wait()
        result.must_equal [1,2,3,4]
      end
    end


    # NOTE: these test may fail occasionally since the target queues uses are
    # concurrent and only guaranty that work will be scheduled in order.
    # Execution might be out of order by the time the result is enqueued.
    # Ordering relies exclusively on the delays introduced by dispatch_after(),
    # which might not be nough.
    # Also note that there is no synchronization on writing to result, so this
    # will result in a race condition in multi-threaded ruby interpretter.

    describe "ConcurrentQueue.dispatch_after" do
      subject { ConcurrentQueue.new }

      it "execute tasks in eta order" do
        subject.dispatch_after( reference_time + 0.001, group:group ) { result << 1 }
        subject.dispatch_after( reference_time + 0.003, group:group ) { result << 3 }
        subject.dispatch_after( reference_time + 0.004, group:group ) { result << 4 }
        subject.dispatch_after( reference_time + 0.002, group:group ) { result << 2 }
        group.wait()
        result.must_equal [1,2,3,4]
      end
    end

    describe "ThreadPoolQueue.dispatch_after" do
      subject { ThreadPoolQueue.new }

      it "execute tasks in eta order" do
        subject.dispatch_after( reference_time + 0.001, group:group ) { result << 1 }
        subject.dispatch_after( reference_time + 0.003, group:group ) { result << 3 }
        subject.dispatch_after( reference_time + 0.004, group:group ) { result << 4 }
        subject.dispatch_after( reference_time + 0.002, group:group ) { result << 2 }
        group.wait()
        result.must_equal [1,2,3,4]
      end
    end

  end # describe TimerPool
end # module DispatchQueue
