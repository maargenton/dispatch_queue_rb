# =============================================================================
#
# MODULE      : lib/dispatch_queue_rb/internal/condition_variable_pool.rb
# PROJECT     : DispatchQueue
# DESCRIPTION :
#
# Copyright (c) 2016, Marc-Antoine Argenton.  All rights reserved.
# =============================================================================

module DispatchQueue
  module ConditionVariablePool
    class << self

      @@mutex = Mutex.new
      @@pool = []

      def acquire()
        @@mutex.synchronize do
          return @@pool.shift if !@@pool.empty?
        end

        return Mutex.new, ConditionVariable.new
      end

      def release( mutex, condition )
        @@mutex.synchronize do
          @@pool << [mutex, condition]
        end
      end

    end
  end # class ConditionVariablePool
end # module DispatchQueue
