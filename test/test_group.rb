# =============================================================================
#
# MODULE      : test/test_group.rb
# PROJECT     : DispatchQueue
# DESCRIPTION :
#
# Copyright (c) 2016, Marc-Antoine Argenton.  All rights reserved.
# =============================================================================


require '_test_env.rb'

module DispatchQueue
  describe Group do

    subject { Group.new }

    it "can create a new group" do
      subject.must_be_instance_of Group
    end

    describe "wait()" do
      it "returns immediatly when no work is pending in the group" do
        subject.wait()
      end

      it "waits until timeout expires if enter never leaves " do
        subject.enter()

        t0 = Time.now
        subject.wait( timeout:0.001 )
        dt = Time.now - t0

        dt.must_be :>, 0.001
      end

      it "waits until timeout expires if enter never leaves " do
        subject.enter()
        Dispatch.default_queue.dispatch_async do
          sleep( 0.001 )
          subject.leave()
        end

        subject.wait()
      end

    end
  end
end
