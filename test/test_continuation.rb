# =============================================================================
#
# MODULE      : test/test_continuation.rb
# PROJECT     : DispatchQueue
# DESCRIPTION :
#
# Copyright (c) 2016, Marc-Antoine Argenton.  All rights reserved.
# =============================================================================


require '_test_env.rb'

module DispatchQueue
  describe Continuation do

    subject { Continuation.new }

    it "passes this one" do
      subject.must_be_instance_of Continuation
    end

  end
end
