# =============================================================================
#
# MODULE      : test/test_concurrent_queue.rb
# PROJECT     : DispatchQueue
# DESCRIPTION :
#
# Copyright (c) 2016, Marc-Antoine Argenton.  All rights reserved.
# =============================================================================


require '_test_env.rb'

module DispatchQueue
  describe ConcurrentQueue do

    let( :task_count )    { 10 }
    let( :log )           { [] }
    let( :lock )          { Mutex.new }
    let( :logger )        { Proc.new { |e, d| lock.synchronize { log << [e, d] } } }
    subject               { ConcurrentQueue.new }

    it "can initialize a serial queue" do
      subject.must_be_instance_of ConcurrentQueue
    end

    def task( task_id )
      logger.call( :begin_task, { task_id:task_id, thread:Thread.current } )
      sleep(0.001)
      logger.call( :end_task, { task_id:task_id, thread:Thread.current } )
    end

    describe "dispatch_async" do
      it "executes tasks concurrently" do
        (1..task_count).each { |i| subject.dispatch_async { task( i ) } }
        subject.dispatch_barrier_sync {} # wait for all previous tasks to complete

        running_count = 0
        parallel_task_count = log.map do |e,d|
          running_count += 1 if e == :begin_task
          running_count -= 1 if e == :end_task
          running_count
        end

        parallel_task_count.max.must_be :>, 1, parallel_task_count
      end

      it "preserves ordering arround barrier" do
        (1..task_count).each { |i| subject.dispatch_async { task( "a#{i}".to_sym ) } }
        subject.dispatch_barrier_async { task( "b0".to_sym ) }
        (1..task_count).each { |i| subject.dispatch_async { task( "c#{i}".to_sym ) } }
        subject.dispatch_barrier_async { task( "d0".to_sym ) }

        subject.dispatch_barrier_sync {} # wait for all previous tasks to complete

        task_id_list = log.select { |e,d| e == :begin_task }.map { |e,d| d[:task_id] }
        task_chunks = task_id_list.chunk { |e| e.to_s[0] }.map { |c, l| l }
        task_chunks.count.must_be :==, 4, task_chunks
      end

      it "resumes execution after synchronous barrier" do
        (1..task_count).each { |i| subject.dispatch_async { task( "a#{i}".to_sym ) } }
        subject.dispatch_barrier_sync { task( "b0".to_sym ) }
        (1..task_count).each { |i| subject.dispatch_async { task( "c#{i}".to_sym ) } }
        subject.dispatch_barrier_sync { task( "d0".to_sym ) }

        subject.dispatch_barrier_sync {} # wait for all previous tasks to complete

        task_id_list = log.select { |e,d| e == :begin_task }.map { |e,d| d[:task_id] }
        task_chunks = task_id_list.chunk { |e| e.to_s[0] }.map { |c, l| l }
        task_chunks.count.must_be :==, 4, task_chunks
      end
    end

    describe "with multiple concurrent queues" do
      let( :subject2 )    { ConcurrentQueue.new }

      it "interleaves barrier tasks from different queues" do
        (1..task_count).each { |i| subject.dispatch_barrier_async { task( "a#{i}".to_sym ) } }
        (1..task_count).each { |i| subject2.dispatch_barrier_async { task( "b#{i}".to_sym ) } }
        subject.dispatch_barrier_sync {} # wait for all previous tasks to complete
        subject2.dispatch_barrier_sync {} # wait for all previous tasks to complete

        task_id_list = log.select { |e,d| e == :begin_task }.map { |e,d| d[:task_id] }
        task_chunks = task_id_list.chunk { |e| e.to_s[0] }.map { |c, l| l }
        task_chunks.count.must_be :>, 3, task_chunks
      end
    end

  end
end
