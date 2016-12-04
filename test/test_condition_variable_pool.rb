# =============================================================================
#
# MODULE      : test/test_condition_variable_pool.rb
# PROJECT     : DispatchQueue
# DESCRIPTION :
#
# Copyright (c) 2016, Marc-Antoine Argenton.  All rights reserved.
# =============================================================================


require '_test_env.rb'

module DispatchQueue
  describe ConditionVariablePool do

    describe "acquire" do
      it "returns a pair of mutex and condition variable" do
        mutex, condition = ConditionVariablePool.acquire()
        mutex.must_be_instance_of Mutex
        condition.must_be_instance_of ConditionVariable
      end
    end

    describe "release" do
      it "releases mutex and condition variable" do
        mutex, condition = ConditionVariablePool.acquire()
        ConditionVariablePool.release( mutex, condition )
      end

      it "recycles released mutex and condition variable" do
        mutex, condition = ConditionVariablePool.acquire()
        ConditionVariablePool.release( mutex, condition )
        mutex2, condition2 = ConditionVariablePool.acquire()

        mutex2.must_be_same_as mutex
        condition2.must_be_same_as condition
      end
    end

  end
end
