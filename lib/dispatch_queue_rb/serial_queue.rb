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

    def dispatch_async( &task )
      @parent_queue.dispatch_async do
        _run_task( task )
      end if _try_activate_or_enqueue( task )
    end

    def dispatch_sync( &task )
      mutex, condition = ConditionVariablePool.acquire()
      mutex.synchronize do

        dispatch_async do
          task.call()
          mutex.synchronize do
            condition.signal()
          end
        end

        condition.wait( mutex )
      end
      ConditionVariablePool.release( mutex, condition )
    end

    alias_method :dispatch_barrier_async, :dispatch_async
    alias_method :dispatch_barrier_sync, :dispatch_sync

  private
    def _try_activate_or_enqueue( task )
      @mutex.synchronize do
        if (!@active)
          @active = true
          return true
        else
          @task_list << task
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
      task, target_queue = _suspend_or_next_task()
      target_queue.dispatch_async do
        _run_task( task )
      end if task
    end

    def _suspend_or_next_task()
      @mutex.synchronize do
        return @task_list.shift, @parent_queue if !@task_list.empty?
        @active = false
        return nil
      end
    end

  end # class SerialQueue
end # module DispatchQueue
