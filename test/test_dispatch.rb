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
      it "is a ThreadPoolQueue" do
        Dispatch.default_queue.must_be_instance_of ThreadPoolQueue
      end

      it "must remain the same" do
        q1 = Dispatch.default_queue
        q2 = Dispatch.default_queue

        q1.wont_be_nil
        q2.wont_be_nil
        q2.must_be_same_as q1
      end
    end

    describe "main_queue" do
      it "is a ThreadQueue" do
        Dispatch.main_queue.must_be_instance_of ThreadQueue
      end

      it "must remain the same" do
        q1 = Dispatch.main_queue
        q2 = Dispatch.main_queue

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

    describe "concurrent_map" do
      it "returns reslt of concurrently executed block" do
        start_time = Time.now()
        result = Dispatch.concurrent_map( 1..10 ) do |i|
          sleep( 0.001 )
          i
        end.must_equal (1..10).to_a

        elapsed_time = Time.now - start_time
        elapsed_time.must_be :<, 0.005
      end
    end

  end
end
