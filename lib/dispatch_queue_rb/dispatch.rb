# =============================================================================
#
# MODULE      : lib/dispatch_queue_rb/dispatch.rb
# PROJECT     : DispatchQueue
# DESCRIPTION :
#
# Copyright (c) 2016, Marc-Antoine Argenton.  All rights reserved.
# =============================================================================

module DispatchQueue
  class Dispatch
    class << self

      def ncpu()
        @@ncpu ||= `sysctl -n hw.ncpu`.to_i rescue 1
      end

      @@default_queue = ThreadPoolQueue.new()

      def default_queue
        @@default_queue
      end


    end
  end # class Dispatch
end # module DispatchQueue
