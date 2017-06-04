# frozen_string_literal: true

require 'rake/testtask'
require './init.rb'

task default: [:rubocop, :spec]

desc 'Run all the tests'
Rake::TestTask.new(:spec) do |t|
  t.pattern = 'specs/*_spec.rb'
  t.warning = false
end

desc 'Rake all the Ruby'
task :rubocop do
  `rubopcop **/*.rb`
end

desc 'Run in development mode'
task :run do
  sh 'rerun -c rackup'
end

namespace :crypto do
  task :crypto_requires do
    require 'rbnacl/libsodium'
    require 'base64'
  end

  desc 'Create rbnacl key'
  task msg_key: [:crypto_requires] do
    puts "New MSG_KEY: #{SecureMessage.generate_key}"
  end

  desc 'Create cookie secret'
  task session_secret: [:crypto_requires] do
    puts "New session secret (base64 encoded): #{SecureSession.generate_secret}"
  end
end

namespace :session do
  desc 'Wipe all sessions stored in Redis'
  task :wipe do
    require 'redis'
    puts 'Deleting all sessions from Redis session store'
    wiped = SecureSession.wipe_redis_sessions
    puts "#{wiped.count} sessions deleted"
  end
end
