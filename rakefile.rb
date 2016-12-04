# =============================================================================
#
# MODULE      : rakefile.rb
# PROJECT     : DispatchQueueRb
# DESCRIPTION :
#
# Copyright (c) 2016, Marc-Antoine Argenton.  All rights reserved.
# =============================================================================


require 'bundler/gem_tasks'
require 'rake/testtask'

task default: [:test, :build]

Rake::TestTask.new do |t|
  t.libs << '.' << 'test'
  t.test_files = FileList['test/**/test_*.rb']
  t.verbose = false
end



# ----------------------------------------------------------------------------
# Definitions to help formating 'rake watch' results
# ----------------------------------------------------------------------------

TERM_WIDTH = `tput cols`.to_i || 80

def tty_red(str);           "\e[31m#{str}\e[0m" end
def tty_green(str);         "\e[32m#{str}\e[0m" end
def tty_blink(str);         "\e[5m#{str}\e[25m" end
def tty_reverse_color(str); "\e[7m#{str}\e[27m" end

def print_separator( success = true )
  if success
    puts tty_green( "-" * TERM_WIDTH )
  else
    puts tty_reverse_color(tty_red( "-" * TERM_WIDTH ))
  end
end



# ----------------------------------------------------------------------------
# Definition of watch task, that monitors the project folder for any relevant
# file change and runs the unit test of the project.
# ----------------------------------------------------------------------------

begin
  require 'watch'

  desc 'Run unit tests everytime a source or test file is changed'
  task :watch do
    Watch.new( '**/*.rb' ) do
      success = system "clear && rake test"
      print_separator( success )
    end
  end

rescue LoadError

  desc 'Run unit tests everytime a source or test file is changed'
  task :watch do
    puts
    puts "'rake watch' requires the watch gem to be available"
    puts
    puts "To install:"
    puts "    gem install watch"
    puts " or "
    puts "    sudo gem install watch"
    puts
    fail
  end
end



# ----------------------------------------------------------------------------
# Definition of add_class[class_name] task, that uses folder_template to add
# a new class to a ruvy project
# ----------------------------------------------------------------------------

PROJECT_CONTEXT = {
  project_name:       "dispatch_queue_rb",
  project_namespace:  "DispatchQueue",
  copyright_owner:    "Marc-Antoine Argenton",
  copyright_year:     "2016",
}

begin
  require 'folder_template'

  task :add_class, :class_name do |t, args|
    context = PROJECT_CONTEXT.merge( name:args[:class_name])
    FolderTemplate::SetupFolderCmd.run( '.', 'rubyclass', context )
  end
rescue LoadError
  task :add_class, :class_name do |t, args|
    puts
    puts "'rake add_class[class_name]' task requires the folder_template gem to be available"
    puts
    puts "To install:"
    puts "    gem install folder_template"
    puts " or "
    puts "    sudo gem install folder_template"
    puts
    fail
  end
end
