# =============================================================================
#
# MODULE      : lib/dispatch_queue_rb/continuation.rb
# PROJECT     : DispatchQueue
# DESCRIPTION :
#
# Copyright (c) 2016, Marc-Antoine Argenton.  All rights reserved.
# =============================================================================

module DispatchQueue
  class Continuation
    attr_reader :barrier
    attr_reader :eta

    def initialize( target_queue:nil, group:nil, barrier:false, eta:nil, &task )
      @task = task
      @target_queue = target_queue
      @group = group
      @barrier = barrier
      @eta = eta
    end

    def run( default_target_queue:nil, override_target_queue:nil )
      queue = override_target_queue || @target_queue || default_target_queue
      if queue
        if @barrier
          queue.dispatch_barrier_async( group:@group, &@task )
        else
          queue.dispatch_async( group:@group, &@task )
        end
        @group.leave() if @group
      else
        begin
          @task.call() if @task
        ensure
          @group.leave() if @group
        end
      end
    end
  end # class Continuation
end # module DispatchQueue
