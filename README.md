# DispatchQueueRb

[![Gem Version](https://badge.fury.io/rb/dispatch_queue_rb.svg)](https://badge.fury.io/rb/dispatch_queue_rb)
[![Build Status](https://travis-ci.org/marcus999/dispatch_queue_rb.svg?branch=master)](https://travis-ci.org/marcus999/dispatch_queue_rb)
[![Code Climate](https://codeclimate.com/github/marcus999/dispatch_queue_rb/badges/gpa.svg)](https://codeclimate.com/github/marcus999/dispatch_queue_rb)
[![Issue Count](https://codeclimate.com/github/marcus999/dispatch_queue_rb/badges/issue_count.svg)](https://codeclimate.com/github/marcus999/dispatch_queue_rb)



## Overview

DispatchQueueRb is a pure ruby implementation of the Apple Grand Central Dispatch
concurrency primitives, using Ruby threads and blocking synchronization primitives
like Mutex and ConditionVariable.

It implements serial and concurrent queues, with synchronous, asynchronous,
barrier and delayed dispatch methods. It provides dispatch groups for
synchronization. It also provides a default thread pool concurrent queue,
scaled to the number of available cpu cores, used by default by all the other
queues to er form the actual work.

Beside a highly optimized lock-free C implementation with libdispatch,
Grand Central Dispatch is a shift of paradigm that expresses concurrent
programming concepts in terms of tasks that must be serialized with respect to
each other and tasks that can be performed concurrently.

Using threads, concurrency is usually defining with a fixed set of threads that
perform specific tasks, and by passing data between threads using message queues
and producer / consumer patterns. The flow of data and the sequence of
operations is often very inflexible because what threads do and where they
write their result to is often frozen at design time.

With dispatch queues, concurrency is expressed by scheduling work items to
serial and concurrent queues. The work that needs to be performed in the
context of a queue is not frozen in a dedicated thread, but passed as a block
of code to the dispatch method call. That block of code captures the data it
needs to execute, knows how to access global immutable data, and defines what
to do with the result.


### Implements:
  - SerialQueue and ConcurrentQueue
  - dispatch_async() and dispatch_sync()
  - dispatch_barrier_async() and dispatch_barrier_sync()
  - dispatch_after()
  - Dispatch.main_queue is a global serial queue attached to a single thread
    (but not the main thread).
  - Dispatch.default_queue is a global concurrent queue that is implemented as
    a thread pool, scaled to the number of available cpu cores. It is the
    default parent_queue for all private queues.

### Key differences and not supported features:
  - Implemented with Ruby threading primitives (Mutex, ConditionVariable) instead
    of high-performance lock-free algorithms
  - Aimed at MRI ruby 2.x, where ruby code cannot execute concurrently across
    multiple cpu cores. Mostly useful to manage parallel sub-processes execution.
  - Dispatch.default_queue does not monitor thread activity and does not spawn
    more threads to compensate for blocked threads.

### Version 1.0 limitations:
  - Does not implement an equivalent for dispatch_source primitives.
  - Does not support suspend / resume operations
  - Does not provide multiple priority levels for global queues


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dispatch_queue_rb'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dispatch_queue_rb

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/dispatch_queue_rb/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
