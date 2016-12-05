# =============================================================================
#
# MODULE      : lib/dispatch_queue_rb.rb
# PROJECT     : DispatchQueueRb
# DESCRIPTION :
#
# Copyright (c) 2016, Marc-Antoine Argenton.  All rights reserved.
# =============================================================================

require 'set'

require_relative 'dispatch_queue_rb/version.rb'

require_relative 'dispatch_queue_rb/mixins/dispatch_sync_impl.rb'
require_relative 'dispatch_queue_rb/mixins/dispatch_after_impl.rb'

require_relative 'dispatch_queue_rb/internal/condition_variable_pool.rb'
require_relative 'dispatch_queue_rb/internal/heap.rb'
require_relative 'dispatch_queue_rb/internal/continuation.rb'
require_relative 'dispatch_queue_rb/internal/thread_pool_queue.rb'
require_relative 'dispatch_queue_rb/internal/timer_pool.rb'
require_relative 'dispatch_queue_rb/internal/thread_queue.rb'

require_relative 'dispatch_queue_rb/dispatch.rb'
require_relative 'dispatch_queue_rb/serial_queue.rb'
require_relative 'dispatch_queue_rb/concurrent_queue.rb'
require_relative 'dispatch_queue_rb/dispatch_group.rb'

Dispatch = DispatchQueue::Dispatch
SerialQueue = DispatchQueue::SerialQueue
ConcurrentQueue = DispatchQueue::ConcurrentQueue
DispatchGroup = DispatchQueue::DispatchGroup
