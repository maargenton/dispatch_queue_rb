# =============================================================================
#
# MODULE      : lib/dispatch_queue_rb/dispatch_after_mixin.rb
# PROJECT     : DispatchQueue
# DESCRIPTION :
#
# Copyright (c) 2016, Marc-Antoine Argenton.  All rights reserved.
# =============================================================================

module DispatchQueue
  module DispatchAfterMixin

    def dispatch_after( eta, group:nil, &task )
      TimerPool.default_pool.dispatch_after( eta, group:group, target_queue:self, &task )
    end

  end # class DispatchAfterMixin
end # module DispatchQueue
