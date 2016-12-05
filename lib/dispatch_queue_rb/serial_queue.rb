# =============================================================================
#
# MODULE      : lib/dispatch_queue_rb/serial_queue.rb
# PROJECT     : DispatchQueue
# DESCRIPTION :
#
# Copyright (c) 2016, Marc-Antoine Argenton.  All rights reserved.
# =============================================================================

module DispatchQueue
  class SerialQueue

    def initialize( parent_queue: nil )
      @mutex = Mutex.new
      @condition = ConditionVariable.new
      @task_list = []
      @active = false
      @parent_queue = parent_queue || Dispatch.default_queue
    end

    def dispatch_async( group:nil, &task )
      group.enter() if group
      continuation = Continuation.new( target_queue:@parent_queue, group:group ) do
        _run_task( task )
      end

      continuation.run() if _try_activate_or_enqueue( continuation )
      self
    end

    alias_method :dispatch_barrier_async, :dispatch_async

    include DispatchSyncMixin
    include DispatchAfterMixin



  private
    def _try_activate_or_enqueue( continuation )
      @mutex.synchronize do
        if (!@active)
          @active = true
          return true
        else
          @task_list << continuation
          return false
        end
      end
    end

    def _run_task( task )
      previous_queue = Thread.current[:current_queue]
      Thread.current[:current_queue] = self

      begin
        task.call()
      ensure
        Thread.current[:current_queue] = previous_queue
        _dispatch_next_task()
      end
    end

    def _dispatch_next_task()
      continuation = _suspend_or_next_task()
      continuation.run() if continuation
    end

    def _suspend_or_next_task()
      @mutex.synchronize do
        return @task_list.shift if !@task_list.empty?
        @active = false
        return nil
      end
    end

  end # class SerialQueue
end # module DispatchQueue
