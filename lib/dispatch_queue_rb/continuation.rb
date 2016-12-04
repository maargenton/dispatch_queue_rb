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
    def initialize( target_queue:nil, group:nil, barrier:false, &task )
      @task = task
      @target_queue = target_queue
      @group = group
      @barrier = barrier
    end

    def run( default_target_queue:nil, override_target_queue:nil )
      q = override_target_queue || @target_queue || default_target_queue
      if q
        if @barrier
          q.dispatch_barrier_async( group:group, &@task )
        else
          q.dispatch_async( group:group, &@task )
        end
      else
        task.call()
        @group.leave() if @group
      end
    end
  end # class Continuation
end # module DispatchQueue
