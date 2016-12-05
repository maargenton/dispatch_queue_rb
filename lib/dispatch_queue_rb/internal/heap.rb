# =============================================================================
#
# MODULE      : lib/dispatch_queue_rb/internal/heap.rb
# PROJECT     : DispatchQueue
# DESCRIPTION :
#
# Copyright (c) 2016, Marc-Antoine Argenton.  All rights reserved.
# =============================================================================

module DispatchQueue
  class Heap

    def initialize( &compare )
      @heap = []
      @compare = compare
    end

    def push( elt )
      @heap.push( elt )
      _sift_up( @heap.count - 1 )
    end

    def pop()
      head = @heap.first
      tail =  @heap.pop()
      @heap[0] = tail if !@heap.empty?
      _sift_down( 0 )
      head
    end

    def head()
      @heap.first
    end

    def count
      @heap.count
    end

    alias_method :size, :count
    alias_method :length, :count

    def empty?
      @heap.empty?
    end

    def elements
      @heap
    end

  private
    def _ordered?( i, j )
      a = @heap[i]
      b = @heap[j]
      return @compare.call( a, b ) if @compare
      return a < b
    end

    def _swap( i, j )
      @heap[i], @heap[j] = @heap[j], @heap[i]
    end

    def _sift_up( i )
      loop do
        parent = (i-1) / 2
        break if parent < 0
        break if _ordered?( parent, i )
        _swap( parent, i )
        i = parent
      end
    end

    def _sift_down( i )
      size = @heap.size
      loop do
        left = i*2 + 1
        right = left + 1
        largest = i

        largest = left if left < size && _ordered?( left, largest )
        largest = right if right < size && _ordered?( right, largest )
        break if largest == i
        _swap( i, largest )
        i = largest
      end
    end

  end # class Heap
end # module DispatchQueue
