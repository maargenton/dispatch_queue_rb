# =============================================================================
#
# MODULE      : test/test_thread_pool_queue.rb
# PROJECT     : DispatchQueue
# DESCRIPTION :
#
# Copyright (c) 2016, Marc-Antoine Argenton.  All rights reserved.
# =============================================================================


require '_test_env.rb'

module DispatchQueue
  describe ThreadPoolQueue do

    let( :log )     { [] }
    let( :lock )    { Mutex.new }
    let( :logger )  { Proc.new { |e, d| lock.synchronize { log << [e, d] } } }
    let( :max_threads ) { 2 }
    subject { ThreadPoolQueue.new( max_threads: max_threads,
                                   debug_trace: logger,
                                   thread_termination_delay: 0.001 ) }

    it "can initialize a thread ppol" do
      subject.must_be_instance_of ThreadPoolQueue
    end

    it "can execute work in the thread pool" do
      (1..10).each do |i|
        subject.dispatch_async do
          sleep(0.001)
          logger.call( :task, { task_id:i, thread:Thread.current } )
        end
      end
      subject.wait_for_all_threads_termination()

      completed_tasks = Set.new( log.select { |e, d| e == :task }.map { |e, d| d[:task_id] } )
      completed_tasks.must_equal( Set.new( 1..10 ) )
    end

    it "spawns and terminates threads as needed" do
      (1..200).each do |i|
        subject.dispatch_async do
          sleep(0.001)
          logger.call( :task, { task_id:i, thread:Thread.current } )
        end
      end

      sleep(0.02)
      subject.max_threads = 8
      sleep(0.01)
      subject.max_threads = 2

      subject.wait_for_all_threads_termination()

      thread_count = 0
      thread_count_list = log.map { |e, d| thread_count = d[:thread_count] || thread_count }
      major_thread_counts = thread_count_list.chunk { |n| n }.map { |cnt, e| [cnt, e.count] }.select { |t,e| e > 10 }.map { |t,e| t }
      major_thread_counts.must_equal( [2, 8, 2] )
    end

  end
end
