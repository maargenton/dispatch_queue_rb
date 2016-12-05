# =============================================================================
#
# MODULE      : lib/dispatch_queue_rb/dispatch.rb
# PROJECT     : DispatchQueue
# DESCRIPTION :
#
# Copyright (c) 2016, Marc-Antoine Argenton.  All rights reserved.
# =============================================================================

module DispatchQueue
  module Dispatch

    Result = Struct.new( :value )

    class << self
      def ncpu()
        @@ncpu ||= `sysctl -n hw.ncpu`.to_i rescue 1
      end

      def default_queue
        @@default_queue
      end

      def concurrent_map( input_array, target_queue:nil, &task )
        group = DispatchGroup.new
        target_queue ||= default_queue

        output_results = input_array.map do |e|
          result = Result.new
          target_queue.dispatch_async( group:group ) do
            result.value = task.call( e )
          end
          result
        end

        group.wait()
        output_results.map { |result| result.value }
      end


    private
      @@default_queue = ThreadPoolQueue.new()

    end # class << self
  end # class Dispatch
end # module DispatchQueue
