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

    let( :task_count )    { 4 }
    let( :log )           { [] }
    let( :lock )          { Mutex.new }
    let( :logger )        { Proc.new { |e, d| lock.synchronize { log << [e, d] } } }
    subject               { ThreadQueue.new }

    it "can initialize a thread queue" do
      subject.must_be_instance_of ThreadQueue
    end

    def task( task_id )
      logger.call( :begin_task, { task_id:task_id, thread:Thread.current } )
      sleep(0.001)
      logger.call( :end_task, { task_id:task_id, thread:Thread.current } )
    end

    describe "dispatch_async" do
      it "executes tasks serially" do
        (1..task_count).each { |i| subject.dispatch_async { task( i ) } }
        subject.dispatch_barrier_sync {} # wait for all previous tasks to complete

        log.map { |e,d| e }.must_equal [:begin_task, :end_task] * task_count
      end

      it "executes tasks in enqueue order" do
        (1..task_count).each { |i| subject.dispatch_async { task( i ) } }
        subject.dispatch_barrier_sync {} # wait for all previous tasks to complete

        task_id_list = log.select { |e,d| e == :begin_task }.map { |e,d| d[:task_id] }
        task_id_list.must_equal (1..task_count).to_a
      end

      it "resumes execution when new tasks are enqueues" do
        (1..task_count).each { |i| subject.dispatch_async { task( "a#{i}".to_sym ) } }
        subject.dispatch_barrier_sync {} # wait for all previous tasks to complete
        sleep( 0.01 )

        (1..task_count).each { |i| subject.dispatch_async { task( "b#{i}".to_sym ) } }
        subject.dispatch_barrier_sync {} # wait for all previous tasks to complete

        task_id_list = log.select { |e,d| e == :begin_task }.map { |e,d| d[:task_id] }
        task_id_list.count.must_equal task_count*2, task_id_list
      end
    end

    describe "with multiple thread queues" do
      let( :subject2 )    { ThreadQueue.new }

      it "interleaves tasks from different queues" do
        (1..task_count).each { |i| subject.dispatch_async { task( "a#{i}".to_sym ) } }
        (1..task_count).each { |i| subject2.dispatch_async { task( "b#{i}".to_sym ) } }
        subject.dispatch_barrier_sync {} # wait for all previous tasks to complete
        subject2.dispatch_barrier_sync {} # wait for all previous tasks to complete

        task_id_list = log.select { |e,d| e == :begin_task }.map { |e,d| d[:task_id] }
        task_chunks = task_id_list.chunk { |e| e.to_s[0] }.map { |c, l| l }
        task_chunks.count.must_be :>, 3, task_chunks
      end
    end

  end
end
