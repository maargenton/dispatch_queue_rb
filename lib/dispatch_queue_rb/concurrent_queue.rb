# =============================================================================
#
# MODULE      : lib/dispatch_queue_rb/concurrent_queue.rb
# PROJECT     : DispatchQueue
# DESCRIPTION :
#
# Copyright (c) 2016, Marc-Antoine Argenton.  All rights reserved.
# =============================================================================

module DispatchQueue
  class ConcurrentQueue

    def initialize( parent_queue: nil )
      @mutex = Mutex.new
      @condition = ConditionVariable.new
      @task_list = []
      @parent_queue = parent_queue || Dispatch.default_queue
      @scheduled_count = 0
      @barrier_count = 0
    end

    def dispatch_async( &task )
      schedule_immediately = @mutex.synchronize do
        if ( @barrier_count > 0)
          @task_list << [task, false]
          false
        else
          @scheduled_count += 1
          true
        end
      end

      @parent_queue.dispatch_async { _run_task( task, false ) } if schedule_immediately
    end

    def dispatch_sync( &task )
      mutex, condition = ConditionVariablePool.acquire()
      mutex.synchronize do

        dispatch_async do
          begin
            task.call()
          ensure
            mutex.synchronize do
              condition.signal()
            end
          end
        end

        condition.wait( mutex )
      end
      ConditionVariablePool.release( mutex, condition )
    end


    def dispatch_barrier_async( &task )
      barrier_task, tasks = @mutex.synchronize do
        @barrier_count += 1
        @task_list << [task, true]
        resume_pending = ( @scheduled_count == 0 && @barrier_count == 1)
        _sync_get_next_batch() if resume_pending
      end

      _schedule_next_batch( barrier_task, tasks )
    end

    def dispatch_barrier_sync( &task )
      mutex, condition = ConditionVariablePool.acquire()
      mutex.synchronize do

        dispatch_barrier_async do
          begin
            task.call()
          ensure
            mutex.synchronize do
              condition.signal()
            end
          end
        end

        condition.wait( mutex )
      end
      ConditionVariablePool.release( mutex, condition )
    end

    # def _debug_trace_queue_state( prefix = "" )
    #   puts "%-35s | scheduled: %3d, barrier: %3d, queued: %3d, barrier_head: %-5s" % [
    #     prefix,
    #     @scheduled_count,
    #     @barrier_count,
    #     @task_list.count,
    #     !@task_list.empty? && @task_list.first[1],
    #   ]
    # end

  private
    def _run_task( task, barrier )
      previous_queue = Thread.current[:current_queue]
      Thread.current[:current_queue] = self

      begin
        task.call()
      ensure
        Thread.current[:current_queue] = previous_queue
        _task_comleted( barrier )
      end
    end

    def _task_comleted( barrier = false )
      barrier_task, tasks = @mutex.synchronize do
        resume_pending = barrier || ((@scheduled_count -= 1) == 0)
        @barrier_count -= 1 if barrier
        _sync_get_next_batch() if resume_pending
      end

      _schedule_next_batch( barrier_task, tasks )
    end

    def _sync_get_next_batch()
      return nil if @task_list.empty?
      return @task_list.shift.first if @task_list.first[1] # Barrier task

      tasks = []
      tasks << @task_list.shift.first while @task_list.first[1] == false
      @scheduled_count += tasks.count
      return [nil, tasks]
    end

    def _schedule_next_batch( barrier_task, tasks )
      if barrier_task
        @parent_queue.dispatch_async { _run_task( barrier_task, true ) }
      elsif tasks
        tasks.each do |t|
          @parent_queue.dispatch_async { _run_task( t, false ) }
        end
      end
    end

  end # class ConcurrentQueue
end # module DispatchQueue
