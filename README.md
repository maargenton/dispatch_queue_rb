# FolderTemplate

[![Gem Version](https://badge.fury.io/rb/dispatch_queue_rb.svg)](https://badge.fury.io/rb/dispatch_queue_rb)
[![Build Status](https://travis-ci.org/{{travis_account}}/dispatch_queue_rb.svg?branch=master)](https://travis-ci.org/{{travis_account}}/dispatch_queue_rb)
[![Code Climate](https://codeclimate.com/github/{{github_account}}/dispatch_queue_rb/badges/gpa.svg)](https://codeclimate.com/github/{{github_account}}/dispatch_queue_rb)
[![Issue Count](https://codeclimate.com/github/{{github_account}}/dispatch_queue_rb/badges/issue_count.svg)](https://codeclimate.com/github/{{github_account}}/dispatch_queue_rb)




# Project

Pure ruby implementation of GCD dispatch_queue concurrency primitives.

Implements:
  - SerialQueue and ConcurrentQueue
  - dispatch_async() and dispatch_sync()
  - dispatch_barrier_async() and dispatch_barrier_sync()
  - dispatch_after()
  - Dispatch.main_queue is a global serial queue attached to a single thread
    (but not the main thread).
  - Dispatch.default_queue is a global concurrent queue that is implemented as
    a thread pool, scaled to the number of available cpu cores. It is the
    default parent_queue for all private queues.

Key differences and not supported features:
  - Implemented with Ruby threading primitives (Mutex, ConditionVariable) instead
    of high-performance lock-free algorithms
  - Aimed at MRI ruby 2.x, where ruby code cannot execute concurrently across
    multiple cpu cores. Mostly useful to manage parallel sub-processes execution.
  - Dispatch.default_queue does not monitor thread activity and does not spawn
    more threads to compensate for blocked threads.

Version 1.0 limitations:
  - Does not implement an equivalent for dispatch_source primitives.
  - Does not support suspend / resume operations
  - Does not provide multiple priority levels for global queues



Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/dispatch_queue_rb`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

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
