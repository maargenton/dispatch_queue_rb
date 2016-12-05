# =============================================================================
#
# MODULE      : lib/dispatch_queue_rb/mixins/dispatch_after_impl.rb
# PROJECT     : DispatchQueue
# DESCRIPTION :
#
# Copyright (c) 2016, Marc-Antoine Argenton.  All rights reserved.
# =============================================================================

module DispatchQueue
  module DispatchAfterImpl

    def dispatch_after( eta, group:nil, &task )
      TimerPool.default_pool.dispatch_after( eta, group:group, target_queue:self, &task )
    end

  end # class DispatchAfterImpl
end # module DispatchQueue
