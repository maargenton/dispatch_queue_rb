# =============================================================================
#
# MODULE      : lib/dispatch_queue_rb/thread_queue.rb
# PROJECT     : DispatchQueue
# DESCRIPTION :
#
# Copyright (c) 2016, Marc-Antoine Argenton.  All rights reserved.
# =============================================================================

module DispatchQueue
  class ThreadQueue
    def initialize( thread_termination_delay:0.01 )
      @thread_termination_delay = thread_termination_delay

      @mutex = Mutex.new
      @condition = ConditionVariable.new
      @tasks = []
      @thread = nil
    end

    def dispatch_async( group:nil, &task )
      group.enter() if group
      @mutex.synchronize do
        resume = @tasks.empty?
        @tasks << Continuation.new( group:group, &task )
        _sync_spawn_or_wakeup_thread() if resume
      end
      self
    end

    alias_method :dispatch_barrier_async, :dispatch_async

    include DispatchSyncMixin
    include DispatchAfterMixin


  private
    def _thread_main
      @mutex.synchronize do
        loop do
          @tasks.shift.run() if !@tasks.empty?

          next if !@tasks.empty?
          @condition.wait( @mutex, thread_termination_delay )

          if @tasks.empty?
            @thread = nil
            break
          end
        end # loop
      end
    end

    def _sync_spawn_or_wakeup_thread()
      @thread = Thread.new { _thread_main() } if @thread.nil?
      @condition.signal()
    end

  end # class ThreadQueue
end # module DispatchQueue
