# =============================================================================
#
# MODULE      : lib/dispatch_queue_rb/timer_pool.rb
# PROJECT     : DispatchQueue
# DESCRIPTION :
#
# Copyright (c) 2016, Marc-Antoine Argenton.  All rights reserved.
# =============================================================================

module DispatchQueue
  class TimerPool
    Timer = Struct.new(:eta, :target_queue, :task)

    def initialize()
      @mutex = Mutex.new
      @condition = ConditionVariable.new
      @heap = Heap.new { |a,b| a.eta < b.eta }
      @scheduled_eta = nil
    end

    def schedule_timer( eta, target_queue, task )
      @mutex.synchronize do
        @heap.push( Timer.new( eta, target_queue, task ) )
        @condition.signal() if @scheduled_eta.nil? || eta < @scheduled_eta
      end
    end

    def _thread_main
      loop do
        _fire_expired_timers()
        wait_time = @heap.head.eta - Time.now if !@heap.empty
        next if wait_time < 0
        @condition.wait( @mutex, wait_time )
      end
    end

    def _fire_expired_timers
      while !@heap.empty? && @heap.head.eta < Time.now do
        timer = @heap.pop
        timer.target_queue.dispatch_async( &timer.task )
      end
    end
  end # class TimerPool
end # module DispatchQueue
