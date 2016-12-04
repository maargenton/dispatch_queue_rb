# =============================================================================
#
# MODULE      : lib/dispatch_queue_rb/thread_pool_queue.rb
# PROJECT     : DispatchQueue
# DESCRIPTION :
#
# Copyright (c) 2016, Marc-Antoine Argenton.  All rights reserved.
# =============================================================================

module DispatchQueue
  class ThreadPoolQueue

    def initialize( max_threads:nil, debug_trace:nil, thread_termination_delay:0.01 )
      @max_threads = max_threads || Dispatch.ncpu()
      @debug_trace = debug_trace
      @thread_termination_delay = thread_termination_delay

      @mutex = Mutex.new
      @condition = ConditionVariable.new
      @tasks = []
      @worker_threads = Set.new
      @idle_count = 0
    end

    def dispatch_async( &b )
      @mutex.synchronize do
        @tasks << b
        @condition.signal()
        _sync_try_spwan_more_threads()
      end
    end

    alias_method :dispatch_barrier_async, :dispatch_async


    def max_threads
      @mutex.synchronize do
        @max_threads
      end
    end

    def max_threads=( new_value )
      @mutex.synchronize do
        @max_threads = new_value
        _sync_try_spwan_more_threads()
      end
    end

    def wait_for_all_threads_termination
      loop do
        sleep 0.001
        break if @tasks.empty? && @worker_threads.empty?
      end
    end


  private
    def _hw_ncpu()
      `sysctl -n hw.ncpu`.to_i rescue 1
    end

    def _worker_main()
      Thread.current[:current_queue] = self

      begin
        loop do
          task = _pop_task()
          break if task.nil?
          task.call()
        end
      ensure
        @mutex.synchronize do
          @worker_threads.delete( Thread.current )
          @debug_trace.call( :terminated, { thread:       Thread.current,
                                            thread_count: @worker_threads.count,
                                            idle_count:   @idle_count,
                                            task_count:   @tasks.count } ) if @debug_trace
        end
      end
    end

    def _pop_task()
      @mutex.synchronize do
        return nil if @worker_threads.count > @max_threads
        _sync_wait_for_item()
        task = @tasks.shift();
        _sync_try_spwan_more_threads() if task
        task
      end
    end


    #
    # _sync_xxx() methods assume that the mutex is already owned
    #

    def _sync_try_spwan_more_threads()
      return if @worker_threads.count >= @max_threads
      return if @idle_count > 0
      return if @tasks.count == 0

      thread = _sync_spawn_worker_thread()
      @debug_trace.call( :spawned, {  thread:       thread,
                                      from_thread:  Thread.current,
                                      thread_count: @worker_threads.count,
                                      idle_count:   @idle_count,
                                      task_count:   @tasks.count } ) if @debug_trace
    end

    def _sync_spawn_worker_thread()
      thread = Thread.new { _worker_main() }
      @worker_threads.add( thread )
      thread
    end

    def _sync_wait_for_item()
      if @tasks.empty?
        @idle_count += 1
        @condition.wait( @mutex, @thread_termination_delay )
        @idle_count -= 1
      end
    end

  end # class ThreadPoolQueue
end # module DispatchQueue
