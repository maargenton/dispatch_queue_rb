# =============================================================================
#
# MODULE      : test/test_group_serial_queue.rb
# PROJECT     : DispatchQueue
# DESCRIPTION :
#
# Copyright (c) 2016, Marc-Antoine Argenton.  All rights reserved.
# =============================================================================


require '_test_env.rb'
require 'timeout'

module DispatchQueue
  describe "DispatchGroup with SerialQueue" do

    let( :target_queue ) { SerialQueue.new }
    let( :group ) { DispatchGroup.new }

    it "leaves group when task completes, with single task on idle queue " do
      target_queue.dispatch_async( group:group ) { sleep( 0.002 ) }
      assert_must_timeout( 0.001 ) { group.wait() }
      assert_wont_timeout( 0.002 ) { group.wait() }
    end

    it "leaves group when task completes, with enquened tasks" do
      target_queue.dispatch_async( group:group ) { sleep( 0.002 ) }
      target_queue.dispatch_async( group:group ) { sleep( 0.002 ) }
      assert_must_timeout( 0.001 ) { group.wait() }
      assert_wont_timeout( 0.005 ) { group.wait() }
    end
  end # DispatchGroup with SerialQueue
end # module DispatchQueue
