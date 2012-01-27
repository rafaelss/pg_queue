require "pg_queue/version"
require "pg"
require "logger"

module PgQueue
  extend self

  autoload :Worker, "pg_queue/worker"
  autoload :Queue, "pg_queue/queue"
  autoload :Job, "pg_queue/job"

  attr_accessor :logger
  self.logger = Logger.new(STDOUT)
end

