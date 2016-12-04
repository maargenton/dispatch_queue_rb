# =============================================================================
#
# MODULE      : test/test_dispatch.rb
# PROJECT     : DispatchQueue
# DESCRIPTION :
#
# Copyright (c) 2016, Marc-Antoine Argenton.  All rights reserved.
# =============================================================================


require '_test_env.rb'

module DispatchQueue
  describe Dispatch do

    describe "default_queue" do
      it "must remain the same" do
        q1 = Dispatch.default_queue
        q2 = Dispatch.default_queue

        q1.wont_be_nil
        q2.wont_be_nil
        q2.must_be_same_as q1
      end
    end

    describe "ncpu" do
      it "returns the number of cpu cores available" do
        Dispatch.ncpu.must_be_kind_of Integer
        Dispatch.ncpu.must_be :>, 1
      end
    end


  end
end
