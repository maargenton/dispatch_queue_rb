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

    def self.default_pool
      @@default_pool
    end

    def initialize()
      @mutex = Mutex.new
      @condition = ConditionVariable.new
      @heap = Heap.new { |a,b| a.eta < b.eta }
      @scheduled_eta = nil
      @thread = nil
    end

    def dispatch_after( eta, group:nil, target_queue:nil, &task )
      group.enter() if group
      target_queue ||= Dispatch.default_queue
      eta = Time.now + eta if !(Time === eta)
      continuation = Continuation.new( target_queue:target_queue, group:group, eta:eta, &task )

      @mutex.synchronize do
        @heap.push( continuation )
        if @scheduled_eta.nil? || eta < @scheduled_eta
          @thread = Thread.new { _thread_main() } if @thread.nil?
          @condition.signal()
        end
      end
      target_queue
    end



  private
    def _thread_main
      @mutex.synchronize do
        loop do
          _fire_expired_timers()
          wait_time = @heap.head.eta - Time.now if !@heap.empty?
          next if wait_time && wait_time < 0

          idle = @heap.empty?
          @condition.wait( @mutex, wait_time || 0.01 )
          if idle && @heap.empty?
            @thread = nil
            break
          end
        end # loop
      end
    end

    def _fire_expired_timers
      while !@heap.empty? && @heap.head.eta < Time.now do
        continuation = @heap.pop
        continuation.run()
      end
    end

    @@default_pool = self.new

  end # class TimerPool
end # module DispatchQueue
