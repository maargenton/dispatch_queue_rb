# =============================================================================
#
# MODULE      : test/test_version.rb
# PROJECT     : DispatchQueueRb
# DESCRIPTION :
#
# Copyright (c) 2016, Marc-Antoine Argenton.  All rights reserved.
# =============================================================================


require '_test_env.rb'

module DispatchQueue
  describe VERSION do

    subject { VERSION }

    it "is definied as a string" do
      subject.must_be_instance_of String
    end

  end


  class Expectation
    def initialize( target, action=nil, *args, **opts, &block )
      @target = target
      @action = action
      @args = args
      @opts = opts
      @block = block
    end

    def to
      self
    end

    def to_be
      self
    end

    def method_missing( name, *args, **opts, &block )
      # puts "method_missing( #{name.inspect} )"
      Expectation.new( self, name, *args, **opts, &block )
    end

    def inspect
      "#{@target.inspect}#{_inspect_action()}"
    end

    def ==( arg )
      Expectation.new( self, :==, arg )
    end

    def !=( arg )
      Expectation.new( self, :!=, arg )
    end

    def =~( arg, within:nil )
      Expectation.new( self, :=~, arg, within:within )
    end


  private
    def _inspect_action()
      return "" if @action.nil?
      return " #{@action} #{@args[0]}" if _is_operator_action()
      return ".#{@action}" if @args.empty? && @opts.empty?
      return ".#{@action}(#{_inspect_action_args()})"
    end

    def _is_operator_action()
      @args.count == 1 && [:==, :!=, :=~, :<=>, :<, :>, :<=, :>=, :<<, :>>].include?( @action )
    end


    def _inspect_action_args()
      return "" if @args.empty? && @opts.empty?
      return " " + ( @args.map { |a| a.inspect } +
                     @opts.map { |k,v| "#{k}: #{v.inspect}" } ).join( ', ' ) + " "
    end
  end


  # expect( subject ) < 10
  # expect( subject ).start_with?( "aaa" )
  # expect( subject ).to.start_with?( "aaa" )
  # expect( subject ).to.include?( "aaa" )
  # expect( subject ).count < 10
  # expect( subject ).count.to_equal( 10 ).within( 20 )
  # expect( subject ).count.to_equal( 10 ).within( 20 )

  describe Expectation do

    def expect( value )
      Expectation.new( value )
    end

    it "can create a new expectation" do
      expectation = expect( :value )
      expectation.must_be_instance_of Expectation
    end

    it "inspects to the wrapped value" do
      expectation = expect( :value )
      expectation.inspect.must_equal ":value"
    end

    it "inspects with method call" do
      expectation = expect( :value ).something()
      expectation.inspect.must_equal ":value.something"
    end

    it "inspects with method call and arguments" do
      expectation = expect( :value ).something(:aaa, :bbb)
      expectation.inspect.must_equal ":value.something( :aaa, :bbb )"
    end

    it "inspects with method call and optional arguments" do
      expectation = expect( :value ).something(:aaa, bbb:1)
      expectation.inspect.must_equal ":value.something( :aaa, bbb: 1 )"
    end

    it "inspects with chained method calls" do
      expectation = expect( :value ).something(:aaa, :bbb).something_else( aaa:1, bbb:2 )
      expectation.inspect.must_equal ":value.something( :aaa, :bbb ).something_else( aaa: 1, bbb: 2 )"
    end

    it "inspects with chained method calls and binary operators" do
      expectation = expect( :value ).something(:aaa, :bbb) < 10
      expectation.inspect.must_equal ":value.something( :aaa, :bbb ) < 10"
    end

    it "inspects with chained method calls and binary operators 2" do
      expectation = expect( :value ).something(:aaa, :bbb).to_be << 10
      expectation.inspect.must_equal ":value.something( :aaa, :bbb ) << 10"
    end

    it "inspects with chained method calls and binary operators 3" do
      expectation = expect( [1,2,3] ).size ==  10
      expectation.inspect.must_equal "[1, 2, 3].size == 10"
    end

    it "inspects with chained method calls and binary operators 4" do
      expectation = expect( [1,2,3] ).size !=  10
      expectation.inspect.must_equal "[1, 2, 3].size != 10"
    end

    it "inspects with chained method calls and binary operators 4" do
      expectation = expect( [1,2,3] ).size.=~( 10, within:1 )
      expectation.inspect.must_equal "[1, 2, 3].size =~ 10"
    end

  end
end
