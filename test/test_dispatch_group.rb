# =============================================================================
#
# MODULE      : test/test_dispatch_group.rb
# PROJECT     : DispatchQueue
# DESCRIPTION :
#
# Copyright (c) 2016, Marc-Antoine Argenton.  All rights reserved.
# =============================================================================


require '_test_env.rb'
require 'timeout'

module DispatchQueue
  describe DispatchGroup do

    subject { DispatchGroup.new }

    it "can create a new group" do
      subject.must_be_instance_of DispatchGroup
    end


    describe "wait()" do
      it "returns true immediatly when no work is pending in the group" do
        subject.wait().must_equal true
      end

      it "waits forever if group enters and never leaves" do
        subject.enter()

        assert_must_timeout do
          subject.wait()
        end
      end

      it "waits until timeout expires and returns false if enter never leaves " do
        subject.enter()

        assert_wont_timeout(0.002) do
          subject.wait( timeout:0.001 ).must_equal false
        end
      end

      it "returns true when leave() is called" do
        subject.enter()
        Dispatch.default_queue.dispatch_async do
          sleep( 0.001 )
          subject.leave()
        end

        assert_wont_timeout(0.002) do
          subject.wait().must_equal true
        end
      end
    end # describe "wait()"

  end # describe DispatchGroup do
end # module DispatchQueue
