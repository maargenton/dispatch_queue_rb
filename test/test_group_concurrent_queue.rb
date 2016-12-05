# =============================================================================
#
# MODULE      : test/test_group_concurrent_queue.rb
# PROJECT     : DispatchQueue
# DESCRIPTION :
#
# Copyright (c) 2016, Marc-Antoine Argenton.  All rights reserved.
# =============================================================================


require '_test_env.rb'
require 'timeout'

module DispatchQueue
  describe "DispatchGroup with ConcurrentQueue" do
    let( :target_queue ) { ConcurrentQueue.new }
    let( :group ) { DispatchGroup.new }

    it "leaves group when task completes, with single task on idle queue " do
      target_queue.dispatch_async( group:group ) { sleep( 0.002 ) }
      assert_must_timeout( 0.001 ) { group.wait() }
      assert_wont_timeout( 0.002 ) { group.wait() }
    end

    it "leaves group when task completes, with enquened tasks" do
      (1..10).each do
        target_queue.dispatch_async( group:group ) { sleep( 0.002 ) }
      end

      assert_must_timeout( 0.001 ) { group.wait() }
      assert_wont_timeout( 0.020 ) { group.wait() }
    end

    it "leaves group when task completes, with barrier tasks only" do
      (1..4).each do
        target_queue.dispatch_barrier_async( group:group ) { sleep( 0.002 ) }
      end

      assert_must_timeout( 0.001 ) { group.wait() }
      assert_wont_timeout( 0.010 ) { group.wait() }
    end

    it "leaves group when task completes, with mix of barrier and non-barrier tasks" do
      target_queue.dispatch_async( group:group ) { sleep( 0.002 ) }
      (1..10).each do
        target_queue.dispatch_async( group:group ) { sleep( 0.001 ) }
      end

      target_queue.dispatch_barrier_async( group:group ) { sleep( 0.001 ) }
      (1..10).each do
        target_queue.dispatch_async( group:group ) { sleep( 0.002 ) }
      end
      target_queue.dispatch_barrier_async( group:group ) { sleep( 0.001 ) }

      assert_must_timeout( 0.001 ) { group.wait() }
      assert_wont_timeout( 0.030 ) { group.wait() }
    end

    it "completes immediatly after a last synchronous barrier" do
      target_queue.dispatch_async( group:group ) { sleep( 0.002 ) }
      (1..10).each do
        target_queue.dispatch_async( group:group ) { sleep( 0.001 ) }
      end

      target_queue.dispatch_barrier_async( group:group ) { sleep( 0.001 ) }
      (1..10).each do
        target_queue.dispatch_async( group:group ) { sleep( 0.002 ) }
      end

      assert_must_timeout( 0.001 ) { group.wait() }
      target_queue.dispatch_barrier_sync( group:group ) { sleep( 0.001 ) }
      assert_wont_timeout( 0.001 ) { group.wait() }
    end
  end # DispatchGroup with ConcurrentQueue
end # module DispatchQueue
