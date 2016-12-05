# =============================================================================
#
# MODULE      : test/test_thread_queue.rb
# PROJECT     : DispatchQueue
# DESCRIPTION :
#
# Copyright (c) 2016, Marc-Antoine Argenton.  All rights reserved.
# =============================================================================


require '_test_env.rb'

module DispatchQueue
  describe ThreadQueue do

    subject { ThreadQueue.new }

    it "passes this one" do
      subject.must_be_instance_of ThreadQueue
    end

  end
end
