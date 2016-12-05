# =============================================================================
#
# MODULE      : lib/dispatch_queue_rb/dispatch_sync_mixin.rb
# PROJECT     : DispatchQueue
# DESCRIPTION :
#
# Copyright (c) 2016, Marc-Antoine Argenton.  All rights reserved.
# =============================================================================

module DispatchQueue
  module DispatchSyncMixin

    def dispatch_sync( group:nil, &task )
      mutex, condition = ConditionVariablePool.acquire()
      result = nil
      mutex.synchronize do
        dispatch_async( group:group ) do
          result = task.call()
          mutex.synchronize { condition.signal() }
        end
        condition.wait( mutex )
      end
      ConditionVariablePool.release( mutex, condition )
      result
    end

    def dispatch_barrier_sync( group:nil, &task )
      mutex, condition = ConditionVariablePool.acquire()
      result = nil
      mutex.synchronize do
        dispatch_barrier_async( group:group ) do
          result = task.call()
          mutex.synchronize { condition.signal() }
        end
        condition.wait( mutex )
      end
      ConditionVariablePool.release( mutex, condition )
      result
    end

  end # class DispatchSyncMixin
end # module DispatchQueue
