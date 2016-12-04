# =============================================================================
#
# MODULE      : test/test_heap.rb
# PROJECT     : DispatchQueue
# DESCRIPTION :
#
# Copyright (c) 2016, Marc-Antoine Argenton.  All rights reserved.
# =============================================================================


require '_test_env.rb'

module DispatchQueue
  describe Heap do

    subject { Heap.new }

    def push( heap, *elements )
      elements.each { |e| heap.push( e ) }
    end

    def drain( heap )
      elements = []
      elements.push( heap.pop() ) while !heap.empty?
      elements
    end

    it "can be initialized with no argument" do
      subject.must_be_instance_of Heap
    end

    it "is empty when newly created" do
      subject.size.must_equal 0
      subject.count.must_equal 0
      subject.length.must_equal 0
      subject.empty?.must_equal true
    end

    it "stores pushed elements in an order that preserves heap property" do
      push( subject, 7, 1, 6, 2, 5, 3, 4 )
      subject.size.must_equal 7
      subject.empty?.must_equal false
      subject.elements.must_equal( [1, 2, 3, 7, 5, 6, 4] )
    end

    it "pops elements in sorted order" do
      push( subject, 7, 1, 6, 2, 5, 3, 4 )
      drain( subject ).must_equal [1, 2, 3, 4, 5, 6, 7]
    end

    it "pops elements in sorted order" do
      count = 20
      push( subject, *(1..count).to_a.shuffle )
      drain( subject ).must_equal (1..count).to_a
    end

  end
end
