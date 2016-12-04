# =============================================================================
#
# MODULE      : test/test_group_thread_pool_queue.rb
# PROJECT     : DispatchQueue
# DESCRIPTION :
#
# Copyright (c) 2016, Marc-Antoine Argenton.  All rights reserved.
# =============================================================================


require '_test_env.rb'
require 'timeout'

module DispatchQueue
  describe "Group with ThreadPoolQueue" do
    let( :target_queue ) { Dispatch.default_queue }
    let( :group ) { Group.new }

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
  end # Group with ThreadPoolQueue
end # module DispatchQueue
